import 'package:money_manager_flutter/domain/entities/transaction.dart';

abstract class TransactionDataSource {
  Future<void> createTransaction(TransactionEntity transaction);
  Future<void> deleteTransaction(String id);
  Future<List<TransactionEntity>> getAllTransactions({
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<TransactionEntity?> getTransactionById(String id);
  Future<List<TransactionEntity>> searchTransactions(String query);
  Future<void> updateTransaction(String id, TransactionEntity transaction);
}
