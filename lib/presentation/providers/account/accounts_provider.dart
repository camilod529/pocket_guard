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

@riverpod
class AccountsNotifier extends _$AccountsNotifier {
  @override
  Future<List<AccountEntity>> build() async {
    final repository = ref.read(accountRepositoryProvider);
    final accounts = await repository.getAllAccounts();
    return accounts;
  }

  Future<void> createAccount(AccountEntity account) async {
    if (!ref.mounted) return;
    state = const AsyncLoading();
    try {
      final repository = ref.read(accountRepositoryProvider);
      await repository.createAccount(account);
      if (!ref.mounted) return;
      state = AsyncValue.data(await repository.getAllAccounts());
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteAccount(String id) async {
    state = const AsyncLoading();
    try {
      if (!ref.mounted) return;
      final repository = ref.read(accountRepositoryProvider);
      await repository.deleteAccount(id);
      if (!ref.mounted) return;
      state = AsyncValue.data(await repository.getAllAccounts());
      ref.invalidate(transactionsProvider);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    if (!ref.mounted) return;
    state = const AsyncLoading();
    try {
      final repository = ref.read(accountRepositoryProvider);
      final accounts = await repository.getAllAccounts();
      if (!ref.mounted) return;
      state = AsyncValue.data(accounts);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> reorderAccounts(
    int oldIndex,
    int newIndex,
    List<AccountEntity> categoryAccounts,
  ) async {
    if (newIndex > oldIndex) newIndex -= 1;

    final items = [...categoryAccounts];
    final movedItem = items.removeAt(oldIndex);
    items.insert(newIndex, movedItem);

    final repository = ref.read(accountRepositoryProvider);
    for (int i = 0; i < items.length; i++) {
      final updatedAccount = items[i].copyWith(sortOrder: i);
      await repository.updateAccount(updatedAccount.id, updatedAccount);
    }

    refresh();
  }

  Future<List<AccountEntity>> searchAccounts(String query) async {
    if (!ref.mounted) return [];
    final repository = ref.read(accountRepositoryProvider);
    return repository.searchAccounts(query);
  }

  Future<void> updateAccount(String id, AccountEntity account) async {
    state = const AsyncLoading();
    try {
      if (!ref.mounted) return;
      final repository = ref.read(accountRepositoryProvider);
      await repository.updateAccount(id, account);
      if (!ref.mounted) return;
      state = AsyncValue.data(await repository.getAllAccounts());
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
