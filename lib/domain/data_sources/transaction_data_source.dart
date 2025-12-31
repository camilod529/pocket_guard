import 'package:pocket_guard/domain/entities/transaction.dart';
import 'package:pocket_guard/domain/entities/transaction_filter.dart';

abstract class TransactionDataSource {
  Future<void> createTransaction(TransactionEntity transaction);
  Future<void> deleteTransaction(String id);
  Future<List<TransactionEntity>> getAllTransactions({
    TransactionFilter? filter,
  });
  Future<TransactionEntity?> getTransactionById(String id);
  Future<List<TransactionEntity>> searchTransactions(String query);
  Future<void> updateTransaction(String id, TransactionEntity transaction);
}
