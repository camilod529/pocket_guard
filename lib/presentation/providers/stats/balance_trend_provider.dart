import 'package:pocket_guard/domain/entities/transaction_filter.dart';
import 'package:pocket_guard/domain/services/balance_trend_calculator.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/providers/category/categories_provider.dart';
import 'package:pocket_guard/presentation/providers/savings_goal/savings_goals_provider.dart';
import 'package:pocket_guard/presentation/providers/selected_date_range_provider.dart';
import 'package:pocket_guard/presentation/providers/transaction/transactions_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'balance_trend_provider.g.dart';

/// End-of-day balances (index 0 = day 1) for the calendar's selected month,
/// combining every account in [currency] - or just [accountId] when given.
///
/// Queries the repositories directly instead of reusing transactionsProvider:
/// that list is narrowed to the selected month *and* the user's search and
/// category filters, while working back from today's balance needs every
/// change since the month began, unfiltered (see BalanceTrendCalculator).
@riverpod
Future<List<double>> balanceTrend(
  Ref ref,
  String currency,
  String? accountId,
) async {
  // Every dependency is registered before the first await, so this can't
  // be disposed between awaits and then try to watch something.
  // transactionsProvider / savingsGoalsProvider: results unused, watched so
  // the chart recomputes after any transaction or goal movement.
  final transactionsChanged = ref.watch(transactionsProvider.future);
  final goalsChanged = ref.watch(savingsGoalsProvider.future);
  final accountsFuture = ref.watch(accountsProvider.future);
  final categoriesFuture = ref.watch(categoriesProvider.future);
  final transactionRepository = ref.watch(transactionRepositoryProvider);
  final goalRepository = ref.watch(savingsGoalRepositoryProvider);
  final range = ref.watch(selectedDateRangeProvider);

  await transactionsChanged;
  await goalsChanged;
  final accounts = await accountsFuture;
  final categories = await categoriesFuture;

  final monthStart = DateTime(range.start.year, range.start.month);
  final charted = accounts
      .where(
        (a) =>
            a.currency == currency && (accountId == null || a.id == accountId),
      )
      .toList();
  final chartedIds = {for (final a in charted) a.id};
  final typeByCategory = {for (final c in categories) c.id: c.type};

  final transactions = await transactionRepository.getAllTransactions(
    filter: TransactionFilter(startDate: monthStart),
  );
  final contributions = await goalRepository.getContributionsSince(
    monthStart,
  );

  return BalanceTrendCalculator.dailyBalances(
    month: monthStart,
    currentBalance: charted.fold(0, (sum, a) => sum + a.balance),
    changes: [
      for (final tx in transactions)
        if (typeByCategory[tx.categoryId] case final type?)
          BalanceChange(
            tx.date,
            BalanceTrendCalculator.transactionDelta(tx, type, chartedIds),
          ),
      for (final c in contributions)
        BalanceChange(
          c.date,
          BalanceTrendCalculator.contributionDelta(c, chartedIds),
        ),
    ],
  );
}
