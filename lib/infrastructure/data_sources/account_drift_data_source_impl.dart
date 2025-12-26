import 'package:drift/drift.dart';
import 'package:money_manager_flutter/config/database/database.dart';
import 'package:money_manager_flutter/domain/data_sources/account_data_source.dart';
import 'package:money_manager_flutter/domain/entities/account.dart';
import 'package:money_manager_flutter/infrastructure/errors/data_exceptions.dart';
import 'package:money_manager_flutter/infrastructure/errors/drift_exception_handler.dart';

class AccountDriftDataSourceImpl extends AccountDataSource {
  final DriftExceptionHandler _exceptionHandler = DriftExceptionHandler();

  @override
  Future<void> createAccount(AccountEntity account) async {
    try {
      await database
          .into(database.accounts)
          .insert(
            AccountsCompanion(
              name: Value(account.name),
              currency: Value(account.currency),
            ),
          );
    } catch (e, stackTrace) {
      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'create account',
        entityName: 'account',
        fieldName: _checkDuplicateField(e),
      );
    }
  }

  @override
  Future<void> deleteAccount(String id) async {
    try {
      final deleted = await (database.delete(
        database.accounts,
      )..where((tbl) => tbl.id.equals(id))).go();

      if (deleted == 0) {
        throw DataNotFoundException(entityName: 'account');
      }
    } catch (e, stackTrace) {
      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'delete account',
        entityName: 'account',
      );
    }
  }

  @override
  Future<AccountEntity?> getAccountById(String id) async {
    try {
      final account = await (database.select(
        database.accounts,
      )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

      if (account == null) return null;

      return AccountEntity(
        id: account.id,
        name: account.name,
        currency: account.currency,
        balance: account.balance,
      );
    } catch (e, stackTrace) {
      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'get account',
        entityName: 'account',
      );
    }
  }

  @override
  Future<List<AccountEntity>> getAllAccounts() async {
    try {
      final databaseAccounts = await database.select(database.accounts).get();

      final accounts = databaseAccounts.map((account) {
        return AccountEntity(
          id: account.id,
          name: account.name,
          currency: account.currency,
          balance: account.balance,
        );
      }).toList();

      return accounts;
    } catch (e, stackTrace) {
      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'get all accounts',
        entityName: 'account',
      );
    }
  }

  @override
  Future<List<AccountEntity>> searchAccounts(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getAllAccounts();
      }

      final accounts = await (database.select(
        database.accounts,
      )..where((tbl) => tbl.name.like('%$query%'))).get();

      return accounts.map((account) {
        return AccountEntity(
          id: account.id,
          name: account.name,
          currency: account.currency,
          balance: account.balance,
        );
      }).toList();
    } catch (e, stackTrace) {
      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'search accounts',
        entityName: 'account',
      );
    }
  }

  @override
  Future<void> updateAccount(String id, AccountEntity account) async {
    try {
      // Check if account exists first
      final existing = await getAccountById(id);
      if (existing == null) {
        throw DataNotFoundException(entityName: 'account');
      }

      final updated =
          await (database.update(
            database.accounts,
          )..where((tbl) => tbl.id.equals(id))).write(
            AccountsCompanion(
              name: Value(account.name),
              currency: Value(account.currency),
              balance: Value(account.balance),
            ),
          );

      if (updated == 0) {
        throw DataNotFoundException(entityName: 'account');
      }
    } catch (e, stackTrace) {
      if (e is DataException) rethrow;

      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'update account',
        entityName: 'account',
        fieldName: _checkDuplicateField(e),
      );
    }
  }

  String? _checkDuplicateField(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains('name')) return 'name';
    if (message.contains('currency')) return 'currency';

    return null;
  }
}
