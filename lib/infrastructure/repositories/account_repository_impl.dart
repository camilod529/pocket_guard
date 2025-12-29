import 'package:pocket_guard/domain/data_sources/account_data_source.dart';
import 'package:pocket_guard/domain/entities/account.dart';
import 'package:pocket_guard/domain/repositories/account_repository.dart';
import 'package:pocket_guard/domain/services/logger_service.dart';
import 'package:pocket_guard/infrastructure/errors/data_exceptions.dart';
import 'package:pocket_guard/infrastructure/services/logger_service_impl.dart';

class AccountRepositoryImpl extends AccountRepository {
  final AccountDataSource _dataSource;
  late final LoggerService _logger;

  AccountRepositoryImpl({required AccountDataSource dataSource})
    : _dataSource = dataSource {
    _logger = LoggerServiceImpl(runtimeType.toString());
  }

  @override
  Future<void> createAccount(AccountEntity account) async {
    _logger.info('Creating account: ${account.name}');

    try {
      await _dataSource.createAccount(account);
      _logger.info('Account created successfully: ${account.name}');
    } on DataException catch (e, stackTrace) {
      _logger.error(
        'Failed to create account: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      _logger.error(
        'Unexpected error creating account',
        error: e,
        stackTrace: stackTrace,
      );
      throw UnknownDataException(
        message: 'Failed to create account: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deleteAccount(String id) async {
    _logger.info('Deleting account with ID: $id');

    try {
      await _dataSource.deleteAccount(id);
      _logger.info('Account deleted successfully: $id');
    } on DataException catch (e, stackTrace) {
      _logger.error(
        'Failed to delete account: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      _logger.error(
        'Unexpected error deleting account',
        error: e,
        stackTrace: stackTrace,
      );
      throw UnknownDataException(
        message: 'Failed to delete account: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<AccountEntity?> getAccountById(String id) async {
    _logger.debug('Getting account by ID: $id');

    try {
      final account = await _dataSource.getAccountById(id);

      if (account == null) {
        _logger.debug('Account not found: $id');
      } else {
        _logger.debug('Account found: ${account.name}');
      }

      return account;
    } on DataException catch (e, stackTrace) {
      _logger.error(
        'Failed to get account: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      _logger.error(
        'Unexpected error getting account',
        error: e,
        stackTrace: stackTrace,
      );
      throw UnknownDataException(
        message: 'Failed to get account: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<AccountEntity>> getAllAccounts() async {
    _logger.debug('Getting all accounts');

    try {
      final accounts = await _dataSource.getAllAccounts();
      _logger.debug('Found ${accounts.length} accounts');
      return accounts;
    } on DataException catch (e, stackTrace) {
      _logger.error(
        'Failed to get all accounts: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      _logger.error(
        'Unexpected error getting all accounts',
        error: e,
        stackTrace: stackTrace,
      );
      throw UnknownDataException(
        message: 'Failed to get all accounts: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<AccountEntity>> searchAccounts(String query) async {
    _logger.debug('Searching accounts with query: "$query"');

    try {
      final accounts = await _dataSource.searchAccounts(query);
      _logger.debug('Found ${accounts.length} accounts matching "$query"');
      return accounts;
    } on DataException catch (e, stackTrace) {
      _logger.error(
        'Failed to search accounts: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      _logger.error(
        'Unexpected error searching accounts',
        error: e,
        stackTrace: stackTrace,
      );
      throw UnknownDataException(
        message: 'Failed to search accounts: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateAccount(String id, AccountEntity account) async {
    _logger.info('Updating account: $id');

    try {
      await _dataSource.updateAccount(id, account);
      _logger.info('Account updated successfully: $id');
    } on DataException catch (e, stackTrace) {
      _logger.error(
        'Failed to update account: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      _logger.error(
        'Unexpected error updating account',
        error: e,
        stackTrace: stackTrace,
      );
      throw UnknownDataException(
        message: 'Failed to update account: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
