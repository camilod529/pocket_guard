import 'package:drift/drift.dart';
import 'package:pocket_guard/config/database/database.dart' as db;
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/domain/data_sources/savings_goal_data_source.dart';
import 'package:pocket_guard/domain/entities/goal_contribution.dart';
import 'package:pocket_guard/domain/entities/savings_goal.dart';
import 'package:pocket_guard/infrastructure/errors/data_exceptions.dart';
import 'package:pocket_guard/infrastructure/errors/drift_exception_handler.dart';

/// Savings goals move real money: a deposit subtracts from its source
/// account's balance, a withdrawal adds back to its account. Like
/// transactions, balances are only ever touched through relative updates in
/// [_applyContributionEffect] / [_reverseContributionEffect], which must
/// stay exact inverses of each other. Every rule check runs inside the same
/// `database.transaction()` as the write it guards, after any reversal, so
/// a failed check rolls the whole operation back.
class SavingsGoalDriftDataSourceImpl extends SavingsGoalDataSource {
  SavingsGoalDriftDataSourceImpl({AppDatabase? database})
    : database = database ?? db.database;

  /// Tolerance for float sums of currency amounts (well under a cent).
  static const double _epsilon = 1e-6;

  final AppDatabase database;
  final DriftExceptionHandler _exceptionHandler = DriftExceptionHandler();

