import 'package:pocket_guard/domain/data_sources/transaction_data_source.dart';
import 'package:pocket_guard/domain/entities/transaction.dart';
import 'package:pocket_guard/domain/repositories/transaction_repository.dart';
import 'package:pocket_guard/infrastructure/data_sources/transaction_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/repositories/transaction_repository_impl.dart';
import 'package:pocket_guard/presentation/providers/account/account_provider.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/providers/transaction/transaction_filter_provider.dart';
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
    final filter = ref.watch(transactionSearchFilterProvider);

    final repository = ref.read(transactionRepositoryProvider);
    return await repository.getAllTransactions(filter: filter);
  }

  Future<void> createTransaction(TransactionEntity transaction) =>
      _mutate((repository) => repository.createTransaction(transaction));

  Future<void> deleteTransaction(String id) async {
    final transaction = await ref
        .read(transactionRepositoryProvider)
        .getTransactionById(id);
    if (transaction == null) {
      throw Exception('Transaction not found');
    }
    await _mutate((repository) => repository.deleteTransaction(id));
    if (!ref.mounted) return;

    ref.read(accountProvider(transaction.accountId).notifier).refreshAccount();
    if (transaction.toAccountId != null) {
      ref
          .read(accountProvider(transaction.toAccountId!).notifier)
          .refreshAccount();
    }
    ref.invalidate(accountsProvider);
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

  Future<void> updateTransaction(String id, TransactionEntity transaction) =>
      _mutate((repository) => repository.updateTransaction(id, transaction));

  /// Same error contract as BudgetsNotifier: on failure, revert to the
  /// previous state and rethrow rather than setting `AsyncValue.error` -
  /// that swallowed failures (the form reported an unsaved transaction as
  /// saved) and replaced the calendar's list with an error screen. On
  /// success, re-run build() for the current date range.
  Future<void> _mutate(
    Future<void> Function(TransactionRepository repository) action,
  ) async {
    if (!ref.mounted) return;
    final previousState = state;
    state = const AsyncLoading();
    try {
      await action(ref.read(transactionRepositoryProvider));
      if (!ref.mounted) return;
      ref.invalidateSelf();
    } catch (e) {
      if (ref.mounted) state = previousState;
      rethrow;
    }
  }
}
