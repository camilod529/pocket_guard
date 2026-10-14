import 'package:pocket_guard/domain/entities/transaction_filter.dart';
import 'package:pocket_guard/domain/services/budget_progress_calculator.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/providers/budget/budgets_provider.dart';
import 'package:pocket_guard/presentation/providers/transaction/transactions_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'budget_progress_provider.g.dart';

/// Combines the active budgets with this month's actual spending per
/// category. Deliberately queries the repository directly (not through
/// transactionsProvider's cached list) so the date-range filter happens at
/// the query layer, matching how the rest of the app filters transactions
/// (see TransactionFilter) - but still watches transactionsProvider (result
/// discarded) purely to pick up a dependency, so this recomputes whenever
/// any transaction is created/updated/deleted anywhere in the app.
@riverpod
Future<List<BudgetProgress>> budgetProgress(Ref ref) async {
  ref.watch(transactionsProvider);

  final budgets = await ref.watch(budgetsProvider.future);
  final repository = ref.watch(transactionRepositoryProvider);
  final accounts = await ref.watch(accountsProvider.future);
  final accountCurrencyById = {for (final a in accounts) a.id: a.currency};

  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

  final progress = <BudgetProgress>[];
  for (final budget in budgets.where((b) => b.isActive)) {
    final transactions = await repository.getAllTransactions(
      filter: TransactionFilter(
        categoryIds: [budget.categoryId],
        startDate: startOfMonth,
        endDate: endOfMonth,
      ),
    );
    // A category can have transactions from accounts in different
    // currencies (e.g. a "Dining" category used by both a USD and a EUR
    // account) - only count spending that's actually in the budget's own
    // currency, rather than summing mismatched currencies together.
    final sameCurrencyTransactions = transactions
        .where((tx) => accountCurrencyById[tx.accountId] == budget.currency)
        .toList();
    progress.add(
      BudgetProgressCalculator.calculate(
        budget: budget,
        categoryTransactionsThisMonth: sameCurrencyTransactions,
      ),
    );
  }
  return progress;
}
