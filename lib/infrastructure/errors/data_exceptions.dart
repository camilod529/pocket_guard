import 'package:money_manager_flutter/infrastructure/errors/user_message_key.dart';

/// Database constraint violations
class ConstraintViolation extends DataException {
  ConstraintViolation({
    String? message,
    String? userMessage,
    super.originalError,
    super.stackTrace,
  }) : super(
         message: message ?? 'Database constraint violation',
         userMessage: userMessage != null
             ? UserMessageKey(userMessage)
             : const UserMessageKey('error_db_constraint_violation'),
       );
}

class DatabaseClosedException extends DataException {
  DatabaseClosedException({super.originalError, super.stackTrace})
    : super(
        message: 'Database is closed',
        userMessage: const UserMessageKey('error_db_closed'),
      );
}

/// Database operation errors
class DatabaseOperationException extends DataException {
  DatabaseOperationException({
    super.originalError,
    super.stackTrace,
    String? operation,
  }) : super(
         message: 'Database operation failed',
         userMessage: operation != null
             ? UserMessageKey(
                 'error_db_operation_failed_operation',
                 args: {'operation': operation},
               )
             : const UserMessageKey('error_db_operation_failed'),
       );
}

abstract class DataException implements Exception {
  final String message;
  final UserMessageKey userMessage;
  final Object? originalError;
  final StackTrace? stackTrace;

  const DataException({
    required this.message,
    required this.userMessage,
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
  }) : super(
         message: 'Data not found',
         userMessage: entityName != null
             ? UserMessageKey(
                 'error_data_not_found_entity',
                 args: {'entity': entityName},
               )
             : const UserMessageKey('error_data_not_found'),
       );
}

class ForeignKeyViolation extends DataException {
  ForeignKeyViolation({
    super.originalError,
    super.stackTrace,
    String? referencedTable,
  }) : super(
         message: 'Foreign key constraint violation',
         userMessage: referencedTable != null
             ? UserMessageKey(
                 'error_foreign_key_violation_table',
                 args: {'table': referencedTable},
               )
             : const UserMessageKey('error_foreign_key_violation'),
       );
}

/// Storage-related errors
class StorageFullException extends DataException {
  StorageFullException({super.originalError, super.stackTrace})
    : super(
        message: 'Storage is full',
        userMessage: const UserMessageKey('error_storage_full'),
      );
}

class UniqueConstraintViolation extends DataException {
  UniqueConstraintViolation({
    super.originalError,
    super.stackTrace,
    String? fieldName,
  }) : super(
         message: 'Unique constraint violation',
         userMessage: fieldName != null
             ? UserMessageKey(
                 'error_unique_constraint_violation_field',
                 args: {'field': fieldName},
               )
             : const UserMessageKey('error_unique_constraint_violation'),
       );
}

/// Generic/Unknown data errors
class UnknownDataException extends DataException {
  UnknownDataException({String? message, super.originalError, super.stackTrace})
    : super(
        message: message ?? 'An unexpected data error occurred',
        userMessage: const UserMessageKey('error_unknown_data'),
      );
}
