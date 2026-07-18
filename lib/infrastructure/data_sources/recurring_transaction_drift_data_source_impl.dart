import 'package:drift/drift.dart';
import 'package:pocket_guard/config/database/database.dart' as db;
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/domain/data_sources/recurring_transaction_data_source.dart';
import 'package:pocket_guard/domain/entities/recurring_transaction.dart';
import 'package:pocket_guard/infrastructure/errors/data_exceptions.dart';
import 'package:pocket_guard/infrastructure/errors/drift_exception_handler.dart';

class RecurringTransactionDriftDataSourceImpl
    extends RecurringTransactionDataSource {
  RecurringTransactionDriftDataSourceImpl({AppDatabase? database})
    : database = database ?? db.database;

  final AppDatabase database;
  final DriftExceptionHandler _exceptionHandler = DriftExceptionHandler();

  @override
  Future<void> createRecurringTransaction(
    RecurringTransactionEntity rule,
  ) async {
    try {
      await database
          .into(database.recurringTransactions)
          .insert(_toCompanion(rule));
    } catch (e, stackTrace) {
      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'create recurring transaction',
        entityName: 'recurring transaction',
      );
    }
  }

  @override
  Future<void> deleteRecurringTransaction(String id) async {
    try {
      final deleted = await (database.delete(
        database.recurringTransactions,
      )..where((tbl) => tbl.id.equals(id))).go();

      if (deleted == 0) {
        throw DataNotFoundException(entityName: 'recurring transaction');
      }
    } catch (e, stackTrace) {
      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'delete recurring transaction',
        entityName: 'recurring transaction',
      );
    }
  }

  @override
  Future<List<RecurringTransactionEntity>> getAllRecurringTransactions() async {
    try {
      final rows = await database.select(database.recurringTransactions).get();
      return rows.map(_toEntity).toList();
    } catch (e, stackTrace) {
      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'get all recurring transactions',
        entityName: 'recurring transaction',
      );
    }
  }

  @override
  Future<RecurringTransactionEntity?> getRecurringTransactionById(
    String id,
  ) async {
    try {
      final row = await (database.select(
        database.recurringTransactions,
      )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

      if (row == null) return null;
      return _toEntity(row);
    } catch (e, stackTrace) {
      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'get recurring transaction',
        entityName: 'recurring transaction',
      );
    }
  }

  @override
  Future<void> updateRecurringTransaction(
    String id,
    RecurringTransactionEntity rule,
  ) async {
    try {
      final updated =
          await (database.update(
            database.recurringTransactions,
          )..where((tbl) => tbl.id.equals(id))).write(_toCompanion(rule));

      if (updated == 0) {
        throw DataNotFoundException(entityName: 'recurring transaction');
      }
    } catch (e, stackTrace) {
      if (e is DataException) rethrow;

      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'update recurring transaction',
        entityName: 'recurring transaction',
      );
    }
  }

  RecurringTransactionsCompanion _toCompanion(
    RecurringTransactionEntity rule,
  ) {
    return RecurringTransactionsCompanion(
      accountId: Value(rule.accountId),
      toAccountId: Value(rule.toAccountId),
      categoryId: Value(rule.categoryId),
      amount: Value(rule.amount),
      description: Value(rule.description),
      frequency: Value(rule.frequency),
      startDate: Value(rule.startDate),
      nextDueDate: Value(rule.nextDueDate),
      lastGeneratedDate: Value(rule.lastGeneratedDate),
      endDate: Value(rule.endDate),
      isActive: Value(rule.isActive),
    );
  }

  RecurringTransactionEntity _toEntity(RecurringTransaction row) {
    return RecurringTransactionEntity(
      id: row.id,
      accountId: row.accountId,
      toAccountId: row.toAccountId,
      categoryId: row.categoryId,
      amount: row.amount,
      description: row.description,
      frequency: row.frequency,
      startDate: row.startDate,
      nextDueDate: row.nextDueDate,
      lastGeneratedDate: row.lastGeneratedDate,
      endDate: row.endDate,
      isActive: row.isActive,
    );
  }
}
