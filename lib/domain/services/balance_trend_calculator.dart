import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/domain/entities/goal_contribution.dart';
import 'package:pocket_guard/domain/entities/transaction.dart';

/// One dated change to the combined balance of the accounts being charted.
class BalanceChange {
  final DateTime date;
  final double delta;

  const BalanceChange(this.date, this.delta);
}

/// Pure end-of-day balance math - no DB/Riverpod dependency.
///
/// Works backwards from today's balance rather than forwards from zero:
/// account balances are maintained exactly (every transaction and goal
/// movement is applied as it's saved, whatever its date), so the balance at
/// the end of day d is the current balance minus every change dated after
/// day d.
class BalanceTrendCalculator {
  /// End-of-day balances for every day of [month]'s calendar month; index 0
  /// is day 1. [changes] must include everything dated on or after the 1st
  /// of that month - including dates after the month, up to and beyond
  /// today - or the earlier days come out wrong.
  static List<double> dailyBalances({
    required DateTime month,
    required double currentBalance,
    required Iterable<BalanceChange> changes,
  }) {
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    return [
      for (var day = 1; day <= lastDay; day++)
        currentBalance -
            changes
                .where(
                  (c) => !c.date.isBefore(
                    DateTime(month.year, month.month, day + 1),
                  ),
                )
                .fold<double>(0, (sum, c) => sum + c.delta),
    ];
  }

  /// How [transaction] changed the combined balance of [accountIds].
  /// A transfer between two charted accounts nets to zero.
  static double transactionDelta(
    TransactionEntity transaction,
    TransactionType type,
    Set<String> accountIds,
  ) {
    final fromCharted = accountIds.contains(transaction.accountId);
    return switch (type) {
      TransactionType.income => fromCharted ? transaction.amount : 0,
      TransactionType.expense => fromCharted ? -transaction.amount : 0,
      TransactionType.transfer =>
        (fromCharted ? -transaction.amount : 0) +
            (accountIds.contains(transaction.toAccountId)
                ? transaction.amount
                : 0),
    };
  }

  /// How a savings goal movement changed the combined balance of
  /// [accountIds]: a deposit (+) leaves the account, a withdrawal (-)
  /// returns to it.
  static double contributionDelta(
    GoalContributionEntity contribution,
    Set<String> accountIds,
  ) {
    return accountIds.contains(contribution.accountId)
        ? -contribution.amount
        : 0;
  }
}
