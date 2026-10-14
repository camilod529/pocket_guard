import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/domain/entities/goal_contribution.dart';
import 'package:pocket_guard/domain/entities/savings_goal.dart';
import 'package:pocket_guard/domain/entities/transaction.dart';
import 'package:pocket_guard/infrastructure/data_sources/account_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/category_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/savings_goal_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/transaction_drift_data_source_impl.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/providers/category/categories_provider.dart';
import 'package:pocket_guard/presentation/providers/savings_goal/savings_goals_provider.dart';
import 'package:pocket_guard/presentation/providers/selected_date_range_provider.dart';
import 'package:pocket_guard/presentation/providers/stats/balance_trend_provider.dart';
import 'package:pocket_guard/presentation/providers/transaction/transactions_provider.dart';

/// Applies real transactions and a goal deposit through the data sources
/// (so account balances change exactly as in the app), then checks the
/// chart reproduces the balance the account had at the end of each day.
void main() {
  late AppDatabase testDb;
  late ProviderContainer container;
  late TransactionDriftDataSourceImpl transactions;
  late SavingsGoalDriftDataSourceImpl goals;
  late Map<TransactionType, String> categoryByType;

  // The chart shows the calendar's selected month (the current one by
  // default); every date below is inside it.
  final now = DateTime.now();
  DateTime day(int d, [int hour = 12]) =>
      DateTime(now.year, now.month, d, hour);

  setUp(() async {
    testDb = AppDatabase(NativeDatabase.memory());
    transactions = TransactionDriftDataSourceImpl(database: testDb);
    goals = SavingsGoalDriftDataSourceImpl(database: testDb);
    container = ProviderContainer(
      overrides: [
        accountDataSourceProvider.overrideWith(
          (ref) => AccountDriftDataSourceImpl(database: testDb),
        ),
        categoryDataSourceProvider.overrideWith(
          (ref) => CategoryDriftDataSourceImpl(database: testDb),
        ),
        transactionDataSourceProvider.overrideWith((ref) => transactions),
        savingsGoalDataSourceProvider.overrideWith((ref) => goals),
      ],
    );

    final categories = await container.read(categoriesProvider.future);
    categoryByType = {for (final c in categories) c.type: c.id};

    for (final (id, currency) in [('a', 'USD'), ('b', 'USD'), ('e', 'EUR')]) {
      await testDb
          .into(testDb.accounts)
          .insert(
            AccountsCompanion.insert(
              id: Value(id),
              name: id,
              currency: currency,
              balance: const Value(1000),
            ),
          );
    }
  });

  tearDown(() async {
    container.dispose();
    await testDb.close();
  });

  Future<void> addTransaction(
    TransactionType type,
    double amount,
    DateTime date, {
    String from = 'a',
    String? to,
  }) => transactions.createTransaction(
    TransactionEntity(
      id: 'unused',
      amount: amount,
      description: null,
      categoryId: categoryByType[type]!,
      date: date,
      accountId: from,
      toAccountId: to,
    ),
  );

  Future<List<double>> trend(String currency, String? accountId) async {
    final provider = balanceTrendProvider(currency, accountId);
    final sub = container.listen(provider, (_, _) {});
    try {
      return await container.read(provider.future);
    } finally {
      sub.close();
    }
  }

  test('reconstructs each day from the real, current balance', () async {
    await addTransaction(TransactionType.expense, 100, day(1));
    await addTransaction(TransactionType.income, 50, day(2));
    await addTransaction(TransactionType.transfer, 200, day(3), to: 'b');
    await goals.createGoal(
      SavingsGoalEntity(
        id: 'unused',
        name: 'Trip',
        targetAmount: 1000,
        currency: 'USD',
        targetDate: null,
        isArchived: false,
        createdAt: day(1),
      ),
    );
    await goals.addContribution(
      GoalContributionEntity(
        id: 'unused',
        goalId: (await goals.getAllGoals()).single.id,
        accountId: 'a',
        amount: 300,
        date: day(4),
      ),
    );
    // Account a: 1000 -100 +50 -200 -300 = 450 now.
    expect(await testDb.getAccountBalance('a'), 450);

    final a = await trend('USD', 'a');
    expect(a.sublist(0, 4), [900, 950, 750, 450]);
    expect(a.last, 450);

    // b only sees the transfer arrive.
    final b = await trend('USD', 'b');
    expect(b.sublist(0, 3), [1000, 1000, 1200]);

    // All USD accounts: the a -> b transfer nets out; the jar deposit
    // doesn't (the money left both accounts' total).
    final allUsd = await trend('USD', null);
    expect(allUsd.sublist(0, 4), [1900, 1950, 1950, 1650]);
  });

  test('other currencies never leak into the line', () async {
    await addTransaction(TransactionType.expense, 999, day(1), from: 'e');

    expect((await trend('USD', null)).toSet(), {2000});
    expect((await trend('EUR', null)).first, 1);
  });

  test('follows the month selected in the calendar', () async {
    await addTransaction(TransactionType.expense, 100, day(1));
    final lastMonth = DateTime(now.year, now.month - 1);
    container
        .read(selectedDateRangeProvider.notifier)
        .state = DateRangeSelection(
      start: lastMonth,
      end: DateTime(now.year, now.month, 0, 23, 59, 59),
      selectedDay: lastMonth,
      type: DateRangeType.month,
    );

    // All of last month was before this month's expense.
    final previous = await trend('USD', 'a');
    expect(previous, hasLength(DateTime(now.year, now.month, 0).day));
    expect(previous.toSet(), {1000});
  });
}
