import 'package:drift/drift.dart';
import 'package:pocket_guard/config/database/database.dart' as db;
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/domain/data_sources/backup_data_source.dart';
import 'package:pocket_guard/domain/entities/backup.dart';
import 'package:pocket_guard/infrastructure/backup/backup_row_codecs.dart';
import 'package:pocket_guard/infrastructure/errors/data_exceptions.dart';
import 'package:pocket_guard/infrastructure/errors/drift_exception_handler.dart';

class BackupDriftDataSourceImpl extends BackupDataSource {
  BackupDriftDataSourceImpl({AppDatabase? database})
    : database = database ?? db.database;

  /// Which tables each section carries, by their name in the backup file.
  static const tablesBySection = <BackupSection, List<String>>{
    BackupSection.categories: ['categories'],
    BackupSection.money: [
      'accounts',
      'savingsGoals',
      'goalContributions',
      'transactions',
      'recurringTransactions',
    ],
    BackupSection.budgets: ['budgets'],
    BackupSection.wishlist: ['wishlistItems'],
    BackupSection.settings: [],
  };

  final AppDatabase database;
  final DriftExceptionHandler _exceptionHandler = DriftExceptionHandler();

  @override
  int get schemaVersion => database.schemaVersion;

  @override
  Future<Map<String, List<Map<String, Object?>>>> readTables(
    Set<BackupSection> sections,
  ) async {
    try {
      final tables = <String, List<Map<String, Object?>>>{};
      if (sections.contains(BackupSection.categories)) {
        tables['categories'] = [
          for (final row in await database.select(database.categories).get())
            BackupRowCodecs.encodeCategory(row),
        ];
      }
      if (sections.contains(BackupSection.money)) {
        tables['accounts'] = [
          for (final row in await database.select(database.accounts).get())
            BackupRowCodecs.encodeAccount(row),
        ];
        tables['savingsGoals'] = [
          for (final row in await database.select(database.savingsGoals).get())
            BackupRowCodecs.encodeSavingsGoal(row),
        ];
        tables['goalContributions'] = [
          for (final row
              in await database.select(database.goalContributions).get())
            BackupRowCodecs.encodeGoalContribution(row),
        ];
        tables['transactions'] = [
          for (final row in await database.select(database.transactions).get())
            BackupRowCodecs.encodeTransaction(row),
        ];
        tables['recurringTransactions'] = [
          for (final row
              in await database.select(database.recurringTransactions).get())
            BackupRowCodecs.encodeRecurringTransaction(row),
        ];
      }
      if (sections.contains(BackupSection.budgets)) {
        tables['budgets'] = [
          for (final row in await database.select(database.budgets).get())
            BackupRowCodecs.encodeBudget(row),
        ];
      }
      if (sections.contains(BackupSection.wishlist)) {
        tables['wishlistItems'] = [
          for (final row in await database.select(database.wishlistItems).get())
            BackupRowCodecs.encodeWishlistItem(row),
        ];
      }
      return tables;
    } catch (e, stackTrace) {
      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'read backup tables',
        entityName: 'backup',
      );
    }
  }

  @override
  Future<Map<String, int>> restoreTables(
    Map<String, List<Map<String, Object?>>> tables,
    Set<BackupSection> sections,
  ) async {
    // Decode every row before touching the database, so a malformed file
    // fails here with nothing written.
    final _Decoded rows;
    try {
      rows = _Decoded(tables, sections);
    } on FormatException catch (e) {
      throw BackupException(BackupError.corrupted, e);
    }

    try {
      return await database.transaction(() async {
        final written = <String, int>{};
        // Backup category id -> id to use locally (see _mergeCategories).
        final categoryIds = sections.contains(BackupSection.categories)
            ? await _mergeCategories(rows.categories)
            : <String, String>{};
        if (sections.contains(BackupSection.categories)) {
          written['categories'] = rows.categories.length;
        }
        String category(String id) => categoryIds[id] ?? id;

        if (sections.contains(BackupSection.money)) {
          // Children before parents: contributions don't cascade from goals.
          await database.delete(database.goalContributions).go();
          await database.delete(database.savingsGoals).go();
          await database.delete(database.recurringTransactions).go();
          await database.delete(database.transactions).go();
          await database.delete(database.accounts).go();

          await database.batch((batch) {
            batch.insertAll(database.accounts, rows.accounts);
            batch.insertAll(database.savingsGoals, rows.savingsGoals);
            batch.insertAll(database.goalContributions, rows.goalContributions);
            batch.insertAll(database.transactions, [
              for (final t in rows.transactions)
                t.copyWith(categoryId: Value(category(t.categoryId.value))),
            ]);
            batch.insertAll(database.recurringTransactions, [
              for (final r in rows.recurringTransactions)
                r.copyWith(categoryId: Value(category(r.categoryId.value))),
            ]);
          });
          written
            ..['accounts'] = rows.accounts.length
            ..['savingsGoals'] = rows.savingsGoals.length
            ..['goalContributions'] = rows.goalContributions.length
            ..['transactions'] = rows.transactions.length
            ..['recurringTransactions'] = rows.recurringTransactions.length;
        }

        if (sections.contains(BackupSection.budgets)) {
          await database.delete(database.budgets).go();
          await database.batch(
            (batch) => batch.insertAll(database.budgets, [
              for (final b in rows.budgets)
                b.copyWith(categoryId: Value(category(b.categoryId.value))),
            ]),
          );
          written['budgets'] = rows.budgets.length;
        }

        if (sections.contains(BackupSection.wishlist)) {
          // Links are optional - keep one only if its target exists now
          // (e.g. the item's goal wasn't part of this restore and isn't on
          // this device), instead of failing the whole restore.
          final existingCategories = {
            for (final c in await database.select(database.categories).get())
              c.id,
          };
          final existingGoals = {
            for (final g in await database.select(database.savingsGoals).get())
              g.id,
          };
          await database.delete(database.wishlistItems).go();
          await database.batch(
            (batch) => batch.insertAll(database.wishlistItems, [
              for (final item in rows.wishlistItems)
                item.copyWith(
                  categoryId: Value(switch (item.categoryId.value) {
                    final id? when existingCategories.contains(category(id)) =>
                      category(id),
                    _ => null,
                  }),
                  goalId: Value(
                    existingGoals.contains(item.goalId.value)
                        ? item.goalId.value
                        : null,
                  ),
                ),
            ]),
          );
          written['wishlistItems'] = rows.wishlistItems.length;
        }
        return written;
      });
    } catch (e, stackTrace) {
      if (e is DataException || e is BackupException) rethrow;
      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'restore backup',
        entityName: 'backup',
      );
    }
  }

  /// Categories are merged, never deleted. System categories (the seeded
  /// ones) get a fresh id on every install, so they're matched by nameKey
  /// and the backup's id is mapped onto this install's. User categories
  /// keep their id: inserted, or updated in place if already here.
  Future<Map<String, String>> _mergeCategories(
    List<CategoriesCompanion> categories,
  ) async {
    final localSystemByKey = {
      for (final c in await database.select(database.categories).get())
        if (c.origin == CategoryOrigin.system && c.nameKey != null)
          c.nameKey!: c.id,
    };
    final ids = <String, String>{};
    for (final category in categories) {
      final backupId = category.id.value;
      final localId = category.origin.value == CategoryOrigin.system
          ? localSystemByKey[category.nameKey.value]
          : null;
      if (localId != null) {
        ids[backupId] = localId;
      } else {
        await database
            .into(database.categories)
            .insertOnConflictUpdate(category);
        ids[backupId] = backupId;
      }
    }
    return ids;
  }
}

