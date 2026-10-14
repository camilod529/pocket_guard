import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_guard/domain/entities/savings_goal.dart';
import 'package:pocket_guard/domain/services/goal_progress_calculator.dart';

void main() {
  final now = DateTime(2026, 3, 15, 18, 30);

  SavingsGoalEntity goal({double targetAmount = 1000, DateTime? targetDate}) {
    return SavingsGoalEntity(
      id: 'goal',
      name: 'Goal',
      targetAmount: targetAmount,
      currency: 'USD',
      targetDate: targetDate,
      isArchived: false,
      createdAt: DateTime(2026, 1, 1),
    );
  }

  test('partial progress with no target date', () {
    final progress = GoalProgressCalculator.calculate(
      goal: goal(),
      saved: 250,
      now: now,
    );

    expect(progress.remaining, 750);
    expect(progress.percentSaved, 0.25);
    expect(progress.status, GoalStatus.inProgress);
    expect(progress.monthlyAmountNeeded, isNull);
  });

  test('reaching the target exactly is completed', () {
    final progress = GoalProgressCalculator.calculate(
      goal: goal(targetDate: DateTime(2026, 1, 1)),
      saved: 1000,
      now: now,
    );

    expect(progress.status, GoalStatus.completed);
    expect(progress.remaining, 0);
    expect(progress.monthlyAmountNeeded, isNull);
  });

  test('over-funding is completed with zero remaining and >100%', () {
    final progress = GoalProgressCalculator.calculate(
      goal: goal(),
      saved: 1200,
      now: now,
    );

    expect(progress.status, GoalStatus.completed);
    expect(progress.remaining, 0);
    expect(progress.percentSaved, 1.2);
  });

  test('past target date and not reached is overdue', () {
    final progress = GoalProgressCalculator.calculate(
      goal: goal(targetDate: DateTime(2026, 3, 14)),
      saved: 100,
      now: now,
    );

    expect(progress.status, GoalStatus.overdue);
    expect(progress.monthlyAmountNeeded, isNull);
  });

  test('target date of today is still in progress, needing it all now', () {
    final progress = GoalProgressCalculator.calculate(
      goal: goal(targetDate: DateTime(2026, 3, 15)),
      saved: 100,
      now: now,
    );

    expect(progress.status, GoalStatus.inProgress);
    expect(progress.monthlyAmountNeeded, 900);
  });

  test('spreads the remainder across the months left', () {
    // 3/15 -> 9/15 is 184 days, ~6.04 months -> rounds up to 7.
    final progress = GoalProgressCalculator.calculate(
      goal: goal(targetAmount: 1400, targetDate: DateTime(2026, 9, 15)),
      saved: 0,
      now: now,
    );

    expect(progress.monthlyAmountNeeded, 200);
  });

  test('zero target counts as completed without dividing by zero', () {
    final progress = GoalProgressCalculator.calculate(
      goal: goal(targetAmount: 0),
      saved: 0,
      now: now,
    );

    expect(progress.status, GoalStatus.completed);
    expect(progress.percentSaved, 1.0);
  });
}
