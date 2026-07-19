import 'package:pocket_guard/domain/entities/recurring_transaction.dart';
import 'package:pocket_guard/presentation/providers/recurring_transaction/recurring_transactions_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recurring_transaction_provider.g.dart';

@Riverpod(keepAlive: true)
class RecurringTransactionNotifier extends _$RecurringTransactionNotifier {
  @override
  Future<RecurringTransactionEntity?> build(String id) async {
    if (id.isEmpty) return null;
    final repository = ref.read(recurringTransactionRepositoryProvider);
    return repository.getRecurringTransactionById(id);
  }

  Future<void> refreshRecurringTransaction() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build(state.value?.id ?? ''));
  }
}