/// Every row of a backup decoded into insertable companions. Constructing
/// one throws [FormatException] on the first malformed row.
class _Decoded {
  _Decoded(
    Map<String, List<Map<String, Object?>>> tables,
    Set<BackupSection> sections,
  ) : categories = sections.contains(BackupSection.categories)
          ? _rows(tables, 'categories', BackupRowCodecs.decodeCategory)
          : const [],
      accounts = sections.contains(BackupSection.money)
          ? _rows(tables, 'accounts', BackupRowCodecs.decodeAccount)
          : const [],
      savingsGoals = sections.contains(BackupSection.money)
          ? _rows(tables, 'savingsGoals', BackupRowCodecs.decodeSavingsGoal)
          : const [],
      goalContributions = sections.contains(BackupSection.money)
          ? _rows(
              tables,
              'goalContributions',
              BackupRowCodecs.decodeGoalContribution,
            )
          : const [],
      transactions = sections.contains(BackupSection.money)
          ? _rows(tables, 'transactions', BackupRowCodecs.decodeTransaction)
          : const [],
      recurringTransactions = sections.contains(BackupSection.money)
          ? _rows(
              tables,
              'recurringTransactions',
              BackupRowCodecs.decodeRecurringTransaction,
            )
          : const [],
      budgets = sections.contains(BackupSection.budgets)
          ? _rows(tables, 'budgets', BackupRowCodecs.decodeBudget)
          : const [],
      wishlistItems = sections.contains(BackupSection.wishlist)
          ? _rows(tables, 'wishlistItems', BackupRowCodecs.decodeWishlistItem)
          : const [];

  final List<CategoriesCompanion> categories;
  final List<AccountsCompanion> accounts;
  final List<SavingsGoalsCompanion> savingsGoals;
  final List<GoalContributionsCompanion> goalContributions;
  final List<TransactionsCompanion> transactions;
  final List<RecurringTransactionsCompanion> recurringTransactions;
  final List<BudgetsCompanion> budgets;
  final List<WishlistItemsCompanion> wishlistItems;

  static List<T> _rows<T>(
    Map<String, List<Map<String, Object?>>> tables,
    String table,
    T Function(Map<String, Object?>) decode,
  ) {
    final rows = tables[table];
    if (rows == null) throw FormatException('Backup is missing $table');
    return [for (final row in rows) decode(row)];
  }
}
