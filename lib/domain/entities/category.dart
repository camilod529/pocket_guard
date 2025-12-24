class CategoryEntity {
  final String id;
  final String label;
  final bool isSystem;
  final TransactionType type;

  CategoryEntity({
    required this.id,
    required this.label,
    required this.isSystem,
    required this.type,
  });
}

enum TransactionType { income, expense, transfer }
