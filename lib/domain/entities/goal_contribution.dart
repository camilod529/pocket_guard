class GoalContributionEntity {
  final String id;
  final String goalId;

  /// Null only when the source account has since been deleted (see
  /// GoalContributions.accountId in database.dart).
  final String? accountId;

  /// Signed: positive = deposit into the jar, negative = withdrawal.
  final double amount;
  final DateTime date;
  final String? note;

  GoalContributionEntity({
    required this.id,
    required this.goalId,
    required this.accountId,
    required this.amount,
    required this.date,
    this.note,
  });

  bool get isWithdrawal => amount < 0;
}