  @override
  Future<void> addContribution(GoalContributionEntity contribution) async {
    try {
      await database.transaction(() async {
        await _validateContribution(contribution, savedExcluding: 0);
        await database
            .into(database.goalContributions)
            .insert(_toContributionCompanion(contribution));
        await _applyContributionEffect(contribution);
      });
    } catch (e, stackTrace) {
      if (e is DataException) rethrow;

      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'add goal contribution',
        entityName: 'goal contribution',
      );
    }
  }

  @override
  Future<void> createGoal(SavingsGoalEntity goal) async {
    try {
      await database.into(database.savingsGoals).insert(_toGoalCompanion(goal));
    } catch (e, stackTrace) {
      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'create savings goal',
        entityName: 'savings goal',
      );
    }
  }

  @override
  Future<void> deleteContribution(String id) async {
    try {
      await database.transaction(() async {
        final old = await _getContribution(id);
        if (old.accountId == null) {
          throw SavingsGoalValidationException(SavingsGoalError.accountMissing);
        }

        await _reverseContributionEffect(old);
        await (database.delete(
          database.goalContributions,
        )..where((tbl) => tbl.id.equals(id))).go();

        // Deleting a deposit that later withdrawals already drew on would
        // leave the jar negative.
        if (await _savedAmount(old.goalId) < -_epsilon) {
          throw SavingsGoalValidationException(
            SavingsGoalError.insufficientGoalBalance,
          );
        }
      });
    } catch (e, stackTrace) {
      if (e is DataException) rethrow;

      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'delete goal contribution',
        entityName: 'goal contribution',
      );
    }
  }

  @override
  Future<void> deleteGoal(String id, {String? refundAccountId}) async {
    try {
      await database.transaction(() async {
        final goal = await getGoalById(id);
        if (goal == null) {
          throw DataNotFoundException(entityName: 'savings goal');
        }

        final saved = await _savedAmount(id);
        if (saved > _epsilon) {
          if (refundAccountId == null) {
            throw SavingsGoalValidationException(
              SavingsGoalError.refundAccountRequired,
            );
          }
          final account = await _getAccount(refundAccountId);
          if (account.currency != goal.currency) {
            throw SavingsGoalValidationException(
              SavingsGoalError.currencyMismatch,
            );
          }
          // Return the money directly rather than writing a withdrawal row,
          // since the contribution history is deleted right after anyway.
          await _adjustBalance(refundAccountId, saved);
        }

        await (database.delete(
          database.goalContributions,
        )..where((tbl) => tbl.goalId.equals(id))).go();
        await (database.delete(
          database.savingsGoals,
        )..where((tbl) => tbl.id.equals(id))).go();
      });
    } catch (e, stackTrace) {
      if (e is DataException) rethrow;

      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'delete savings goal',
        entityName: 'savings goal',
      );
    }
  }

  @override
  Future<List<SavingsGoalEntity>> getAllGoals() async {
    try {
      final rows = await (database.select(
        database.savingsGoals,
      )..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)])).get();
      return rows.map(_toGoalEntity).toList();
    } catch (e, stackTrace) {
      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'get all savings goals',
        entityName: 'savings goal',
      );
    }
  }

  @override
  Future<List<GoalContributionEntity>> getContributionsForGoal(
    String goalId,
  ) async {
    try {
      final rows =
          await (database.select(database.goalContributions)
                ..where((tbl) => tbl.goalId.equals(goalId))
                ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]))
              .get();
      return rows.map(_toContributionEntity).toList();
    } catch (e, stackTrace) {
      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'get goal contributions',
        entityName: 'goal contribution',
      );
    }
  }

  @override
  Future<List<GoalContributionEntity>> getContributionsSince(
    DateTime since,
  ) async {
    try {
      final rows = await (database.select(
        database.goalContributions,
      )..where((tbl) => tbl.date.isBiggerOrEqualValue(since))).get();
      return rows.map(_toContributionEntity).toList();
    } catch (e, stackTrace) {
      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'get goal contributions since date',
        entityName: 'goal contribution',
      );
    }
  }

  @override
  Future<SavingsGoalEntity?> getGoalById(String id) async {
    try {
      final row = await (database.select(
        database.savingsGoals,
      )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

      if (row == null) return null;
      return _toGoalEntity(row);
    } catch (e, stackTrace) {
      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'get savings goal',
        entityName: 'savings goal',
      );
    }
  }

  @override
  Future<Map<String, double>> getSavedAmounts() async {
    try {
      final total = database.goalContributions.amount.sum();
      final rows =
          await (database.selectOnly(database.goalContributions)
                ..addColumns([database.goalContributions.goalId, total])
                ..groupBy([database.goalContributions.goalId]))
              .get();
      return {
        for (final row in rows)
          row.read(database.goalContributions.goalId)!: row.read(total) ?? 0,
      };
    } catch (e, stackTrace) {
      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'get saved amounts',
        entityName: 'goal contribution',
      );
    }
  }

  @override
  Future<void> updateContribution(
    String id,
    GoalContributionEntity contribution,
  ) async {
    try {
      await database.transaction(() async {
        final old = await _getContribution(id);
        if (old.accountId == null) {
          throw SavingsGoalValidationException(SavingsGoalError.accountMissing);
        }
        // A contribution can't be moved to a different jar.
        final updated = GoalContributionEntity(
          id: id,
          goalId: old.goalId,
          accountId: contribution.accountId,
          amount: contribution.amount,
          date: contribution.date,
          note: contribution.note,
        );

        // Same order as TransactionDriftDataSourceImpl.updateTransaction:
        // reverse old -> write new -> apply new. Validating after the
        // reversal means the checks see balances as if the old version
        // never happened.
        await _reverseContributionEffect(old);
        await _validateContribution(updated, savedExcluding: old.amount);
        await (database.update(database.goalContributions)
              ..where((tbl) => tbl.id.equals(id)))
            .write(_toContributionCompanion(updated));
        await _applyContributionEffect(updated);

        // Lowering an old deposit can strand later withdrawals.
        if (await _savedAmount(old.goalId) < -_epsilon) {
          throw SavingsGoalValidationException(
            SavingsGoalError.insufficientGoalBalance,
          );
        }
      });
    } catch (e, stackTrace) {
      if (e is DataException) rethrow;

      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'update goal contribution',
        entityName: 'goal contribution',
      );
    }
  }

  @override
  Future<void> updateGoal(String id, SavingsGoalEntity goal) async {
    try {
      await database.transaction(() async {
        final existing = await getGoalById(id);
        if (existing == null) {
          throw DataNotFoundException(entityName: 'savings goal');
        }

        if (existing.currency != goal.currency) {
          final hasContributions =
              await (database.select(database.goalContributions)
                    ..where((tbl) => tbl.goalId.equals(id))
                    ..limit(1))
                  .getSingleOrNull() !=
              null;
          if (hasContributions) {
            throw SavingsGoalValidationException(
              SavingsGoalError.currencyLocked,
            );
          }
        }

        await (database.update(
          database.savingsGoals,
        )..where((tbl) => tbl.id.equals(id))).write(_toGoalCompanion(goal));
      });
    } catch (e, stackTrace) {
      if (e is DataException) rethrow;

      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'update savings goal',
        entityName: 'savings goal',
      );
    }
  }

  Future<void> _adjustBalance(String accountId, double delta) {
    return database.customUpdate(
      'UPDATE accounts SET balance = balance + ? WHERE id = ?',
      updates: {database.accounts},
      variables: [Variable<double>(delta), Variable<String>(accountId)],
    );
  }

  /// A deposit (+amount) leaves the account; a withdrawal (-amount) returns
  /// to it.
  Future<void> _applyContributionEffect(GoalContributionEntity contribution) {
    return _adjustBalance(contribution.accountId!, -contribution.amount);
  }

  Future<Account> _getAccount(String id) async {
    final account = await (database.select(
      database.accounts,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    if (account == null) throw DataNotFoundException(entityName: 'account');
    return account;
  }

  Future<GoalContributionEntity> _getContribution(String id) async {
    final row = await (database.select(
      database.goalContributions,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    if (row == null) {
      throw DataNotFoundException(entityName: 'goal contribution');
    }
    return _toContributionEntity(row);
  }

  /// Exact inverse of [_applyContributionEffect].
  Future<void> _reverseContributionEffect(GoalContributionEntity contribution) {
    return _adjustBalance(contribution.accountId!, contribution.amount);
  }

  Future<double> _savedAmount(String goalId) async {
    final total = database.goalContributions.amount.sum();
    final row =
        await (database.selectOnly(database.goalContributions)
              ..addColumns([total])
              ..where(database.goalContributions.goalId.equals(goalId)))
            .getSingle();
    return row.read(total) ?? 0;
  }

  GoalContributionsCompanion _toContributionCompanion(
    GoalContributionEntity contribution,
  ) {
    return GoalContributionsCompanion(
      goalId: Value(contribution.goalId),
      accountId: Value(contribution.accountId),
      amount: Value(contribution.amount),
      date: Value(contribution.date),
      note: Value(contribution.note),
    );
  }

  GoalContributionEntity _toContributionEntity(GoalContribution row) {
    return GoalContributionEntity(
      id: row.id,
      goalId: row.goalId,
      accountId: row.accountId,
      amount: row.amount,
      date: row.date,
      note: row.note,
    );
  }

  SavingsGoalsCompanion _toGoalCompanion(SavingsGoalEntity goal) {
    return SavingsGoalsCompanion(
      name: Value(goal.name),
      targetAmount: Value(goal.targetAmount),
      currency: Value(goal.currency),
      targetDate: Value(goal.targetDate),
      isArchived: Value(goal.isArchived),
    );
  }

  SavingsGoalEntity _toGoalEntity(SavingsGoal row) {
    return SavingsGoalEntity(
      id: row.id,
      name: row.name,
      targetAmount: row.targetAmount,
      currency: row.currency,
      targetDate: row.targetDate,
      isArchived: row.isArchived,
      createdAt: row.createdAt,
    );
  }

  /// Checks [contribution] against the current (already-reversed, when
  /// editing) state. [savedExcluding] is the amount of the row being
  /// replaced, which is still counted in the jar's SUM at this point.
  Future<void> _validateContribution(
    GoalContributionEntity contribution, {
    required double savedExcluding,
  }) async {
    if (contribution.amount.abs() < _epsilon) {
      throw SavingsGoalValidationException(SavingsGoalError.zeroAmount);
    }
    if (contribution.accountId == null) {
      throw SavingsGoalValidationException(SavingsGoalError.accountMissing);
    }

    final goal = await getGoalById(contribution.goalId);
    if (goal == null) throw DataNotFoundException(entityName: 'savings goal');
    final account = await _getAccount(contribution.accountId!);

    if (account.currency != goal.currency) {
      throw SavingsGoalValidationException(SavingsGoalError.currencyMismatch);
    }

    if (contribution.amount > 0) {
      // Same rule as the transaction form's expense overdraft check.
      if (contribution.amount > account.balance + _epsilon) {
        throw SavingsGoalValidationException(
          SavingsGoalError.insufficientAccountBalance,
        );
      }
    } else {
      final available = await _savedAmount(goal.id) - savedExcluding;
      if (-contribution.amount > available + _epsilon) {
        throw SavingsGoalValidationException(
          SavingsGoalError.insufficientGoalBalance,
        );
      }
    }
  }
}
