import 'package:money_manager_flutter/domain/entities/account.dart';

abstract class AccountRepository {
  Future<void> createAccount(AccountEntity account);
  Future<void> deleteAccount(String id);
  Future<AccountEntity?> getAccountById(String id);
  Future<List<AccountEntity>> getAllAccounts();
  Future<List<AccountEntity>> searchAccounts(String query);
  Future<void> updateAccount(String id, AccountEntity account);
}
