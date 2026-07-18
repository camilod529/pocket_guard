import 'package:pocket_guard/domain/entities/recurring_transaction.dart';

abstract class RecurringTransactionDataSource {
  Future<void> createRecurringTransaction(RecurringTransactionEntity rule);
  Future<void> deleteRecurringTransaction(String id);
  Future<RecurringTransactionEntity?> getRecurringTransactionById(String id);
  Future<List<RecurringTransactionEntity>> getAllRecurringTransactions();
  Future<void> updateRecurringTransaction(
    String id,
    RecurringTransactionEntity rule,
  );
}
