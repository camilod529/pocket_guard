/// Starting values for a *new* transaction, passed to the transaction form
/// route as `extra` (e.g. buying a wishlist item). The form applies them
/// through its normal change handlers, so validation runs as usual.
class TransactionPrefill {
  final double amount;
  final String? categoryId;
  final String? accountId;
  final String? description;

  const TransactionPrefill({
    required this.amount,
    this.categoryId,
    this.accountId,
    this.description,
  });
}
