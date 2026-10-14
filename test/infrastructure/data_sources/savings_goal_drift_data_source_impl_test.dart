import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/domain/entities/goal_contribution.dart';
import 'package:pocket_guard/domain/entities/savings_goal.dart';
import 'package:pocket_guard/infrastructure/data_sources/savings_goal_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/errors/data_exceptions.dart';

void main() {
  late AppDatabase testDb;
  late SavingsGoalDriftDataSourceImpl dataSource;

  setUp(() {
    testDb = AppDatabase(NativeDatabase.memory());
    dataSource = SavingsGoalDriftDataSourceImpl(database: testDb);
  });

  tearDown(() async {
    await testDb.close();
  });

  Future<String> createAccount({
    String name = 'Checking',
    String currency = 'USD',
    double balance = 1000,
  }) async {
    final row = await testDb
        .into(testDb.accounts)
        .insertReturning(
          AccountsCompanion.insert(
            name: name,
            currency: currency,
            balance: Value(balance),
          ),
        );
    return row.id;
  }

  Future<double> balanceOf(String accountId) =>
      testDb.getAccountBalance(accountId);

  Future<String> createGoal({
    String name = 'New Car',
    double targetAmount = 5000,
    String currency = 'USD',
  }) async {
    await dataSource.createGoal(
      SavingsGoalEntity(
        id: 'unused',
        name: name,
        targetAmount: targetAmount,
        currency: currency,
        targetDate: null,
        isArchived: false,
        createdAt: DateTime(2026, 1, 1),
      ),
    );
    return (await dataSource.getAllGoals())
        .firstWhere((g) => g.name == name)
        .id;
  }

  GoalContributionEntity contribution({
    required String goalId,
    required String? accountId,
    required double amount,
  }) {
    return GoalContributionEntity(
      id: 'unused',
      goalId: goalId,
      accountId: accountId,
      amount: amount,
      date: DateTime(2026, 2, 1),
    );
  }

  Future<double> savedIn(String goalId) async =>
      (await dataSource.getSavedAmounts())[goalId] ?? 0;

  Matcher throwsReason(SavingsGoalError reason) => throwsA(
    isA<SavingsGoalValidationException>().having(
      (e) => e.reason,
      'reason',
      reason,
    ),
  );

  group('goals CRUD', () {
    test('createGoal then getGoalById round-trips all fields', () async {
      final targetDate = DateTime(2027, 6, 30);
      await dataSource.createGoal(
        SavingsGoalEntity(
          id: 'unused',
          name: 'Trip',
          targetAmount: 1200.5,
          currency: 'EUR',
          targetDate: targetDate,
          isArchived: false,
          createdAt: DateTime(2026, 1, 1),
        ),
      );

      final goal = (await dataSource.getAllGoals()).single;
      final fetched = await dataSource.getGoalById(goal.id);
      expect(fetched!.name, 'Trip');
      expect(fetched.targetAmount, 1200.5);
      expect(fetched.currency, 'EUR');
      expect(fetched.targetDate, targetDate);
      expect(fetched.isArchived, isFalse);
    });

    test('updateGoal persists changes and can clear targetDate', () async {
      final goalId = await createGoal();
      final goal = await dataSource.getGoalById(goalId);

      await dataSource.updateGoal(
        goalId,
        goal!.copyWith(
          name: 'Used Car',
          targetAmount: 3000,
          isArchived: true,
          targetDate: null,
        ),
      );

      final updated = await dataSource.getGoalById(goalId);
      expect(updated!.name, 'Used Car');
      expect(updated.targetAmount, 3000);
      expect(updated.isArchived, isTrue);
      expect(updated.targetDate, isNull);
    });

    test('currency can change while the jar is empty', () async {
      final goalId = await createGoal();
      final goal = await dataSource.getGoalById(goalId);

      await dataSource.updateGoal(goalId, goal!.copyWith(currency: 'COP'));

      expect((await dataSource.getGoalById(goalId))!.currency, 'COP');
    });

    test('currency is locked once the goal has contributions', () async {
      final accountId = await createAccount();
      final goalId = await createGoal();
      await dataSource.addContribution(
        contribution(goalId: goalId, accountId: accountId, amount: 100),
      );
      final goal = await dataSource.getGoalById(goalId);

      await expectLater(
        dataSource.updateGoal(goalId, goal!.copyWith(currency: 'EUR')),
        throwsReason(SavingsGoalError.currencyLocked),
      );
      expect((await dataSource.getGoalById(goalId))!.currency, 'USD');
    });
  });

  group('contribution balance effects', () {
    test('deposit moves money from the account into the jar', () async {
      final accountId = await createAccount(balance: 1000);
      final goalId = await createGoal();

      await dataSource.addContribution(
        contribution(goalId: goalId, accountId: accountId, amount: 300),
      );

      expect(await balanceOf(accountId), 700);
      expect(await savedIn(goalId), 300);
    });

    test('withdrawal can go to a different account than the deposit came '
        'from', () async {
      final checking = await createAccount(name: 'Checking', balance: 1000);
      final savings = await createAccount(name: 'Savings', balance: 0);
      final goalId = await createGoal();

      await dataSource.addContribution(
        contribution(goalId: goalId, accountId: checking, amount: 400),
      );
      await dataSource.addContribution(
        contribution(goalId: goalId, accountId: savings, amount: -150),
      );

      expect(await balanceOf(checking), 600);
      expect(await balanceOf(savings), 150);
      expect(await savedIn(goalId), 250);
    });

    test('create -> edit amount -> edit account -> delete restores every '
        'balance exactly', () async {
      final a = await createAccount(name: 'A', balance: 1000);
      final b = await createAccount(name: 'B', balance: 500);
      final goalId = await createGoal();

      await dataSource.addContribution(
        contribution(goalId: goalId, accountId: a, amount: 200),
      );
      final id = (await dataSource.getContributionsForGoal(goalId)).single.id;

      await dataSource.updateContribution(
        id,
        contribution(goalId: goalId, accountId: a, amount: 350),
      );
      expect(await balanceOf(a), 650);
      expect(await savedIn(goalId), 350);

      await dataSource.updateContribution(
        id,
        contribution(goalId: goalId, accountId: b, amount: 350),
      );
      expect(await balanceOf(a), 1000);
      expect(await balanceOf(b), 150);
      expect(await savedIn(goalId), 350);

      await dataSource.deleteContribution(id);
      expect(await balanceOf(a), 1000);
      expect(await balanceOf(b), 500);
      expect(await savedIn(goalId), 0);
      expect(await dataSource.getContributionsForGoal(goalId), isEmpty);
    });

    test('editing a deposit can use the money it already holds', () async {
      // Account has 100 left after a 900 deposit; raising the deposit to
      // 1000 is valid because the original 900 is reversed first.
      final accountId = await createAccount(balance: 1000);
      final goalId = await createGoal();
      await dataSource.addContribution(
        contribution(goalId: goalId, accountId: accountId, amount: 900),
      );
      final id = (await dataSource.getContributionsForGoal(goalId)).single.id;

      await dataSource.updateContribution(
        id,
        contribution(goalId: goalId, accountId: accountId, amount: 1000),
      );

      expect(await balanceOf(accountId), 0);
      expect(await savedIn(goalId), 1000);
    });
  });

  group('contribution rules', () {
    test('rejects a deposit larger than the account balance', () async {
      final accountId = await createAccount(balance: 100);
      final goalId = await createGoal();

      await expectLater(
        dataSource.addContribution(
          contribution(goalId: goalId, accountId: accountId, amount: 100.01),
        ),
        throwsReason(SavingsGoalError.insufficientAccountBalance),
      );
      expect(await balanceOf(accountId), 100);
      expect(await savedIn(goalId), 0);
    });

    test('rejects a withdrawal larger than the jar holds', () async {
      final accountId = await createAccount(balance: 1000);
      final goalId = await createGoal();
      await dataSource.addContribution(
        contribution(goalId: goalId, accountId: accountId, amount: 200),
      );

      await expectLater(
        dataSource.addContribution(
          contribution(goalId: goalId, accountId: accountId, amount: -201),
        ),
        throwsReason(SavingsGoalError.insufficientGoalBalance),
      );
      expect(await balanceOf(accountId), 800);
      expect(await savedIn(goalId), 200);
    });

    test('rejects an account in a different currency', () async {
      final accountId = await createAccount(currency: 'EUR');
      final goalId = await createGoal(currency: 'USD');

      await expectLater(
        dataSource.addContribution(
          contribution(goalId: goalId, accountId: accountId, amount: 10),
        ),
        throwsReason(SavingsGoalError.currencyMismatch),
      );
      expect(await balanceOf(accountId), 1000);
    });

    test('rejects a zero amount', () async {
      final accountId = await createAccount();
      final goalId = await createGoal();

      await expectLater(
        dataSource.addContribution(
          contribution(goalId: goalId, accountId: accountId, amount: 0),
        ),
        throwsReason(SavingsGoalError.zeroAmount),
      );
    });

    test('deleting a deposit that a later withdrawal relied on is rejected '
        'and rolled back', () async {
      final accountId = await createAccount(balance: 1000);
      final goalId = await createGoal();
      await dataSource.addContribution(
        contribution(goalId: goalId, accountId: accountId, amount: 300),
      );
      final depositId = (await dataSource.getContributionsForGoal(
        goalId,
      )).single.id;
      await dataSource.addContribution(
        contribution(goalId: goalId, accountId: accountId, amount: -200),
      );

      await expectLater(
        dataSource.deleteContribution(depositId),
        throwsReason(SavingsGoalError.insufficientGoalBalance),
      );
      expect(await balanceOf(accountId), 900);
      expect(await savedIn(goalId), 100);
      expect(await dataSource.getContributionsForGoal(goalId), hasLength(2));
    });

    test('lowering a deposit below what was withdrawn is rejected and rolled '
        'back', () async {
      final accountId = await createAccount(balance: 1000);
      final goalId = await createGoal();
      await dataSource.addContribution(
        contribution(goalId: goalId, accountId: accountId, amount: 300),
      );
      final depositId = (await dataSource.getContributionsForGoal(
        goalId,
      )).single.id;
      await dataSource.addContribution(
        contribution(goalId: goalId, accountId: accountId, amount: -200),
      );

      await expectLater(
        dataSource.updateContribution(
          depositId,
          contribution(goalId: goalId, accountId: accountId, amount: 100),
        ),
        throwsReason(SavingsGoalError.insufficientGoalBalance),
      );
      expect(await balanceOf(accountId), 900);
      expect(await savedIn(goalId), 100);
    });
  });

  group('deleting accounts and goals', () {
    test('deleting the source account keeps the money in the jar', () async {
      final accountId = await createAccount(balance: 1000);
      final goalId = await createGoal();
      await dataSource.addContribution(
        contribution(goalId: goalId, accountId: accountId, amount: 400),
      );

      await (testDb.delete(
        testDb.accounts,
      )..where((tbl) => tbl.id.equals(accountId))).go();

      expect(await savedIn(goalId), 400);
      final orphan = (await dataSource.getContributionsForGoal(goalId)).single;
      expect(orphan.accountId, isNull);

      // Nowhere to reverse its effect into.
      await expectLater(
        dataSource.deleteContribution(orphan.id),
        throwsReason(SavingsGoalError.accountMissing),
      );
    });

    test('deleting an empty goal needs no refund account', () async {
      final goalId = await createGoal();

      await dataSource.deleteGoal(goalId);

      expect(await dataSource.getGoalById(goalId), isNull);
    });

    test('deleting a funded goal requires a refund account', () async {
      final accountId = await createAccount(balance: 1000);
      final goalId = await createGoal();
      await dataSource.addContribution(
        contribution(goalId: goalId, accountId: accountId, amount: 250),
      );

      await expectLater(
        dataSource.deleteGoal(goalId),
        throwsReason(SavingsGoalError.refundAccountRequired),
      );
      expect(await dataSource.getGoalById(goalId), isNotNull);
      expect(await balanceOf(accountId), 750);
    });

    test('deleting a funded goal refunds the saved amount and removes its '
        'history', () async {
      final checking = await createAccount(name: 'Checking', balance: 1000);
      final savings = await createAccount(name: 'Savings', balance: 0);
      final goalId = await createGoal();
      await dataSource.addContribution(
        contribution(goalId: goalId, accountId: checking, amount: 400),
      );
      await dataSource.addContribution(
        contribution(goalId: goalId, accountId: checking, amount: -100),
      );

      await dataSource.deleteGoal(goalId, refundAccountId: savings);

      expect(await balanceOf(checking), 700);
      expect(await balanceOf(savings), 300);
      expect(await dataSource.getGoalById(goalId), isNull);
      expect(await dataSource.getContributionsForGoal(goalId), isEmpty);
    });

    test('refund account must match the goal currency', () async {
      final usd = await createAccount(currency: 'USD');
      final eur = await createAccount(name: 'Euro', currency: 'EUR');
      final goalId = await createGoal();
      await dataSource.addContribution(
        contribution(goalId: goalId, accountId: usd, amount: 100),
      );

      await expectLater(
        dataSource.deleteGoal(goalId, refundAccountId: eur),
        throwsReason(SavingsGoalError.currencyMismatch),
      );
      expect(await dataSource.getGoalById(goalId), isNotNull);
      expect(await balanceOf(eur), 1000);
    });
  });

  test('getSavedAmounts sums per goal and omits goals without '
      'contributions', () async {
    final accountId = await createAccount(balance: 1000);
    final car = await createGoal(name: 'Car');
    final trip = await createGoal(name: 'Trip');
    final empty = await createGoal(name: 'Empty');
    await dataSource.addContribution(
      contribution(goalId: car, accountId: accountId, amount: 100),
    );
    await dataSource.addContribution(
      contribution(goalId: car, accountId: accountId, amount: 50),
    );
    await dataSource.addContribution(
      contribution(goalId: trip, accountId: accountId, amount: 25),
    );

    final saved = await dataSource.getSavedAmounts();

    expect(saved[car], 150);
    expect(saved[trip], 25);
    expect(saved.containsKey(empty), isFalse);
  });
}
