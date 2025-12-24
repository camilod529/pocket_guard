import 'package:drift/drift.dart';
import 'package:money_manager_flutter/infrastructure/errors/data_exceptions.dart';
import 'package:sqlite3/sqlite3.dart';

class DriftExceptionHandler {
  /// Centralized Drift exception handling
  DataException handleDriftException(
    Object error,
    StackTrace stackTrace, {
    String? operation,
    String? entityName,
    String? fieldName,
  }) {
    // Handle Drift-specific exceptions
    if (error is DriftWrappedException) {
      final underlying =
          error.cause; // Fixed: use 'cause' not 'exception' [web:1]

      // Check for SQLite specific errors
      if (underlying is SqliteException) {
        // Fixed: use SqliteException [web:44]
        return _handleSqliteException(
          underlying,
          stackTrace,
          originalError: error,
          operation: operation,
          entityName: entityName,
          fieldName: fieldName,
        );
      }

      // Check error message for constraints
      final errorMessage = underlying?.toString().toLowerCase() ?? '';
      return _handleErrorMessage(
        errorMessage,
        stackTrace,
        originalError: error,
        operation: operation,
        entityName: entityName,
        fieldName: fieldName,
      );
    }

    // Handle generic exceptions - Fixed: use SqliteException directly
    if (error is SqliteException) {
      return _handleSqliteException(
        error,
        stackTrace,
        operation: operation,
        entityName: entityName,
        fieldName: fieldName,
      );
    }

    // Default to unknown error
    return UnknownDataException(
      originalError: error,
      stackTrace: stackTrace,
      message: error.toString(),
    );
  }

  String? _extractConstraintMessage(String errorMessage) {
    if (errorMessage.contains('not null')) {
      return 'error_not_null_constraint';
    }
    if (errorMessage.contains('check constraint')) {
      return 'error_check_constraint';
    }
    return null;
  }

  String? _extractFieldName(String errorMessage) {
    final patterns = [
      // captures "column foo", "column named foo", "no such column: foo", or quoted variations
      RegExp(
        r'''(?:column(?: named)?|no such column:)\s*['"`\[]?([A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*)?)['"`\]]?''',
        caseSensitive: false,
      ),
      // captures cases like "UNIQUE constraint failed: users.email"
      RegExp(
        r'''UNIQUE constraint failed:\s*([A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*)?)''',
        caseSensitive: false,
      ),
      // fallback: any token after the word "column"
      RegExp(r'''column\s+([A-Za-z0-9_.-]+)''', caseSensitive: false),
    ];

    for (final regex in patterns) {
      final match = regex.firstMatch(errorMessage);
      if (match != null && match.groupCount >= 1) {
        final name = match.group(1);
        if (name == null) continue;
        // If we captured table.column, return only the column part
        if (name.contains('.')) return name.split('.').last;
        return name;
      }
    }
    return null;
  }

  String? _extractReferencedTable(String errorMessage) {
    final patterns = [
      // captures "table foo", "no such table: foo", or quoted variations
      RegExp(
        r'''(?:table|no such table:)\s*['"`\[]?([A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*)?)['"`\]]?''',
        caseSensitive: false,
      ),
      // captures "UNIQUE constraint failed: users.email" -> returns 'users'
      RegExp(
        r'''UNIQUE constraint failed:\s*([A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*)?)''',
        caseSensitive: false,
      ),
      // fallback: any token after the word "table"
      RegExp(r'''table\s+([A-Za-z0-9_.-]+)''', caseSensitive: false),
    ];

    for (final regex in patterns) {
      final match = regex.firstMatch(errorMessage);
      if (match != null && match.groupCount >= 1) {
        final name = match.group(1);
        if (name == null) continue;
        // If we captured schema.table or table.column, return the first segment (the table)
        if (name.contains('.')) return name.split('.').first;
        return name;
      }
    }
    return null;
  }

  // Rest of the methods unchanged - they don't have compilation errors
  DataException _handleErrorMessage(
    String errorMessage,
    StackTrace stackTrace, {
    Object? originalError,
    String? operation,
    String? entityName,
    String? fieldName,
  }) {
    if (errorMessage.contains('unique constraint') ||
        errorMessage.contains('duplicate') ||
        errorMessage.contains('unique')) {
      return UniqueConstraintViolation(
        originalError: originalError,
        stackTrace: stackTrace,
        fieldName: fieldName ?? _extractFieldName(errorMessage),
      );
    }

    if (errorMessage.contains('foreign key') ||
        errorMessage.contains('constraint failed')) {
      return ForeignKeyViolation(
        originalError: originalError,
        stackTrace: stackTrace,
        referencedTable: _extractReferencedTable(errorMessage),
      );
    }

    if (errorMessage.contains('database is closed')) {
      return DatabaseClosedException(
        originalError: originalError,
        stackTrace: stackTrace,
      );
    }

    if (errorMessage.contains('disk i/o error') ||
        errorMessage.contains('full') ||
        errorMessage.contains('no space')) {
      return StorageFullException(
        originalError: originalError,
        stackTrace: stackTrace,
      );
    }

    return DatabaseOperationException(
      originalError: originalError,
      stackTrace: stackTrace,
      operation: operation,
    );
  }

  DataException _handleSqliteException(
    SqliteException exception, // Fixed: SqliteException type
    StackTrace stackTrace, {
    Object? originalError,
    String? operation,
    String? entityName,
    String? fieldName,
  }) {
    final message = exception.message.toLowerCase();
    final extendedCode =
        exception.extendedResultCode; // Fixed: proper property access
    final code = extendedCode;

    // SQLite error codes

    switch (code) {
      case 2067: // SQLITE_CONSTRAINT_UNIQUE
        return UniqueConstraintViolation(
          originalError: originalError ?? exception,
          stackTrace: stackTrace,
          fieldName: fieldName,
        );
      case 787: // SQLITE_CONSTRAINT_FOREIGNKEY
        return ForeignKeyViolation(
          originalError: originalError ?? exception,
          stackTrace: stackTrace,
          referencedTable: _extractReferencedTable(message),
        );
      case 1299: // SQLITE_CONSTRAINT_NOTNULL
      case 19: // SQLITE_CONSTRAINT (general)
        return ConstraintViolation(
          originalError: originalError ?? exception,
          stackTrace: stackTrace,
          userMessage: _extractConstraintMessage(message),
        );
      case 5: // SQLITE_BUSY
        return DatabaseOperationException(
          originalError: originalError ?? exception,
          stackTrace: stackTrace,
          operation: operation ?? 'database operation',
        );
    }

    // Fallback to message parsing
    return _handleErrorMessage(
      message,
      stackTrace,
      originalError: originalError ?? exception,
      operation: operation,
      entityName: entityName,
      fieldName: fieldName,
    );
  }
}
