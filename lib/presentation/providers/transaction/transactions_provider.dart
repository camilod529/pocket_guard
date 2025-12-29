import 'package:money_manager_flutter/domain/data_sources/transaction_data_source.dart';
import 'package:money_manager_flutter/domain/entities/transaction.dart';
import 'package:money_manager_flutter/domain/repositories/transaction_repository.dart';
import 'package:money_manager_flutter/infrastructure/data_sources/transaction_drift_data_source_impl.dart';
import 'package:money_manager_flutter/infrastructure/repositories/transaction_repository_impl.dart';
import 'package:money_manager_flutter/presentation/providers/account/account_provider.dart';
import 'package:money_manager_flutter/presentation/providers/selected_date_range_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transactions_provider.g.dart';

@Riverpod(keepAlive: true)
TransactionDataSource transactionDataSource(Ref ref) {
  return TransactionDriftDataSourceImpl();
}

@Riverpod(keepAlive: true)
TransactionRepository transactionRepository(Ref ref) {
  final dataSource = ref.watch(transactionDataSourceProvider);
  return TransactionRepositoryImpl(dataSource: dataSource);
}

@riverpod
class TransactionsNotifier extends _$TransactionsNotifier {
  @override
  Future<List<TransactionEntity>> build() async {
    // Watch the selected date range
    final dateRange = ref.watch(selectedDateRangeProvider);

    final repository = ref.read(transactionRepositoryProvider);
    return await repository.getAllTransactions(
      startDate: dateRange.start,
      endDate: dateRange.end,
    );
  }

  Future<void> createTransaction(TransactionEntity transaction) async {
    if (!ref.mounted) return;
    state = const AsyncLoading();
    try {
      final repository = ref.read(transactionRepositoryProvider);
      await repository.createTransaction(transaction);

      if (!ref.mounted) return;

      // Refresh the current date range
      ref.invalidateSelf();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteTransaction(String id) async {
    if (!ref.mounted) return;
    state = const AsyncLoading();
    try {
      final repository = ref.read(transactionRepositoryProvider);
      final transaction = await repository.getTransactionById(id);
      if (transaction == null) {
        throw Exception('Transaction not found');
      }
      await repository.deleteTransaction(id);

      if (!ref.mounted) return;

      // Refresh the current date range
      ref.invalidateSelf();

      ref
          .read(accountProvider(transaction.accountId).notifier)
          .refreshAccount();
      if (transaction.toAccountId != null) {
        ref
            .read(accountProvider(transaction.toAccountId!).notifier)
            .refreshAccount();
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    if (!ref.mounted) return;
    ref.invalidateSelf();
  }

  Future<List<TransactionEntity>> searchTransactions(String query) async {
    if (!ref.mounted) return [];
    final repository = ref.read(transactionRepositoryProvider);
    return await repository.searchTransactions(query);
  }

  Future<void> updateTransaction(
    String id,
    TransactionEntity transaction,
  ) async {
    if (!ref.mounted) return;
    state = const AsyncLoading();
    try {
      final repository = ref.read(transactionRepositoryProvider);
      await repository.updateTransaction(id, transaction);

      if (!ref.mounted) return;

      // Refresh the current date range
      ref.invalidateSelf();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
