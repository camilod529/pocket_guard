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
        // Insert transaction
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

        // Get category type using a simpler query
        final category =
            await (database.select(database.categories)
                  ..where((tbl) => tbl.id.equals(transaction.categoryId)))
                .getSingle(); // Will throw if not found

        // Calculate adjustment
        final adjustment = category.type == TransactionType.income
            ? transaction.amount
            : -transaction.amount;

        // Update balance using UPDATE with arithmetic
        await database.customUpdate(
          'UPDATE accounts SET balance = balance + ? WHERE id = ?',
          updates: {database.accounts},
          variables: [
            Variable<double>(adjustment),
            Variable<String>(transaction.accountId),
          ],
        );

        print('Transaction created, balance adjusted by: $adjustment');
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
        // Get category type
        final category =
            await (database.select(database.categories)
                  ..where((tbl) => tbl.id.equals(transaction.categoryId)))
                .getSingleOrNull();

        if (category == null) {
          throw DataNotFoundException(entityName: 'category');
        }

        // Reverse the effect (income becomes negative, expense becomes positive)
        final reverseEffect = category.type == TransactionType.income
            ? -transaction.amount
            : transaction.amount;

        // Get current account balance
        final currentAccount =
            await (database.select(database.accounts)
                  ..where((tbl) => tbl.id.equals(transaction.accountId)))
                .getSingleOrNull();

        if (currentAccount == null) {
          throw DataNotFoundException(entityName: 'account');
        }

        final newBalance = currentAccount.balance + reverseEffect;

        // TODO: Handle transfer type (reverse split between accounts)

        // Delete transaction
        await (database.delete(
          database.transactions,
        )..where((tbl) => tbl.id.equals(id))).go();

        // Apply reversal to balance
        await (database.update(database.accounts)
              ..where((tbl) => tbl.id.equals(transaction.accountId)))
            .write(AccountsCompanion(balance: Value(newBalance)));
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
        // Get old and new category types
        final oldCategory =
            await (database.select(database.categories)
                  ..where((tbl) => tbl.id.equals(oldTransaction.categoryId)))
                .getSingleOrNull();
        final newCategory =
            await (database.select(
                  database.categories,
                )..where((tbl) => tbl.id.equals(updatedTransaction.categoryId)))
                .getSingleOrNull();

        if (oldCategory == null || newCategory == null) {
          throw DataNotFoundException(entityName: 'category');
        }

        // Calculate old effect reversal and new effect
        final oldEffect = oldCategory.type == TransactionType.income
            ? oldTransaction.amount
            : -oldTransaction.amount;
        final newEffect = newCategory.type == TransactionType.income
            ? updatedTransaction.amount
            : -updatedTransaction.amount;

        final netChange = newEffect - oldEffect;

        // Update transaction
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
          // Account changed: fully reverse old, apply new
          // TODO: Handle transfer type for both accounts

          // Get current balances for both accounts
          final oldAccount =
              await (database.select(database.accounts)
                    ..where((tbl) => tbl.id.equals(oldTransaction.accountId)))
                  .getSingleOrNull();
          final newAccount =
              await (database.select(database.accounts)..where(
                    (tbl) => tbl.id.equals(updatedTransaction.accountId),
                  ))
                  .getSingleOrNull();

          if (oldAccount == null || newAccount == null) {
            throw DataNotFoundException(entityName: 'account');
          }

          // Update old account (reverse effect)
          await (database.update(
            database.accounts,
          )..where((tbl) => tbl.id.equals(oldTransaction.accountId))).write(
            AccountsCompanion(balance: Value(oldAccount.balance - oldEffect)),
          );

          // Update new account (apply effect)
          await (database.update(
            database.accounts,
          )..where((tbl) => tbl.id.equals(updatedTransaction.accountId))).write(
            AccountsCompanion(balance: Value(newAccount.balance + newEffect)),
          );
        } else {
          // Same account: apply net change
          final currentAccount =
              await (database.select(database.accounts)..where(
                    (tbl) => tbl.id.equals(updatedTransaction.accountId),
                  ))
                  .getSingleOrNull();

          if (currentAccount == null) {
            throw DataNotFoundException(entityName: 'account');
          }

          await (database.update(
            database.accounts,
          )..where((tbl) => tbl.id.equals(updatedTransaction.accountId))).write(
            AccountsCompanion(
              balance: Value(currentAccount.balance + netChange),
            ),
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
