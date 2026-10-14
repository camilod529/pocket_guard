/// Sentinel for [WishlistItemEntity.copyWith] so nullable fields can be
/// explicitly cleared - same pattern as SavingsGoalEntity.
const _unset = Object();

class WishlistItemEntity {
  final String id;
  final String name;
  final double price;
  final String currency;
  final String? categoryId;
  final String? goalId;
  final DateTime? purchasedAt;
  final DateTime createdAt;

  WishlistItemEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    required this.categoryId,
    required this.goalId,
    required this.purchasedAt,
    required this.createdAt,
  });

  bool get isPurchased => purchasedAt != null;

  WishlistItemEntity copyWith({
    String? id,
    String? name,
    double? price,
    String? currency,
    Object? categoryId = _unset,
    Object? goalId = _unset,
    Object? purchasedAt = _unset,
    DateTime? createdAt,
  }) {
    return WishlistItemEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      categoryId: identical(categoryId, _unset)
          ? this.categoryId
          : categoryId as String?,
      goalId: identical(goalId, _unset) ? this.goalId : goalId as String?,
      purchasedAt: identical(purchasedAt, _unset)
          ? this.purchasedAt
          : purchasedAt as DateTime?,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
