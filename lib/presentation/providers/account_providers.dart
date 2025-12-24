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
    return repository.getAllAccounts();
  }

  Future<void> createAccount(AccountEntity account) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(accountRepositoryProvider);
      await repository.createAccount(account);
      ref.invalidateSelf();
      return repository.getAllAccounts();
    });
  }

  Future<void> deleteAccount(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(accountRepositoryProvider);
      await repository.deleteAccount(id);
      ref.invalidateSelf();
      return repository.getAllAccounts();
    });
  }

  Future<AccountEntity?> getAccountById(String id) async {
    final repository = ref.read(accountRepositoryProvider);
    return repository.getAccountById(id);
  }

  Future<List<AccountEntity>> searchAccounts(String query) async {
    final repository = ref.read(accountRepositoryProvider);
    return repository.searchAccounts(query);
  }

  Future<void> updateAccount(String id, AccountEntity account) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(accountRepositoryProvider);
      await repository.updateAccount(id, account);
      ref.invalidateSelf();
      return repository.getAllAccounts();
    });
  }
}
