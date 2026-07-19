class BudgetEntity {
  final String id;
  final String categoryId;
  final double monthlyLimit;
  final String currency;
  final bool isActive;

  BudgetEntity({
    required this.id,
    required this.categoryId,
    required this.monthlyLimit,
    required this.currency,
    required this.isActive,
  });

  BudgetEntity copyWith({
    String? id,
    String? categoryId,
    double? monthlyLimit,
    String? currency,
    bool? isActive,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      currency: currency ?? this.currency,
      isActive: isActive ?? this.isActive,
    );
  }
}
