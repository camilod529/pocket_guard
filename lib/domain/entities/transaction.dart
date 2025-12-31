class TransactionEntity {
  final String id;
  final String accountId;
  final double amount;
  final DateTime date;
  final String categoryId;
  final String? description;
  final String? toAccountId;

  TransactionEntity({
    required this.id,
    required this.accountId,
    required this.amount,
    required this.date,
    required this.categoryId,
    this.description,
    this.toAccountId,
  });

  @override
  String toString() {
    return 'TransactionEntity{id: $id, accountId: $accountId, amount: $amount, date: $date, categoryId: $categoryId, description: $description, toAccountId: $toAccountId}';
  }
}
