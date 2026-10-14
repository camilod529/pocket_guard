import 'package:pocket_guard/domain/services/affordability_calculator.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/providers/budget/budget_progress_provider.dart';
import 'package:pocket_guard/presentation/providers/savings_goal/goal_progress_provider.dart';
import 'package:pocket_guard/presentation/providers/wishlist/wishlist_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wishlist_affordability_provider.g.dart';

/// Every wishlist item with a can-I-buy-it verdict. Recomputes whenever
/// the wishlist, account balances, this month's budgets or savings jars
/// change - all four are watched.
@riverpod
Future<List<Affordability>> wishlistAffordability(Ref ref) async {
  final items = await ref.watch(wishlistProvider.future);
  final accounts = await ref.watch(accountsProvider.future);
  final budgets = await ref.watch(budgetProgressProvider.future);
  final goals = await ref.watch(goalProgressProvider.future);

  final fundsByCurrency = <String, double>{};
  for (final account in accounts) {
    fundsByCurrency.update(
      account.currency,
      (total) => total + account.balance,
      ifAbsent: () => account.balance,
    );
  }
  final savedByGoal = {for (final g in goals) g.goal.id: g};

  return [
    for (final item in items)
      AffordabilityCalculator.calculate(
        item: item,
        availableFunds: fundsByCurrency[item.currency] ?? 0,
        budgetRemaining: item.categoryId == null
            ? null
            : budgets
                  .where(
                    (b) =>
                        b.budget.categoryId == item.categoryId &&
                        b.budget.currency == item.currency,
                  )
                  .map((b) => b.remaining)
                  .firstOrNull,
        // A jar in another currency can't pay for this item.
        goalSaved: switch (savedByGoal[item.goalId]) {
          final goal? when goal.goal.currency == item.currency => goal.saved,
          _ => null,
        },
      ),
  ];
}
