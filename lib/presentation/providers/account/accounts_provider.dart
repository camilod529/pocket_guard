import 'package:pocket_guard/domain/data_sources/account_data_source.dart';
import 'package:pocket_guard/domain/entities/account.dart';
import 'package:pocket_guard/domain/repositories/account_repository.dart';
import 'package:pocket_guard/infrastructure/data_sources/account_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/repositories/account_repository_impl.dart';
import 'package:pocket_guard/presentation/providers/transaction/transactions_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'accounts_provider.g.dart';

@Riverpod(keepAlive: true)
AccountDataSource accountDataSource(Ref ref) {
  return AccountDriftDataSourceImpl();
}

@Riverpod(keepAlive: true)
AccountRepository accountRepository(Ref ref) {
  final dataSource = ref.watch(accountDataSourceProvider);
  return AccountRepositoryImpl(dataSource: dataSource);
}

// Same error contract as BudgetsNotifier: mutating methods revert to the
// previous state and rethrow instead of setting `AsyncValue.error`. Setting
// the error swallowed failures - the account form reported a failed save as
// a success - and replaced the whole list with an error screen.
@riverpod
class AccountsNotifier extends _$AccountsNotifier {
  @override
  Future<List<AccountEntity>> build() async {
    final repository = ref.read(accountRepositoryProvider);
    final accounts = await repository.getAllAccounts();
    return accounts;
  }

  Future<void> createAccount(AccountEntity account) =>
      _mutate((repository) => repository.createAccount(account));

  Future<void> deleteAccount(String id) async {
    await _mutate((repository) => repository.deleteAccount(id));
    // Deleting an account cascades to its transactions.
    ref.invalidate(transactionsProvider);
  }

  Future<void> refresh() => _mutate((_) async {});

  /// [newIndex] is the item's final position, already adjusted for its
  /// removal from [oldIndex] - what ReorderableListView.onReorderItem
  /// passes (the deprecated onReorder passed the pre-removal index).
  Future<void> reorderAccounts(
    int oldIndex,
    int newIndex,
    List<AccountEntity> categoryAccounts,
  ) async {
    final items = [...categoryAccounts];
    final movedItem = items.removeAt(oldIndex);
    items.insert(newIndex, movedItem);

    final repository = ref.read(accountRepositoryProvider);
    for (int i = 0; i < items.length; i++) {
      final updatedAccount = items[i].copyWith(sortOrder: i);
      await repository.updateAccount(updatedAccount.id, updatedAccount);
    }

    await refresh();
  }

  Future<List<AccountEntity>> searchAccounts(String query) async {
    if (!ref.mounted) return [];
    final repository = ref.read(accountRepositoryProvider);
    return repository.searchAccounts(query);
  }

  Future<void> updateAccount(String id, AccountEntity account) =>
      _mutate((repository) => repository.updateAccount(id, account));

  Future<void> _mutate(
    Future<void> Function(AccountRepository repository) action,
  ) async {
    if (!ref.mounted) return;
    final previousState = state;
    state = const AsyncLoading();
    try {
      final repository = ref.read(accountRepositoryProvider);
      await action(repository);
      if (!ref.mounted) return;
      state = AsyncValue.data(await repository.getAllAccounts());
    } catch (e) {
      if (ref.mounted) state = previousState;
      rethrow;
    }
  }
}
