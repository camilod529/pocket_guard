import 'package:drift/drift.dart';
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/domain/data_sources/transaction_data_source.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/domain/entities/transaction.dart';
import 'package:pocket_guard/domain/entities/transaction_filter.dart';
import 'package:pocket_guard/infrastructure/errors/data_exceptions.dart';
import 'package:pocket_guard/infrastructure/errors/drift_exception_handler.dart';

class TransactionDriftDataSourceImpl extends TransactionDataSource {
  final DriftExceptionHandler _exceptionHandler = DriftExceptionHandler();

  @override
  Future<void> createTransaction(TransactionEntity transaction) async {
    try {
      await database.transaction(() async {
        // Insert the transaction
        await database
            .into(database.transactions)
            .insert(
              TransactionsCompanion(
                amount: Value(transaction.amount),
                date: Value(transaction.date.millisecondsSinceEpoch),
                description: Value(transaction.description),
                accountId: Value(transaction.accountId),
                categoryId: Value(transaction.categoryId),
                toAccountId: Value(transaction.toAccountId),
              ),
            );

        // Get category to determine type
        final category = await (database.select(
          database.categories,
        )..where((tbl) => tbl.id.equals(transaction.categoryId))).getSingle();

        // Handle balance updates based on transaction type
        if (category.type == TransactionType.transfer) {
          // Transfer: subtract from source account, add to destination account
          if (transaction.toAccountId == null) {
            throw Exception('Transfer transaction requires toAccountId');
          }

          // Subtract from source account
          await database.customUpdate(
            'UPDATE accounts SET balance = balance - ? WHERE id = ?',
            updates: {database.accounts},
            variables: [
              Variable<double>(transaction.amount),
              Variable<String>(transaction.accountId),
            ],
          );

          // Add to destination account
          await database.customUpdate(
            'UPDATE accounts SET balance = balance + ? WHERE id = ?',
            updates: {database.accounts},
            variables: [
              Variable<double>(transaction.amount),
              Variable<String>(transaction.toAccountId!),
            ],
          );
        } else {
          // Income or Expense: update only the main account
          final adjustment = category.type == TransactionType.income
              ? transaction.amount
              : -transaction.amount;

          await database.customUpdate(
            'UPDATE accounts SET balance = balance + ? WHERE id = ?',
            updates: {database.accounts},
            variables: [
              Variable<double>(adjustment),
              Variable<String>(transaction.accountId),
            ],
          );
        }
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

        // Delete the transaction first
        await (database.delete(
          database.transactions,
        )..where((tbl) => tbl.id.equals(id))).go();

        // Reverse the balance effects
        if (category.type == TransactionType.transfer) {
          // Transfer: reverse the transfer
          if (transaction.toAccountId == null) {
            throw Exception('Transfer transaction missing toAccountId');
          }

          // Add back to source account
          await database.customUpdate(
            'UPDATE accounts SET balance = balance + ? WHERE id = ?',
            updates: {database.accounts},
            variables: [
              Variable<double>(transaction.amount),
              Variable<String>(transaction.accountId),
            ],
          );

          // Subtract from destination account
          await database.customUpdate(
            'UPDATE accounts SET balance = balance - ? WHERE id = ?',
            updates: {database.accounts},
            variables: [
              Variable<double>(transaction.amount),
              Variable<String>(transaction.toAccountId!),
            ],
          );
        } else {
          // Income or Expense: reverse the effect
          final reverseEffect = category.type == TransactionType.income
              ? -transaction.amount
              : transaction.amount;

          await database.customUpdate(
            'UPDATE accounts SET balance = balance + ? WHERE id = ?',
            updates: {database.accounts},
            variables: [
              Variable<double>(reverseEffect),
              Variable<String>(transaction.accountId),
            ],
          );
        }
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
    TransactionFilter? filter,
  }) async {
    try {
      final query = database.select(database.transactions);

      if (filter != null) {
        query.where((tbl) {
          final predicates = <Expression<bool>>[];

          if (filter.startDate != null) {
            predicates.add(
              tbl.date.isBiggerOrEqualValue(
                filter.startDate!.millisecondsSinceEpoch,
              ),
            );
          }
          if (filter.endDate != null) {
            predicates.add(
              tbl.date.isSmallerOrEqualValue(
                filter.endDate!.millisecondsSinceEpoch,
              ),
            );
          }
          if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
            predicates.add(tbl.description.like('%${filter.searchQuery}%'));
          }
          if (filter.categoryIds != null && filter.categoryIds!.isNotEmpty) {
            predicates.add(tbl.categoryId.isIn(filter.categoryIds!));
          }

          return predicates.isEmpty
              ? const Constant(true)
              : predicates.reduce((value, element) => value & element);
        });
      }

      // Always sort by date descending for better UX
      query.orderBy([
        (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
      ]);

      final transactions = await query.get();

      return transactions.map((transaction) {
        return TransactionEntity(
          id: transaction.id,
          amount: transaction.amount,
          date: DateTime.fromMillisecondsSinceEpoch(transaction.date),
          description: transaction.description,
          accountId: transaction.accountId,
          categoryId: transaction.categoryId,
          toAccountId: transaction.toAccountId,
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
        toAccountId: transaction.toAccountId,
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
          toAccountId: transaction.toAccountId,
        );
      }).toList();
    } catch (e, stackTrace) {
      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'search transactions',
        entityName: 'transaction',
      );
    }
  }

  @override
  Future<void> updateTransaction(
    String id,
    TransactionEntity updatedTransaction,
  ) async {
    // TODO: when updating a transaction that is a transfer,
    // and the change is that the accounts swapped,
    //need to handle both accounts, this has a bug
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

        // Update the transaction record
        await (database.update(
          database.transactions,
        )..where((tbl) => tbl.id.equals(id))).write(
          TransactionsCompanion(
            amount: Value(updatedTransaction.amount),
            date: Value(updatedTransaction.date.millisecondsSinceEpoch),
            description: Value(updatedTransaction.description),
            accountId: Value(updatedTransaction.accountId),
            categoryId: Value(updatedTransaction.categoryId),
            toAccountId: Value(updatedTransaction.toAccountId),
          ),
        );

        // Reverse old transaction effects
        await _reverseTransactionEffect(oldTransaction, oldCategory.type);

        // Apply new transaction effects
        await _applyTransactionEffect(updatedTransaction, newCategory.type);
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

  /// Apply the balance effect of a transaction
  Future<void> _applyTransactionEffect(
    TransactionEntity transaction,
    TransactionType type,
  ) async {
    if (type == TransactionType.transfer) {
      if (transaction.toAccountId == null) {
        throw Exception('Transfer transaction requires toAccountId');
      }

      // Subtract from source account
      await database.customUpdate(
        'UPDATE accounts SET balance = balance - ? WHERE id = ?',
        updates: {database.accounts},
        variables: [
          Variable<double>(transaction.amount),
          Variable<String>(transaction.accountId),
        ],
      );

      // Add to destination account
      await database.customUpdate(
        'UPDATE accounts SET balance = balance + ? WHERE id = ?',
        updates: {database.accounts},
        variables: [
          Variable<double>(transaction.amount),
          Variable<String>(transaction.toAccountId!),
        ],
      );
    } else {
      // Income or Expense
      final adjustment = type == TransactionType.income
          ? transaction.amount
          : -transaction.amount;

      await database.customUpdate(
        'UPDATE accounts SET balance = balance + ? WHERE id = ?',
        updates: {database.accounts},
        variables: [
          Variable<double>(adjustment),
          Variable<String>(transaction.accountId),
        ],
      );
    }
  }

  /// Reverse the balance effect of a transaction
  Future<void> _reverseTransactionEffect(
    TransactionEntity transaction,
    TransactionType type,
  ) async {
    if (type == TransactionType.transfer) {
      if (transaction.toAccountId == null) {
        throw Exception('Transfer transaction missing toAccountId');
      }

      // Add back to source account
      await database.customUpdate(
        'UPDATE accounts SET balance = balance + ? WHERE id = ?',
        updates: {database.accounts},
        variables: [
          Variable<double>(transaction.amount),
          Variable<String>(transaction.accountId),
        ],
      );

      // Subtract from destination account
      await database.customUpdate(
        'UPDATE accounts SET balance = balance - ? WHERE id = ?',
        updates: {database.accounts},
        variables: [
          Variable<double>(transaction.amount),
          Variable<String>(transaction.toAccountId!),
        ],
      );
    } else {
      // Income or Expense
      final reverseEffect = type == TransactionType.income
          ? -transaction.amount
          : transaction.amount;

      await database.customUpdate(
        'UPDATE accounts SET balance = balance + ? WHERE id = ?',
        updates: {database.accounts},
        variables: [
          Variable<double>(reverseEffect),
          Variable<String>(transaction.accountId),
        ],
      );
    }
  }
}
