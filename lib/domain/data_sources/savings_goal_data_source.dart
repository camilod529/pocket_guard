import 'package:pocket_guard/domain/entities/goal_contribution.dart';
import 'package:pocket_guard/domain/entities/savings_goal.dart';

abstract class SavingsGoalDataSource {
  Future<void> addContribution(GoalContributionEntity contribution);
  Future<void> createGoal(SavingsGoalEntity goal);
  Future<void> deleteContribution(String id);

  /// [refundAccountId] receives whatever is still saved in the jar; it's
  /// required whenever the saved amount isn't zero.
  Future<void> deleteGoal(String id, {String? refundAccountId});
  Future<List<SavingsGoalEntity>> getAllGoals();
  Future<List<GoalContributionEntity>> getContributionsForGoal(String goalId);
  Future<SavingsGoalEntity?> getGoalById(String id);

  /// Saved amount per goal id. Goals with no contributions are absent.
  Future<Map<String, double>> getSavedAmounts();
  Future<void> updateContribution(
    String id,
    GoalContributionEntity contribution,
  );
  Future<void> updateGoal(String id, SavingsGoalEntity goal);
}
