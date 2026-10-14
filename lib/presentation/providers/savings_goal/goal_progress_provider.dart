import 'package:pocket_guard/domain/entities/goal_contribution.dart';
import 'package:pocket_guard/domain/services/goal_progress_calculator.dart';
import 'package:pocket_guard/presentation/providers/savings_goal/savings_goals_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'goal_progress_provider.g.dart';

/// Every goal paired with its saved amount (SUM of its contributions,
/// computed at read time - never stored). Recomputes whenever
/// savingsGoalsProvider re-emits, which every goal or contribution write
/// does.
@riverpod
Future<List<GoalProgress>> goalProgress(Ref ref) async {
  final goals = await ref.watch(savingsGoalsProvider.future);
  final repository = ref.watch(savingsGoalRepositoryProvider);
  final savedByGoal = await repository.getSavedAmounts();
  final now = DateTime.now();

  return [
    for (final goal in goals)
      GoalProgressCalculator.calculate(
        goal: goal,
        saved: savedByGoal[goal.id] ?? 0,
        now: now,
      ),
  ];
}

/// Newest first.
@riverpod
Future<List<GoalContributionEntity>> goalContributions(
  Ref ref,
  String goalId,
) async {
  // Result discarded - watched only so this refetches after any write.
  await ref.watch(savingsGoalsProvider.future);
  final repository = ref.watch(savingsGoalRepositoryProvider);
  return repository.getContributionsForGoal(goalId);
}
