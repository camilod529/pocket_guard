import 'package:drift/drift.dart';
import 'package:money_manager_flutter/config/database/database.dart';
import 'package:money_manager_flutter/domain/data_sources/transaction_data_source.dart';
import 'package:money_manager_flutter/domain/entities/category.dart';
import 'package:money_manager_flutter/domain/entities/transaction.dart';
import 'package:money_manager_flutter/infrastructure/errors/data_exceptions.dart';
import 'package:money_manager_flutter/infrastructure/errors/drift_exception_handler.dart';

class TransactionDriftDataSourceImpl extends TransactionDataSource {
  final DriftExceptionHandler _exceptionHandler = DriftExceptionHandler();

  @override
  Future<void> createTransaction(TransactionEntity transaction) async {
    try {
      await database.transaction(() async {
        await database
            .into(database.transactions)
            .insert(
              TransactionsCompanion(
                amount: Value(transaction.amount),
                date: Value(transaction.date.millisecondsSinceEpoch),
                description: Value(transaction.description),
                accountId: Value(transaction.accountId),
                categoryId: Value(transaction.categoryId),
              ),
            );

        final category = await (database.select(
          database.categories,
        )..where((tbl) => tbl.id.equals(transaction.categoryId))).getSingle();

        final adjustment = category.type == TransactionType.income
            ? transaction.amount
            : -transaction.amount;

        // TODO: Handle transfer type

        await database.customUpdate(
          'UPDATE accounts SET balance = balance + ? WHERE id = ?',
          updates: {database.accounts},
          variables: [
            Variable<double>(adjustment),
            Variable<String>(transaction.accountId),
          ],
        );
      });
    } catch (e, stackTrace) {
      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'create transaction',
        entityName: 'transaction',
      );
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      final transaction = await getTransactionById(id);
      if (transaction == null) {
        throw DataNotFoundException(entityName: 'transaction');
      }

      await database.transaction(() async {
        final category = await (database.select(
          database.categories,
        )..where((tbl) => tbl.id.equals(transaction.categoryId))).getSingle();

        final reverseEffect = category.type == TransactionType.income
            ? -transaction.amount
            : transaction.amount;

        // TODO: Handle transfer type

        await (database.delete(
          database.transactions,
        )..where((tbl) => tbl.id.equals(id))).go();

        await database.customUpdate(
          'UPDATE accounts SET balance = balance + ? WHERE id = ?',
          updates: {database.accounts},
          variables: [
            Variable<double>(reverseEffect),
            Variable<String>(transaction.accountId),
          ],
        );
      });
    } catch (e, stackTrace) {
      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'delete transaction',
        entityName: 'transaction',
      );
    }
  }

  @override
  Future<List<TransactionEntity>> getAllTransactions({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final query = database.select(database.transactions);

      if (startDate != null) {
        query.where(
          (tbl) =>
              tbl.date.isBiggerOrEqualValue(startDate.millisecondsSinceEpoch),
        );
      }

      if (endDate != null) {
        query.where(
          (tbl) =>
              tbl.date.isSmallerOrEqualValue(endDate.millisecondsSinceEpoch),
        );
      }

      final transactions = await query.get();

      return transactions.map((transaction) {
        return TransactionEntity(
          id: transaction.id,
          amount: transaction.amount,
          date: DateTime.fromMillisecondsSinceEpoch(transaction.date),
          description: transaction.description,
          accountId: transaction.accountId,
          categoryId: transaction.categoryId,
        );
      }).toList();
    } catch (e, stackTrace) {
      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'get all transactions',
        entityName: 'transaction',
      );
    }
  }

  @override
  Future<TransactionEntity?> getTransactionById(String id) async {
    try {
      final transaction = await (database.select(
        database.transactions,
      )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

      if (transaction == null) return null;

      return TransactionEntity(
        id: transaction.id,
        amount: transaction.amount,
        date: DateTime.fromMillisecondsSinceEpoch(transaction.date),
        description: transaction.description,
        accountId: transaction.accountId,
        categoryId: transaction.categoryId,
      );
    } catch (e, stackTrace) {
      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'get transaction',
        entityName: 'transaction',
      );
    }
  }

  @override
  Future<List<TransactionEntity>> searchTransactions(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getAllTransactions();
      }

      final transactions = await (database.select(
        database.transactions,
      )..where((tbl) => tbl.description.like('%$query%'))).get();

      return transactions.map((transaction) {
        return TransactionEntity(
          id: transaction.id,
          amount: transaction.amount,
          date: DateTime.fromMillisecondsSinceEpoch(transaction.date),
          description: transaction.description,
          accountId: transaction.accountId,
          categoryId: transaction.categoryId,
        );
      }).toList();
    } catch (e, stackTrace) {
      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'search accounts',
        entityName: 'account',
      );
    }
  }

  @override
  Future<void> updateTransaction(
    String id,
    TransactionEntity updatedTransaction,
  ) async {
    try {
      final oldTransaction = await getTransactionById(id);
      if (oldTransaction == null) {
        throw DataNotFoundException(entityName: 'transaction');
      }

      await database.transaction(() async {
        final oldCategory =
            await (database.select(database.categories)
                  ..where((tbl) => tbl.id.equals(oldTransaction.categoryId)))
                .getSingle();
        final newCategory =
            await (database.select(
                  database.categories,
                )..where((tbl) => tbl.id.equals(updatedTransaction.categoryId)))
                .getSingle();

        final oldEffect = oldCategory.type == TransactionType.income
            ? oldTransaction.amount
            : -oldTransaction.amount;
        final newEffect = newCategory.type == TransactionType.income
            ? updatedTransaction.amount
            : -updatedTransaction.amount;

        // TODO: Handle transfer type

        await (database.update(
          database.transactions,
        )..where((tbl) => tbl.id.equals(id))).write(
          TransactionsCompanion(
            amount: Value(updatedTransaction.amount),
            date: Value(updatedTransaction.date.millisecondsSinceEpoch),
            description: Value(updatedTransaction.description),
            accountId: Value(updatedTransaction.accountId),
            categoryId: Value(updatedTransaction.categoryId),
          ),
        );

        if (updatedTransaction.accountId != oldTransaction.accountId) {
          // TODO: Handle transfer type for both accounts

          await database.customUpdate(
            'UPDATE accounts SET balance = balance + ? WHERE id = ?',
            updates: {database.accounts},
            variables: [
              Variable<double>(-oldEffect),
              Variable<String>(oldTransaction.accountId),
            ],
          );

          await database.customUpdate(
            'UPDATE accounts SET balance = balance + ? WHERE id = ?',
            updates: {database.accounts},
            variables: [
              Variable<double>(newEffect),
              Variable<String>(updatedTransaction.accountId),
            ],
          );
        } else {
          // Same account: apply net change atomically
          final netChange = newEffect - oldEffect;

          await database.customUpdate(
            'UPDATE accounts SET balance = balance + ? WHERE id = ?',
            updates: {database.accounts},
            variables: [
              Variable<double>(netChange),
              Variable<String>(updatedTransaction.accountId),
            ],
          );
        }
      });
    } catch (e, stackTrace) {
      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'update transaction',
        entityName: 'transaction',
      );
    }
  }
}
