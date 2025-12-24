import 'package:money_manager_flutter/domain/data_sources/account_data_source.dart';
import 'package:money_manager_flutter/domain/entities/account.dart';
import 'package:money_manager_flutter/domain/repositories/account_repository.dart';
import 'package:money_manager_flutter/infrastructure/data_sources/account_drift_data_source_impl.dart';
import 'package:money_manager_flutter/infrastructure/repositories/account_repository_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_providers.g.dart';

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
class AccountNotifier extends _$AccountNotifier {
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
    state = await AsyncValue.guard(() async {
      if (!ref.mounted) return <AccountEntity>[];
      final repository = ref.read(accountRepositoryProvider);
      await repository.deleteAccount(id);
      return repository.getAllAccounts();
    });
  }

  Future<AccountEntity?> getAccountById(String id) async {
    if (!ref.mounted) return null;
    final repository = ref.read(accountRepositoryProvider);
    return repository.getAccountById(id);
  }

  Future<void> refresh() async {
    if (!ref.mounted) return;
    // state = const AsyncLoading();
    // state = await AsyncValue.guard(() async {
    //   if (!ref.mounted) return <AccountEntity>[];
    //   final repository = ref.read(accountRepositoryProvider);
    //   return repository.getAllAccounts();
    // });
    try {
      final repository = ref.read(accountRepositoryProvider);
      final accounts = await repository.getAllAccounts();
      if (!ref.mounted) return;
      state = AsyncValue.data(accounts);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<List<AccountEntity>> searchAccounts(String query) async {
    if (!ref.mounted) return [];
    final repository = ref.read(accountRepositoryProvider);
    return repository.searchAccounts(query);
  }

  Future<void> updateAccount(String id, AccountEntity account) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (!ref.mounted) return <AccountEntity>[];
      final repository = ref.read(accountRepositoryProvider);
      await repository.updateAccount(id, account);
      return repository.getAllAccounts();
    });
  }
}
