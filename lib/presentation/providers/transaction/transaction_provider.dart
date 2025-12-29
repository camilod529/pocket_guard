import 'package:pocket_guard/domain/entities/transaction.dart';
import 'package:pocket_guard/presentation/providers/transaction/transactions_provider.dart';
import 'package:pocket_guard/utils/constants/global_constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_provider.g.dart';

@riverpod
class TransactionNotifier extends _$TransactionNotifier {
  @override
  Future<TransactionEntity?> build(String transactionId) async {
    if (transactionId == GlobalConstants.createId || transactionId.isEmpty) {
      return null;
    }

    final repository = ref.read(transactionRepositoryProvider);
    return await repository.getTransactionById(transactionId);
  }

  Future<void> updateTransaction(TransactionEntity transaction) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(transactionRepositoryProvider);
      await repository.updateTransaction(transaction.id, transaction);

      // Refresh the transactions list
      ref.invalidate(transactionsProvider);

      state = AsyncValue.data(transaction);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
