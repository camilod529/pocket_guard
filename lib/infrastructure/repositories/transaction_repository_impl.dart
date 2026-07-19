import 'package:pocket_guard/domain/data_sources/transaction_data_source.dart';
import 'package:pocket_guard/domain/entities/transaction.dart';
import 'package:pocket_guard/domain/entities/transaction_filter.dart';
import 'package:pocket_guard/domain/repositories/transaction_repository.dart';
import 'package:pocket_guard/domain/services/logger_service.dart';
import 'package:pocket_guard/infrastructure/errors/data_exceptions.dart';
import 'package:pocket_guard/infrastructure/services/logger_service_impl.dart';

class TransactionRepositoryImpl extends TransactionRepository {
  final TransactionDataSource _dataSource;
  late final LoggerService _logger;

  TransactionRepositoryImpl({required TransactionDataSource dataSource})
    : _dataSource = dataSource {
    _logger = LoggerServiceImpl(runtimeType.toString());
  }

  @override
  Future<void> createTransaction(TransactionEntity transaction) async {
    _logger.info('Creating transaction: ${transaction.description}');

    try {
      await _dataSource.createTransaction(transaction);
      _logger.info(
        'Transaction created successfully: ${transaction.description}',
      );
    } on DataException catch (e, stackTrace) {
      _logger.error(
        'Failed to create transaction: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error(
        'Unexpected error creating transaction',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _logger.info('Deleting transaction with ID: $id');

    try {
      await _dataSource.deleteTransaction(id);
      _logger.info('Transaction deleted successfully: $id');
    } on DataException catch (e, stackTrace) {
      _logger.error(
        'Failed to delete transaction: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error(
        'Unexpected error deleting transaction',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<TransactionEntity>> getAllTransactions({
    TransactionFilter? filter,
  }) async {
    _logger.info('Fetching all transactions');
    try {
      final transactions = await _dataSource.getAllTransactions(filter: filter);
      _logger.info('Fetched ${transactions.length} transactions successfully');
      return transactions;
    } on DataException catch (e, stackTrace) {
      _logger.error(
        'Failed to fetch transactions: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      _logger.error(
        'Unexpected error fetching transactions',
        error: e,
        stackTrace: stackTrace,
      );
      throw UnknownDataException(
        message: 'Failed to fetch transactions: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<TransactionEntity?> getTransactionById(String id) async {
    _logger.info('Fetching transaction by ID: $id');
    try {
      final transaction = await _dataSource.getTransactionById(id);
      if (transaction != null) {
        _logger.info('Transaction fetched successfully: ${transaction.id}');
      } else {
        _logger.info('No transaction found with ID: $id');
      }
      return transaction;
    } on DataException catch (e, stackTrace) {
      _logger.error(
        'Failed to fetch transaction: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      _logger.error(
        'Unexpected error fetching transaction',
        error: e,
        stackTrace: stackTrace,
      );
      throw UnknownDataException(
        message: 'Failed to fetch transaction: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<TransactionEntity>> searchTransactions(String query) async {
    _logger.info('Searching transactions with query: $query');
    try {
      final transactions = await _dataSource.searchTransactions(query);
      _logger.info('Found ${transactions.length} transactions matching query');
      return transactions;
    } on DataException catch (e, stackTrace) {
      _logger.error(
        'Failed to search transactions: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      _logger.error(
        'Unexpected error searching transactions',
        error: e,
        stackTrace: stackTrace,
      );
      throw UnknownDataException(
        message: 'Failed to search transactions: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateTransaction(
    String id,
    TransactionEntity transaction,
  ) async {
    _logger.info('Updating transaction: $id');

    try {
      await _dataSource.updateTransaction(id, transaction);
      _logger.info('Transaction updated successfully: $id');
    } on DataException catch (e, stackTrace) {
      _logger.error(
        'Failed to update transaction: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      _logger.error(
        'Unexpected error updating transaction',
        error: e,
        stackTrace: stackTrace,
      );
      throw UnknownDataException(
        message: 'Failed to update transaction: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
