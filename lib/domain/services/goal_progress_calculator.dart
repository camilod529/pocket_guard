import 'dart:math';

import 'package:pocket_guard/domain/entities/savings_goal.dart';

enum GoalStatus { inProgress, completed, overdue }

class GoalProgress {
  final SavingsGoalEntity goal;
  final double saved;
  final double remaining; // never negative - over-funding counts as done
  final double percentSaved; // fraction of targetAmount - can exceed 1.0
  final GoalStatus status;

  /// How much to save per month to reach the target by its date. Null when
  /// there's no target date, the goal is already reached, or it's overdue.
  final double? monthlyAmountNeeded;

  const GoalProgress({
    required this.goal,
    required this.saved,
    required this.remaining,
    required this.percentSaved,
    required this.status,
    required this.monthlyAmountNeeded,
  });
}

/// Pure saved-vs-target math - no DB/Riverpod dependency, mirroring
/// BudgetProgressCalculator. [now] is passed in so tests control the date.
class GoalProgressCalculator {
  static const double _averageDaysPerMonth = 30.44;

  static GoalProgress calculate({
    required SavingsGoalEntity goal,
    required double saved,
    required DateTime now,
  }) {
    final remaining = (goal.targetAmount - saved).clamp(0.0, double.infinity);
    final percentSaved = goal.targetAmount <= 0
        ? 1.0
        : saved / goal.targetAmount;

    final today = DateTime(now.year, now.month, now.day);
    final targetDate = goal.targetDate;
    final targetDay = targetDate == null
        ? null
        : DateTime(targetDate.year, targetDate.month, targetDate.day);

    final GoalStatus status;
    if (remaining <= 0) {
      status = GoalStatus.completed;
    } else if (targetDay != null && targetDay.isBefore(today)) {
      status = GoalStatus.overdue;
    } else {
      status = GoalStatus.inProgress;
    }

    double? monthlyAmountNeeded;
    if (status == GoalStatus.inProgress && targetDay != null) {
      final daysLeft = targetDay.difference(today).inDays;
      // Anything due within the current month still needs the full amount
      // this month, so never divide by less than one.
      final monthsLeft = max(1, (daysLeft / _averageDaysPerMonth).ceil());
      monthlyAmountNeeded = remaining / monthsLeft;
    }

    return GoalProgress(
      goal: goal,
      saved: saved,
      remaining: remaining,
      percentSaved: percentSaved,
      status: status,
      monthlyAmountNeeded: monthlyAmountNeeded,
    );
  }
}
