class TransactionFilter {
  final String? searchQuery;
  final List<String>? categoryIds;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minAmount;
  final double? maxAmount;

  TransactionFilter({
    this.searchQuery,
    this.categoryIds,
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
  });

  bool get isEmpty =>
      (searchQuery?.isEmpty ?? true) &&
      (categoryIds?.isEmpty ?? true) &&
      startDate == null &&
      endDate == null &&
      minAmount == null &&
      maxAmount == null;
}
