import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/domain/entities/account.dart';
import 'package:pocket_guard/domain/entities/goal_contribution.dart';
import 'package:pocket_guard/infrastructure/data_sources/account_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/savings_goal_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/errors/data_exceptions.dart';
import 'package:pocket_guard/presentation/providers/account/account_provider.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/providers/savings_goal/goal_progress_provider.dart';
import 'package:pocket_guard/presentation/providers/savings_goal/savings_goal_form_provider.dart';
import 'package:pocket_guard/presentation/providers/savings_goal/savings_goal_provider.dart';
import 'package:pocket_guard/presentation/providers/savings_goal/savings_goals_provider.dart';
import 'package:pocket_guard/utils/constants/global_constants.dart';

void main() {
  late AppDatabase testDb;
  late ProviderContainer container;

  setUp(() {
    testDb = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        accountDataSourceProvider.overrideWith(
          (ref) => AccountDriftDataSourceImpl(database: testDb),
        ),
        savingsGoalDataSourceProvider.overrideWith(
          (ref) => SavingsGoalDriftDataSourceImpl(database: testDb),
        ),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await testDb.close();
  });

  Future<String> createAccount(String currency, {double balance = 1000}) async {
    await AccountDriftDataSourceImpl(database: testDb).createAccount(
      AccountEntity(
        id: GlobalConstants.createId,
        name: currency,
        currency: currency,
        balance: balance,
        type: AccountType.cash,
        sortOrder: 0,
      ),
    );
    final accounts = await testDb.select(testDb.accounts).get();
    return accounts.firstWhere((a) => a.currency == currency).id;
  }

  /// Drives the real form provider to create a goal; returns its id.
  Future<String> createGoalViaForm({
    String name = 'New Car',
    double target = 5000,
  }) async {
    final provider = savingsGoalFormProvider(GlobalConstants.createId);
    final sub = container.listen(provider, (_, _) {});
    await container.read(provider.future);
    final notifier = container.read(provider.notifier);
    notifier.nameChanged(name);
    notifier.targetAmountChanged(target);

    expect(await notifier.onFormSubmit(), isTrue);
    sub.close();

    final goals = await container.read(savingsGoalsProvider.future);
    return goals.firstWhere((g) => g.name == name).id;
  }

  GoalContributionEntity contribution(
    String goalId,
    String accountId,
    double amount,
  ) => GoalContributionEntity(
    id: GlobalConstants.createId,
    goalId: goalId,
    accountId: accountId,
    amount: amount,
    date: DateTime.now(),
  );

  test('form defaults the currency when every account shares one', () async {
    await createAccount('COP');

    final goalId = await createGoalViaForm();

    final goal = (await container.read(savingsGoalsProvider.future)).single;
    expect(goal.id, goalId);
    expect(goal.currency, 'COP');
    expect(goal.targetAmount, 5000);
  });

  test('form rejects a missing name and amount without saving', () async {
    await createAccount('USD');
    final provider = savingsGoalFormProvider(GlobalConstants.createId);
    final sub = container.listen(provider, (_, _) {});
    await container.read(provider.future);

    expect(await container.read(provider.notifier).onFormSubmit(), isFalse);

    final state = container.read(provider).value!;
    expect(state.isFormPure, isFalse);
    expect(state.name.isNotValid, isTrue);
    expect(state.targetAmount.isNotValid, isTrue);
    expect(await container.read(savingsGoalsProvider.future), isEmpty);
    sub.close();
  });

  test('deposit and withdrawal refresh both account caches and the goal '
      'progress', () async {
    final accountId = await createAccount('USD');
    final goalId = await createGoalViaForm();

    // Prime both caches so the test proves they get refreshed, not just
    // lazily loaded fresh.
    final accountsSub = container.listen(accountsProvider, (_, _) {});
    final progressSub = container.listen(goalProgressProvider, (_, _) {});
    expect(
      (await container.read(accountsProvider.future)).single.balance,
      1000,
    );
    expect(
      (await container.read(accountProvider(accountId).future))!.balance,
      1000,
    );

    final notifier = container.read(savingsGoalsProvider.notifier);
    await notifier.addContribution(contribution(goalId, accountId, 300));

    expect((await container.read(accountsProvider.future)).single.balance, 700);
    expect(
      (await container.read(accountProvider(accountId).future))!.balance,
      700,
    );
    expect(
      (await container.read(goalProgressProvider.future)).single.saved,
      300,
    );

    await notifier.addContribution(contribution(goalId, accountId, -100));

    expect((await container.read(accountsProvider.future)).single.balance, 800);
    expect(
      (await container.read(goalProgressProvider.future)).single.saved,
      200,
    );
    expect(
      await container.read(goalContributionsProvider(goalId).future),
      hasLength(2),
    );
    accountsSub.close();
    progressSub.close();
  });

  test('a rejected contribution rethrows its reason and leaves the list '
      'usable', () async {
    final accountId = await createAccount('USD', balance: 50);
    final goalId = await createGoalViaForm();
    final notifier = container.read(savingsGoalsProvider.notifier);

    await expectLater(
      notifier.addContribution(contribution(goalId, accountId, 100)),
      throwsA(
        isA<SavingsGoalValidationException>().having(
          (e) => e.reason,
          'reason',
          SavingsGoalError.insufficientAccountBalance,
        ),
      ),
    );

    final goals = container.read(savingsGoalsProvider);
    expect(goals.hasError, isFalse);
    expect(goals.value, hasLength(1));
  });

  test('editing a goal refreshes the single-goal cache', () async {
    await createAccount('USD');
    final goalId = await createGoalViaForm(name: 'Car');

    // Load the keepAlive single-goal cache before editing.
    expect(
      (await container.read(savingsGoalProvider(goalId).future))!.name,
      'Car',
    );

    final provider = savingsGoalFormProvider(goalId);
    final sub = container.listen(provider, (_, _) {});
    await container.read(provider.future);
    final notifier = container.read(provider.notifier);
    notifier.nameChanged('Motorbike');
    notifier.targetAmountChanged(2000);
    expect(await notifier.onFormSubmit(), isTrue);
    sub.close();

    final cached = await container.read(savingsGoalProvider(goalId).future);
    expect(cached!.name, 'Motorbike');
    expect(cached.targetAmount, 2000);
  });

  test('deleting a funded goal refunds the money into the account '
      'caches', () async {
    final accountId = await createAccount('USD');
    final goalId = await createGoalViaForm();
    final notifier = container.read(savingsGoalsProvider.notifier);
    await notifier.addContribution(contribution(goalId, accountId, 400));

    final accountsSub = container.listen(accountsProvider, (_, _) {});
    expect((await container.read(accountsProvider.future)).single.balance, 600);

    await notifier.deleteGoal(goalId, refundAccountId: accountId);

    expect(
      (await container.read(accountsProvider.future)).single.balance,
      1000,
    );
    expect(
      (await container.read(accountProvider(accountId).future))!.balance,
      1000,
    );
    expect(await container.read(savingsGoalsProvider.future), isEmpty);
    expect(await container.read(savingsGoalProvider(goalId).future), isNull);
    accountsSub.close();
  });
}
