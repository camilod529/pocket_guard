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
