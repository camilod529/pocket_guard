import 'package:pocket_guard/domain/entities/wishlist_item.dart';

enum AffordabilityStatus {
  /// Enough money, and within the category's budget (if it has one).
  affordable,

  /// The money is there, but buying it would exceed this month's budget
  /// for its category.
  overBudget,

  /// Not enough money across the item's currency accounts (plus its linked
  /// savings jar, if any).
  insufficientFunds,

  /// Already bought - affordability no longer applies.
  purchased,
}

class Affordability {
  final WishlistItemEntity item;
  final AffordabilityStatus status;

  /// How much is missing - funds for [AffordabilityStatus.insufficientFunds],
  /// budget for [AffordabilityStatus.overBudget]; 0 otherwise.
  final double shortfall;

  /// The linked savings jar alone holds the full price.
  final bool coveredByGoal;

  const Affordability({
    required this.item,
    required this.status,
    required this.shortfall,
    required this.coveredByGoal,
  });
}

/// Pure "can I buy this?" math - no DB/Riverpod dependency, mirroring
/// BudgetProgressCalculator. Callers pass amounts already filtered to the
/// item's currency (nothing is converted, same as budgets and goals).
class AffordabilityCalculator {
  /// [availableFunds]: sum of balances of accounts in the item's currency.
  /// Money in savings jars has already left those balances.
  /// [budgetRemaining]: this month's remaining budget for the item's
  /// category in its currency, or null when there's no such active budget.
  /// [goalSaved]: what the item's linked jar holds, or null when unlinked.
  static Affordability calculate({
    required WishlistItemEntity item,
    required double availableFunds,
    required double? budgetRemaining,
    required double? goalSaved,
  }) {
    final coveredByGoal = goalSaved != null && goalSaved >= item.price;

    if (item.isPurchased) {
      return Affordability(
        item: item,
        status: AffordabilityStatus.purchased,
        shortfall: 0,
        coveredByGoal: coveredByGoal,
      );
    }

    final funds = availableFunds + (goalSaved ?? 0);
    if (item.price > funds) {
      return Affordability(
        item: item,
        status: AffordabilityStatus.insufficientFunds,
        shortfall: item.price - funds,
        coveredByGoal: false,
      );
    }

    // Money saved in a jar still counts as spending in the category's
    // budget once it's actually spent, so the budget check applies
    // regardless of where the money comes from.
    if (budgetRemaining != null && item.price > budgetRemaining) {
      return Affordability(
        item: item,
        status: AffordabilityStatus.overBudget,
        shortfall: item.price - budgetRemaining.clamp(0, double.infinity),
        coveredByGoal: coveredByGoal,
      );
    }

    return Affordability(
      item: item,
      status: AffordabilityStatus.affordable,
      shortfall: 0,
      coveredByGoal: coveredByGoal,
    );
  }
}
