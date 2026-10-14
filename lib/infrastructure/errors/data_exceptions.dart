/// Database constraint violations
class ConstraintViolation extends DataException {
  ConstraintViolation({String? message, super.originalError, super.stackTrace})
    : super(message: message ?? 'Database constraint violation');
}

class DatabaseClosedException extends DataException {
  DatabaseClosedException({super.originalError, super.stackTrace})
    : super(message: 'Database is closed');
}

/// Database operation errors
class DatabaseOperationException extends DataException {
  DatabaseOperationException({
    super.originalError,
    super.stackTrace,
    String? operation,
  }) : super(message: 'Database operation failed');
}

abstract class DataException implements Exception {
  final String message;
  final Object? originalError;
  final StackTrace? stackTrace;

  const DataException({
    required this.message,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => message;
}

/// Data not found errors
class DataNotFoundException extends DataException {
  DataNotFoundException({
    super.originalError,
    super.stackTrace,
    String? entityName,
  }) : super(message: 'Data not found');
}

class ForeignKeyViolation extends DataException {
  ForeignKeyViolation({
    super.originalError,
    super.stackTrace,
    String? referencedTable,
  }) : super(message: 'Foreign key constraint violation');
}

/// Storage-related errors
class StorageFullException extends DataException {
  StorageFullException({super.originalError, super.stackTrace})
    : super(message: 'Storage is full');
}

class UniqueConstraintViolation extends DataException {
  UniqueConstraintViolation({
    super.originalError,
    super.stackTrace,
    String? fieldName,
  }) : super(message: 'Unique constraint violation');
}

/// Generic/Unknown data errors
class UnknownDataException extends DataException {
  UnknownDataException({String? message, super.originalError, super.stackTrace})
    : super(message: message ?? 'An unexpected data error occurred');
}

enum SavingsGoalError {
  /// The account's currency doesn't match the goal's.
  currencyMismatch,

  /// Deposit is larger than the source account's balance.
  insufficientAccountBalance,

  /// Withdrawal (or an edit/delete) would leave the jar below zero.
  insufficientGoalBalance,

  /// The contribution's account was deleted, so its balance effect can't be
  /// reversed.
  accountMissing,

  /// Deleting a goal that still holds money needs an account to refund to.
  refundAccountRequired,

  zeroAmount,

  /// Changing a goal's currency once it has contributions.
  currencyLocked,
}

/// A savings goal rule was broken - nothing was written. [reason] says which.
class SavingsGoalValidationException extends DataException {
  final SavingsGoalError reason;

  SavingsGoalValidationException(this.reason)
    : super(message: 'Savings goal validation failed: ${reason.name}');
}
