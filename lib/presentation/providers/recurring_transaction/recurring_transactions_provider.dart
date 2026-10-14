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

// Same error contract as BudgetsNotifier: mutating methods revert to the
// previous state and rethrow instead of setting `AsyncValue.error`, which
// swallowed failures (the form reported an unsaved rule as saved) and
// replaced the whole list with an error screen.
@riverpod
class RecurringTransactionsNotifier extends _$RecurringTransactionsNotifier {
  @override
  Future<List<RecurringTransactionEntity>> build() async {
    final repository = ref.read(recurringTransactionRepositoryProvider);
    return repository.getAllRecurringTransactions();
  }

  Future<void> createRecurringTransaction(RecurringTransactionEntity rule) =>
      _mutate((repository) => repository.createRecurringTransaction(rule));

  Future<void> deleteRecurringTransaction(String id) =>
      _mutate((repository) => repository.deleteRecurringTransaction(id));

  Future<void> refresh() => _mutate((_) async {});

  Future<void> updateRecurringTransaction(
    String id,
    RecurringTransactionEntity rule,
  ) => _mutate((repository) => repository.updateRecurringTransaction(id, rule));

  Future<void> _mutate(
    Future<void> Function(RecurringTransactionRepository repository) action,
  ) async {
    if (!ref.mounted) return;
    final previousState = state;
    state = const AsyncLoading();
    try {
      final repository = ref.read(recurringTransactionRepositoryProvider);
      await action(repository);
      if (!ref.mounted) return;
      state = AsyncValue.data(await repository.getAllRecurringTransactions());
    } catch (e) {
      if (ref.mounted) state = previousState;
      rethrow;
    }
  }
}
