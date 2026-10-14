import 'package:pocket_guard/domain/data_sources/savings_goal_data_source.dart';
import 'package:pocket_guard/domain/entities/goal_contribution.dart';
import 'package:pocket_guard/domain/entities/savings_goal.dart';
import 'package:pocket_guard/domain/repositories/savings_goal_repository.dart';
import 'package:pocket_guard/domain/services/logger_service.dart';
import 'package:pocket_guard/infrastructure/errors/data_exceptions.dart';
import 'package:pocket_guard/infrastructure/services/logger_service_impl.dart';

class SavingsGoalRepositoryImpl extends SavingsGoalRepository {
  final SavingsGoalDataSource _dataSource;
  late final LoggerService _logger;

  SavingsGoalRepositoryImpl({required SavingsGoalDataSource dataSource})
    : _dataSource = dataSource {
    _logger = LoggerServiceImpl(runtimeType.toString());
  }

  @override
  Future<void> addContribution(GoalContributionEntity contribution) {
    _logger.info(
      'Adding contribution of ${contribution.amount} to goal: '
      '${contribution.goalId}',
    );
    return _run('add goal contribution', () async {
      await _dataSource.addContribution(contribution);
      _logger.info('Contribution added to goal: ${contribution.goalId}');
    });
  }

  @override
  Future<void> createGoal(SavingsGoalEntity goal) {
    _logger.info('Creating savings goal: ${goal.name}');
    return _run('create savings goal', () async {
      await _dataSource.createGoal(goal);
      _logger.info('Savings goal created successfully: ${goal.name}');
    });
  }

  @override
  Future<void> deleteContribution(String id) {
    _logger.info('Deleting goal contribution: $id');
    return _run('delete goal contribution', () async {
      await _dataSource.deleteContribution(id);
      _logger.info('Goal contribution deleted successfully: $id');
    });
  }

  @override
  Future<void> deleteGoal(String id, {String? refundAccountId}) {
    _logger.info('Deleting savings goal: $id (refund to: $refundAccountId)');
    return _run('delete savings goal', () async {
      await _dataSource.deleteGoal(id, refundAccountId: refundAccountId);
      _logger.info('Savings goal deleted successfully: $id');
    });
  }

  @override
  Future<List<SavingsGoalEntity>> getAllGoals() {
    _logger.debug('Getting all savings goals');
    return _run('get all savings goals', () async {
      final goals = await _dataSource.getAllGoals();
      _logger.debug('Found ${goals.length} savings goals');
      return goals;
    });
  }

  @override
  Future<List<GoalContributionEntity>> getContributionsForGoal(String goalId) {
    _logger.debug('Getting contributions for goal: $goalId');
    return _run(
      'get goal contributions',
      () => _dataSource.getContributionsForGoal(goalId),
    );
  }

  @override
  Future<List<GoalContributionEntity>> getContributionsSince(DateTime since) {
    _logger.debug('Getting goal contributions since: $since');
    return _run(
      'get goal contributions since date',
      () => _dataSource.getContributionsSince(since),
    );
  }

  @override
  Future<SavingsGoalEntity?> getGoalById(String id) {
    _logger.debug('Getting savings goal by ID: $id');
    return _run('get savings goal', () => _dataSource.getGoalById(id));
  }

  @override
  Future<Map<String, double>> getSavedAmounts() {
    _logger.debug('Getting saved amounts for all goals');
    return _run('get saved amounts', _dataSource.getSavedAmounts);
  }

  @override
  Future<void> updateContribution(
    String id,
    GoalContributionEntity contribution,
  ) {
    _logger.info('Updating goal contribution: $id');
    return _run('update goal contribution', () async {
      await _dataSource.updateContribution(id, contribution);
      _logger.info('Goal contribution updated successfully: $id');
    });
  }

  @override
  Future<void> updateGoal(String id, SavingsGoalEntity goal) {
    _logger.info('Updating savings goal: $id');
    return _run('update savings goal', () async {
      await _dataSource.updateGoal(id, goal);
      _logger.info('Savings goal updated successfully: $id');
    });
  }

  /// Shared log-and-rethrow wrapper: typed [DataException]s pass through
  /// unchanged (callers rely on [SavingsGoalValidationException.reason]),
  /// anything else is wrapped in [UnknownDataException].
  Future<T> _run<T>(String operation, Future<T> Function() action) async {
    try {
      return await action();
    } on DataException catch (e, stackTrace) {
      _logger.error(
        'Failed to $operation: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      _logger.error(
        'Unexpected error trying to $operation',
        error: e,
        stackTrace: stackTrace,
      );
      throw UnknownDataException(
        message: 'Failed to $operation: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
