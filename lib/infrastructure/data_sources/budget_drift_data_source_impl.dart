import 'package:drift/drift.dart';
import 'package:pocket_guard/config/database/database.dart' as db;
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/domain/data_sources/budget_data_source.dart';
import 'package:pocket_guard/domain/entities/budget.dart';
import 'package:pocket_guard/infrastructure/errors/data_exceptions.dart';
import 'package:pocket_guard/infrastructure/errors/drift_exception_handler.dart';

class BudgetDriftDataSourceImpl extends BudgetDataSource {
  BudgetDriftDataSourceImpl({AppDatabase? database})
    : database = database ?? db.database;

  final AppDatabase database;
  final DriftExceptionHandler _exceptionHandler = DriftExceptionHandler();

  @override
  Future<void> createBudget(BudgetEntity budget) async {
    try {
      await database.into(database.budgets).insert(_toCompanion(budget));
    } catch (e, stackTrace) {
      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'create budget',
        entityName: 'budget',
      );
    }
  }

  @override
  Future<void> deleteBudget(String id) async {
    try {
      final deleted = await (database.delete(
        database.budgets,
      )..where((tbl) => tbl.id.equals(id))).go();

      if (deleted == 0) {
        throw DataNotFoundException(entityName: 'budget');
      }
    } catch (e, stackTrace) {
      if (e is DataException) rethrow;

      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'delete budget',
        entityName: 'budget',
      );
    }
  }

  @override
  Future<List<BudgetEntity>> getAllBudgets() async {
    try {
      final rows = await database.select(database.budgets).get();
      return rows.map(_toEntity).toList();
    } catch (e, stackTrace) {
      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'get all budgets',
        entityName: 'budget',
      );
    }
  }

  @override
  Future<BudgetEntity?> getBudgetById(String id) async {
    try {
      final row = await (database.select(
        database.budgets,
      )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

      if (row == null) return null;
      return _toEntity(row);
    } catch (e, stackTrace) {
      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'get budget',
        entityName: 'budget',
      );
    }
  }

  @override
  Future<void> updateBudget(String id, BudgetEntity budget) async {
    try {
      final updated =
          await (database.update(
            database.budgets,
          )..where((tbl) => tbl.id.equals(id))).write(_toCompanion(budget));

      if (updated == 0) {
        throw DataNotFoundException(entityName: 'budget');
      }
    } catch (e, stackTrace) {
      if (e is DataException) rethrow;

      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'update budget',
        entityName: 'budget',
      );
    }
  }

  BudgetsCompanion _toCompanion(BudgetEntity budget) {
    return BudgetsCompanion(
      categoryId: Value(budget.categoryId),
      monthlyLimit: Value(budget.monthlyLimit),
      currency: Value(budget.currency),
      isActive: Value(budget.isActive),
    );
  }

  BudgetEntity _toEntity(Budget row) {
    return BudgetEntity(
      id: row.id,
      categoryId: row.categoryId,
      monthlyLimit: row.monthlyLimit,
      currency: row.currency,
      isActive: row.isActive,
    );
  }
}
