import 'package:money_manager_flutter/domain/entities/account.dart';
import 'package:money_manager_flutter/domain/repositories/account_repository.dart';

class AccountRepositoryImpl extends AccountRepository {
  @override
  Future<void> createAccount(AccountEntity account) {
    // TODO: implement createAccount
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAccount(String id) {
    // TODO: implement deleteAccount
    throw UnimplementedError();
  }

  @override
  Future<AccountEntity?> getAccountById(String id) {
    // TODO: implement getAccountById
    throw UnimplementedError();
  }

  @override
  Future<List<AccountEntity>> getAllAccounts() {
    // TODO: implement getAllAccounts
    throw UnimplementedError();
  }

  @override
  Future<List<AccountEntity>> searchAccounts(String query) {
    // TODO: implement searchAccounts
    throw UnimplementedError();
  }

  @override
  Future<void> updateAccount(String id, AccountEntity account) {
    // TODO: implement updateAccount
    throw UnimplementedError();
  }
}
