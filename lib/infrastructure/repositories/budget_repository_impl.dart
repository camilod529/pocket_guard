import 'package:pocket_guard/domain/data_sources/budget_data_source.dart';
import 'package:pocket_guard/domain/entities/budget.dart';
import 'package:pocket_guard/domain/repositories/budget_repository.dart';
import 'package:pocket_guard/domain/services/logger_service.dart';
import 'package:pocket_guard/infrastructure/errors/data_exceptions.dart';
import 'package:pocket_guard/infrastructure/services/logger_service_impl.dart';

class BudgetRepositoryImpl extends BudgetRepository {
  final BudgetDataSource _dataSource;
  late final LoggerService _logger;

  BudgetRepositoryImpl({required BudgetDataSource dataSource})
    : _dataSource = dataSource {
    _logger = LoggerServiceImpl(runtimeType.toString());
  }

  @override
  Future<void> createBudget(BudgetEntity budget) async {
    _logger.info('Creating budget for category: ${budget.categoryId}');

    try {
      await _dataSource.createBudget(budget);
      _logger.info('Budget created successfully: ${budget.categoryId}');
    } on DataException catch (e, stackTrace) {
      _logger.error(
        'Failed to create budget: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      _logger.error(
        'Unexpected error creating budget',
        error: e,
        stackTrace: stackTrace,
      );
      throw UnknownDataException(
        message: 'Failed to create budget: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deleteBudget(String id) async {
    _logger.info('Deleting budget with ID: $id');

    try {
      await _dataSource.deleteBudget(id);
      _logger.info('Budget deleted successfully: $id');
    } on DataException catch (e, stackTrace) {
      _logger.error(
        'Failed to delete budget: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      _logger.error(
        'Unexpected error deleting budget',
        error: e,
        stackTrace: stackTrace,
      );
      throw UnknownDataException(
        message: 'Failed to delete budget: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<BudgetEntity>> getAllBudgets() async {
    _logger.debug('Getting all budgets');

    try {
      final budgets = await _dataSource.getAllBudgets();
      _logger.debug('Found ${budgets.length} budgets');
      return budgets;
    } on DataException catch (e, stackTrace) {
      _logger.error(
        'Failed to get all budgets: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      _logger.error(
        'Unexpected error getting all budgets',
        error: e,
        stackTrace: stackTrace,
      );
      throw UnknownDataException(
        message: 'Failed to get all budgets: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<BudgetEntity?> getBudgetById(String id) async {
    _logger.debug('Getting budget by ID: $id');

    try {
      final budget = await _dataSource.getBudgetById(id);

      if (budget == null) {
        _logger.debug('Budget not found: $id');
      } else {
        _logger.debug('Budget found: ${budget.categoryId}');
      }

      return budget;
    } on DataException catch (e, stackTrace) {
      _logger.error(
        'Failed to get budget: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      _logger.error(
        'Unexpected error getting budget',
        error: e,
        stackTrace: stackTrace,
      );
      throw UnknownDataException(
        message: 'Failed to get budget: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateBudget(String id, BudgetEntity budget) async {
    _logger.info('Updating budget: $id');

    try {
      await _dataSource.updateBudget(id, budget);
      _logger.info('Budget updated successfully: $id');
    } on DataException catch (e, stackTrace) {
      _logger.error(
        'Failed to update budget: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      _logger.error(
        'Unexpected error updating budget',
        error: e,
        stackTrace: stackTrace,
      );
      throw UnknownDataException(
        message: 'Failed to update budget: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
