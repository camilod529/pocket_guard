// Append-only: Drift's intEnum() maps by index, so inserting or reordering
// values here would silently corrupt existing rows' frequency on next read.
enum RecurrenceFrequency { weekly, monthly, yearly, daily }

class RecurringTransactionEntity {
  final String id;
  final String accountId;
  final String? toAccountId;
  final String categoryId;
  final double amount;
  final String description;
  final RecurrenceFrequency frequency;
  final DateTime startDate;
  final DateTime nextDueDate;
  final DateTime? lastGeneratedDate;
  final DateTime? endDate;
  final bool isActive;

  RecurringTransactionEntity({
    required this.id,
    required this.accountId,
    this.toAccountId,
    required this.categoryId,
    required this.amount,
    required this.description,
    required this.frequency,
    required this.startDate,
    required this.nextDueDate,
    this.lastGeneratedDate,
    this.endDate,
    required this.isActive,
  });

  RecurringTransactionEntity copyWith({
    String? id,
    String? accountId,
    Object? toAccountId = _unset,
    String? categoryId,
    double? amount,
    String? description,
    RecurrenceFrequency? frequency,
    DateTime? startDate,
    DateTime? nextDueDate,
    Object? lastGeneratedDate = _unset,
    Object? endDate = _unset,
    bool? isActive,
  }) {
    return RecurringTransactionEntity(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      toAccountId: identical(toAccountId, _unset)
          ? this.toAccountId
          : toAccountId as String?,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      lastGeneratedDate: identical(lastGeneratedDate, _unset)
          ? this.lastGeneratedDate
          : lastGeneratedDate as DateTime?,
      endDate: identical(endDate, _unset) ? this.endDate : endDate as DateTime?,
      isActive: isActive ?? this.isActive,
    );
  }
}

const _unset = Object();
