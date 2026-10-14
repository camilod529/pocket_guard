/// Sentinel for [SavingsGoalEntity.copyWith] so nullable [targetDate] can be
/// explicitly cleared - same pattern as the form states.
const _unset = Object();

class SavingsGoalEntity {
  final String id;
  final String name;
  final double targetAmount;
  final String currency;
  final DateTime? targetDate;
  final bool isArchived;
  final DateTime createdAt;

  SavingsGoalEntity({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currency,
    required this.targetDate,
    required this.isArchived,
    required this.createdAt,
  });

  SavingsGoalEntity copyWith({
    String? id,
    String? name,
    double? targetAmount,
    String? currency,
    Object? targetDate = _unset,
    bool? isArchived,
    DateTime? createdAt,
  }) {
    return SavingsGoalEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currency: currency ?? this.currency,
      targetDate: identical(targetDate, _unset)
          ? this.targetDate
          : targetDate as DateTime?,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
