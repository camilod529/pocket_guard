import 'package:pocket_guard/domain/entities/budget.dart';
import 'package:pocket_guard/domain/entities/transaction.dart';

enum BudgetStatus { onTrack, warning, exceeded }

class BudgetProgress {
  final BudgetEntity budget;
  final double spent;
  final double remaining;
  final double percentUsed; // fraction of monthlyLimit spent - can exceed 1.0
  final BudgetStatus status;

  const BudgetProgress({
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.percentUsed,
    required this.status,
  });
}

/// Pure date-free spend-vs-limit math - no DB/Riverpod dependency, mirroring
/// RecurringTransactionScheduler's shape. Callers are responsible for
/// already filtering [categoryTransactionsThisMonth] down to this budget's
/// category and the current calendar month (see budget_progress_provider.dart).
class BudgetProgressCalculator {
  static const double warningThreshold = 0.75;

  static BudgetProgress calculate({
    required BudgetEntity budget,
    required List<TransactionEntity> categoryTransactionsThisMonth,
  }) {
    final spent = categoryTransactionsThisMonth.fold<double>(
      0,
      (sum, tx) => sum + tx.amount,
    );
    final remaining = budget.monthlyLimit - spent;

    // A zero/negative limit can't happen through the form (validated
    // there), but stay well-defined rather than dividing by zero if one
    // ever ends up in the data some other way.
    final percentUsed = budget.monthlyLimit <= 0
        ? (spent > 0 ? double.infinity : 0.0)
        : spent / budget.monthlyLimit;

    final BudgetStatus status;
    if (percentUsed > 1.0) {
      status = BudgetStatus.exceeded;
    } else if (percentUsed >= warningThreshold) {
      status = BudgetStatus.warning;
    } else {
      status = BudgetStatus.onTrack;
    }

    return BudgetProgress(
      budget: budget,
      spent: spent,
      remaining: remaining,
      percentUsed: percentUsed,
      status: status,
    );
  }
}
