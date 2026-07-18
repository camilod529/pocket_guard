import 'package:pocket_guard/domain/data_sources/recurring_transaction_data_source.dart';
import 'package:pocket_guard/domain/entities/recurring_transaction.dart';
import 'package:pocket_guard/domain/repositories/recurring_transaction_repository.dart';
import 'package:pocket_guard/infrastructure/data_sources/recurring_transaction_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/repositories/recurring_transaction_repository_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recurring_transactions_provider.g.dart';

@Riverpod(keepAlive: true)
RecurringTransactionDataSource recurringTransactionDataSource(Ref ref) {
  return RecurringTransactionDriftDataSourceImpl();
}

@Riverpod(keepAlive: true)
RecurringTransactionRepository recurringTransactionRepository(Ref ref) {
  final dataSource = ref.watch(recurringTransactionDataSourceProvider);
  return RecurringTransactionRepositoryImpl(dataSource: dataSource);
}

@riverpod
class RecurringTransactionsNotifier extends _$RecurringTransactionsNotifier {
  @override
  Future<List<RecurringTransactionEntity>> build() async {
    final repository = ref.read(recurringTransactionRepositoryProvider);
    return repository.getAllRecurringTransactions();
  }

  Future<void> createRecurringTransaction(
    RecurringTransactionEntity rule,
  ) async {
    if (!ref.mounted) return;
    state = const AsyncLoading();
    try {
      final repository = ref.read(recurringTransactionRepositoryProvider);
      await repository.createRecurringTransaction(rule);
      if (!ref.mounted) return;
      state = AsyncValue.data(await repository.getAllRecurringTransactions());
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteRecurringTransaction(String id) async {
    if (!ref.mounted) return;
    state = const AsyncLoading();
    try {
      final repository = ref.read(recurringTransactionRepositoryProvider);
      await repository.deleteRecurringTransaction(id);
      if (!ref.mounted) return;
      state = AsyncValue.data(await repository.getAllRecurringTransactions());
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    if (!ref.mounted) return;
    state = const AsyncLoading();
    try {
      final repository = ref.read(recurringTransactionRepositoryProvider);
      final rules = await repository.getAllRecurringTransactions();
      if (!ref.mounted) return;
      state = AsyncValue.data(rules);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateRecurringTransaction(
    String id,
    RecurringTransactionEntity rule,
  ) async {
    if (!ref.mounted) return;
    state = const AsyncLoading();
    try {
      final repository = ref.read(recurringTransactionRepositoryProvider);
      await repository.updateRecurringTransaction(id, rule);
      if (!ref.mounted) return;
      state = AsyncValue.data(await repository.getAllRecurringTransactions());
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
