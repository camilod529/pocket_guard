import 'package:pocket_guard/domain/data_sources/recurring_transaction_data_source.dart';
import 'package:pocket_guard/domain/entities/recurring_transaction.dart';
import 'package:pocket_guard/domain/repositories/recurring_transaction_repository.dart';
import 'package:pocket_guard/domain/services/logger_service.dart';
import 'package:pocket_guard/infrastructure/errors/data_exceptions.dart';
import 'package:pocket_guard/infrastructure/services/logger_service_impl.dart';

class RecurringTransactionRepositoryImpl extends RecurringTransactionRepository {
  final RecurringTransactionDataSource _dataSource;
  late final LoggerService _logger;

  RecurringTransactionRepositoryImpl({
    required RecurringTransactionDataSource dataSource,
  }) : _dataSource = dataSource {
    _logger = LoggerServiceImpl(runtimeType.toString());
  }

  @override
  Future<void> createRecurringTransaction(
    RecurringTransactionEntity rule,
  ) async {
    _logger.info('Creating recurring transaction: ${rule.description}');

    try {
      await _dataSource.createRecurringTransaction(rule);
      _logger.info('Recurring transaction created successfully: ${rule.description}');
    } on DataException catch (e, stackTrace) {
      _logger.error(
        'Failed to create recurring transaction: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      _logger.error(
        'Unexpected error creating recurring transaction',
        error: e,
        stackTrace: stackTrace,
      );
      throw UnknownDataException(
        message: 'Failed to create recurring transaction: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deleteRecurringTransaction(String id) async {
    _logger.info('Deleting recurring transaction with ID: $id');

    try {
      await _dataSource.deleteRecurringTransaction(id);
      _logger.info('Recurring transaction deleted successfully: $id');
    } on DataException catch (e, stackTrace) {
      _logger.error(
        'Failed to delete recurring transaction: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      _logger.error(
        'Unexpected error deleting recurring transaction',
        error: e,
        stackTrace: stackTrace,
      );
      throw UnknownDataException(
        message: 'Failed to delete recurring transaction: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<RecurringTransactionEntity>> getAllRecurringTransactions() async {
    _logger.debug('Getting all recurring transactions');

    try {
      final rules = await _dataSource.getAllRecurringTransactions();
      _logger.debug('Found ${rules.length} recurring transactions');
      return rules;
    } on DataException catch (e, stackTrace) {
      _logger.error(
        'Failed to get all recurring transactions: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      _logger.error(
        'Unexpected error getting all recurring transactions',
        error: e,
        stackTrace: stackTrace,
      );
      throw UnknownDataException(
        message: 'Failed to get all recurring transactions: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<RecurringTransactionEntity?> getRecurringTransactionById(
    String id,
  ) async {
    _logger.debug('Getting recurring transaction by ID: $id');

    try {
      final rule = await _dataSource.getRecurringTransactionById(id);

      if (rule == null) {
        _logger.debug('Recurring transaction not found: $id');
      } else {
        _logger.debug('Recurring transaction found: ${rule.description}');
      }

      return rule;
    } on DataException catch (e, stackTrace) {
      _logger.error(
        'Failed to get recurring transaction: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      _logger.error(
        'Unexpected error getting recurring transaction',
        error: e,
        stackTrace: stackTrace,
      );
      throw UnknownDataException(
        message: 'Failed to get recurring transaction: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateRecurringTransaction(
    String id,
    RecurringTransactionEntity rule,
  ) async {
    _logger.info('Updating recurring transaction: $id');

    try {
      await _dataSource.updateRecurringTransaction(id, rule);
      _logger.info('Recurring transaction updated successfully: $id');
    } on DataException catch (e, stackTrace) {
      _logger.error(
        'Failed to update recurring transaction: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      _logger.error(
        'Unexpected error updating recurring transaction',
        error: e,
        stackTrace: stackTrace,
      );
      throw UnknownDataException(
        message: 'Failed to update recurring transaction: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
