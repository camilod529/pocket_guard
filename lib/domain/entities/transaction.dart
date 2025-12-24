class TransactionEntity {
  final String id;
  final String accountId;
  final double amount;
  final DateTime date;
  final String categoryId;
  final String? description;

  TransactionEntity({
    required this.id,
    required this.accountId,
    required this.amount,
    required this.date,
    required this.categoryId,
    this.description,
  });
}
