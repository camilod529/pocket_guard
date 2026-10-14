import 'dart:typed_data';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/domain/data_sources/settings_data_source.dart';
import 'package:pocket_guard/domain/entities/backup.dart';
import 'package:pocket_guard/domain/entities/budget.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/domain/entities/goal_contribution.dart';
import 'package:pocket_guard/domain/entities/recurring_transaction.dart';
import 'package:pocket_guard/domain/entities/savings_goal.dart';
import 'package:pocket_guard/domain/entities/transaction.dart';
import 'package:pocket_guard/domain/entities/wishlist_item.dart';
import 'package:pocket_guard/infrastructure/data_sources/backup_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/budget_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/category_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/recurring_transaction_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/savings_goal_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/transaction_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/wishlist_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/repositories/backup_repository_impl.dart';

class _MemorySettings implements SettingsDataSource {
  String? locale;
  int? themeIndex;

  @override
  Future<String?> getLocale() async => locale;
  @override
  Future<int?> getThemeIndex() async => themeIndex;
  @override
  Future<void> saveLocale(String value) async => locale = value;
  @override
  Future<void> saveThemeIndex(int value) async => themeIndex = value;
}

/// One install: its own in-memory database (so its own seeded system
/// category ids) and settings.
class _Device {
  _Device()
    : db = AppDatabase(NativeDatabase.memory()),
      settings = _MemorySettings() {
    backups = BackupRepositoryImpl(
      dataSource: BackupDriftDataSourceImpl(database: db),
      settings: settings,
      iterations: 1000,
      // On, so the test proves everything sent to the isolate is sendable.
      runCodecInIsolate: true,
    );
  }

  final AppDatabase db;
  final _MemorySettings settings;
  late final BackupRepositoryImpl backups;

  Future<String> systemCategoryId(String nameKey) async => (await (db.select(
    db.categories,
  )..where((c) => c.nameKey.equals(nameKey))).getSingle()).id;

  Future<double> balance(String accountId) => db.getAccountBalance(accountId);
}

void main() {
  late _Device phone;
  late _Device newPhone;

  setUp(() {
    phone = _Device();
    newPhone = _Device();
  });

  tearDown(() async {
    await phone.db.close();
    await newPhone.db.close();
  });

  /// A realistic data set on [device], written through the real data
  /// sources so balances move exactly as in the app.
  Future<void> populate(_Device device) async {
    final db = device.db;
    for (final (id, name) in [
      ('checking', 'Checking'),
      ('savings', 'Savings'),
    ]) {
      await db
          .into(db.accounts)
          .insert(
            AccountsCompanion.insert(
              id: Value(id),
              name: name,
              currency: 'USD',
              balance: const Value(1000),
            ),
          );
    }
    final food = await device.systemCategoryId('category_expense_food_dining');
    final transfer = await device.systemCategoryId('category_transfer');
    await CategoryDriftDataSourceImpl(database: db).createCategory(
      CategoryEntity(
        id: 'unused',
        label: 'Pets',
        isSystem: false,
        type: TransactionType.expense,
      ),
    );
    final pets = (await (db.select(
      db.categories,
    )..where((c) => c.label.equals('Pets'))).getSingle()).id;

    final transactions = TransactionDriftDataSourceImpl(database: db);
    for (final (amount, category, to) in [
      (40.0, food, null),
      (25.0, pets, null),
      (200.0, transfer, 'savings'),
    ]) {
      await transactions.createTransaction(
        TransactionEntity(
          id: 'unused',
          amount: amount,
          description: 'tx $amount',
          categoryId: category,
          date: DateTime(2026, 9, 10, 18, 30),
          accountId: 'checking',
          toAccountId: to,
        ),
      );
    }
    await RecurringTransactionDriftDataSourceImpl(
      database: db,
    ).createRecurringTransaction(
      RecurringTransactionEntity(
        id: 'unused',
        accountId: 'checking',
        categoryId: food,
        amount: 15,
        description: 'Streaming',
        frequency: RecurrenceFrequency.monthly,
        startDate: DateTime(2026, 1, 1),
        nextDueDate: DateTime(2026, 11, 1),
        isActive: true,
      ),
    );
    final goals = SavingsGoalDriftDataSourceImpl(database: db);
    await goals.createGoal(
      SavingsGoalEntity(
        id: 'unused',
        name: 'Trip',
        targetAmount: 900,
        currency: 'USD',
        targetDate: DateTime(2027, 6, 1),
        isArchived: false,
        createdAt: DateTime(2026, 1, 1),
      ),
    );
    final goalId = (await goals.getAllGoals()).single.id;
    await goals.addContribution(
      GoalContributionEntity(
        id: 'unused',
        goalId: goalId,
        accountId: 'checking',
        amount: 300,
        date: DateTime(2026, 9, 1),
        note: 'first',
      ),
    );
    await BudgetDriftDataSourceImpl(database: db).createBudget(
      BudgetEntity(
        id: 'unused',
        categoryId: food,
        monthlyLimit: 250,
        currency: 'USD',
        isActive: true,
      ),
    );
    await WishlistDriftDataSourceImpl(database: db).createItem(
      WishlistItemEntity(
        id: 'unused',
        name: 'Camera',
        price: 500,
        currency: 'USD',
        categoryId: pets,
        goalId: goalId,
        purchasedAt: null,
        createdAt: DateTime(2026, 2, 1),
      ),
    );
    device.settings
      ..locale = 'fr'
      ..themeIndex = 4;
  }

  Matcher throwsBackupError(BackupError error) =>
      throwsA(isA<BackupException>().having((e) => e.error, 'error', error));

  test('everything moves to a new install, with system categories '
      'remapped onto its own ids', () async {
    await populate(phone);
    // checking: 1000 - 40 - 25 - 200 - 300 (goal) = 435; savings: 1200.
    expect(await phone.balance('checking'), 435);

    final file = await phone.backups.createBackup(
      BackupSection.values.toSet(),
      password: 'pw',
    );
    final contents = await newPhone.backups.readBackup(file, password: 'pw');
    expect(contents.manifest.counts, {
      'categories': 7,
      'accounts': 2,
      'savingsGoals': 1,
      'goalContributions': 1,
      'transactions': 3,
      'recurringTransactions': 1,
      'budgets': 1,
      'wishlistItems': 1,
    });

    await newPhone.backups.restore(contents, BackupSection.values.toSet());

    final db = newPhone.db;
    expect(await newPhone.balance('checking'), 435);
    expect(await newPhone.balance('savings'), 1200);

    // The new phone's own seeded "Food & Dining", not a duplicate.
    final food = await newPhone.systemCategoryId(
      'category_expense_food_dining',
    );
    expect(
      await db.select(db.categories).get(),
      hasLength(7), // 6 system + Pets
    );
    final txs = await db.select(db.transactions).get();
    expect(txs, hasLength(3));
    expect(txs.where((t) => t.categoryId == food), hasLength(1));
    expect(
      txs.firstWhere((t) => t.amount == 40).date,
      DateTime(2026, 9, 10, 18, 30),
    );
    expect(
      (await db.select(db.recurringTransactions).get()).single.categoryId,
      food,
    );
    expect((await db.select(db.budgets).get()).single.categoryId, food);

    final goal = (await db.select(db.savingsGoals).get()).single;
    expect(goal.targetDate, DateTime(2027, 6, 1));
    final contribution = (await db.select(db.goalContributions).get()).single;
    expect(contribution.goalId, goal.id);
    expect(contribution.note, 'first');

    final item = (await db.select(db.wishlistItems).get()).single;
    expect(item.goalId, goal.id);
    expect(
      (await (db.select(
        db.categories,
      )..where((c) => c.id.equals(item.categoryId!))).getSingle()).label,
      'Pets',
    );

    expect(newPhone.settings.locale, 'fr');
    expect(newPhone.settings.themeIndex, 4);
  });

  test('restoring money replaces what is there, including goals', () async {
    await populate(phone);
    final file = await phone.backups.createBackup({BackupSection.money});

    // Diverge after the backup: another expense, and a new goal.
    await TransactionDriftDataSourceImpl(database: phone.db).createTransaction(
      TransactionEntity(
        id: 'unused',
        amount: 100,
        description: 'after backup',
        categoryId: await phone.systemCategoryId('category_expense_rent'),
        date: DateTime(2026, 10, 1),
        accountId: 'checking',
      ),
    );
    expect(await phone.balance('checking'), 335);

    await phone.backups.restore(await phone.backups.readBackup(file), {
      BackupSection.money,
    });

    expect(await phone.balance('checking'), 435);
    expect(await phone.db.select(phone.db.transactions).get(), hasLength(3));
    expect(await phone.db.select(phone.db.savingsGoals).get(), hasLength(1));
  });

  test('restoring only some sections leaves the others alone', () async {
    await populate(phone);
    final file = await phone.backups.createBackup({BackupSection.budgets});
    await (phone.db.update(
      phone.db.budgets,
    )).write(const BudgetsCompanion(monthlyLimit: Value(999)));
    final transactionsBefore = await phone.db
        .select(phone.db.transactions)
        .get();

    await phone.backups.restore(await phone.backups.readBackup(file), {
      BackupSection.budgets,
    });

    expect(
      (await phone.db.select(phone.db.budgets).get()).single.monthlyLimit,
      250,
    );
    expect(
      await phone.db.select(phone.db.transactions).get(),
      hasLength(transactionsBefore.length),
    );
    expect(await phone.balance('checking'), 435);
  });

  test('exporting a section brings what it requires', () async {
    await populate(phone);
    final file = await phone.backups.createBackup({BackupSection.budgets});
    final contents = await phone.backups.readBackup(file);

    expect(contents.manifest.sections, {
      BackupSection.budgets,
      BackupSection.categories,
    });
    expect(contents.tables.keys, unorderedEquals(['budgets', 'categories']));
    expect(contents.settings, isEmpty);
  });

  test(
    'a wishlist restored without its goal keeps the item, unlinked',
    () async {
      await populate(phone);
      final file = await phone.backups.createBackup({BackupSection.wishlist});

      await newPhone.backups.restore(await newPhone.backups.readBackup(file), {
        BackupSection.wishlist,
      });

      final item =
          (await newPhone.db.select(newPhone.db.wishlistItems).get()).single;
      expect(item.name, 'Camera');
      expect(item.goalId, isNull); // no goals on the new phone
      expect(item.categoryId, isNotNull); // Pets came along with categories
    },
  );

  test('a restore that fails part-way changes nothing', () async {
    await populate(phone);
    await populate(newPhone);
    final file = await phone.backups.createBackup({BackupSection.money});
    final contents = await newPhone.backups.readBackup(file);
    // Point one transaction at a category that exists nowhere: the insert
    // fails after the old money data has already been deleted.
    contents.tables['transactions']!.first['categoryId'] = 'nonexistent';
    final before = await newPhone.db.select(newPhone.db.transactions).get();

    await expectLater(
      newPhone.backups.restore(contents, {BackupSection.money}),
      throwsA(anything),
    );

    expect(
      await newPhone.db.select(newPhone.db.transactions).get(),
      hasLength(before.length),
    );
    expect(await newPhone.balance('checking'), 435);
    expect(newPhone.settings.locale, 'fr'); // untouched by a failed restore
  });

  test('a malformed row is rejected before anything is written', () async {
    await populate(phone);
    final file = await phone.backups.createBackup({BackupSection.money});
    final contents = await phone.backups.readBackup(file);
    contents.tables['accounts']!.first['balance'] = 'lots';

    await expectLater(
      phone.backups.restore(contents, {BackupSection.money}),
      throwsBackupError(BackupError.corrupted),
    );
    expect(await phone.db.select(phone.db.accounts).get(), hasLength(2));
  });

  test('an empty install backs up and restores cleanly', () async {
    final Uint8List file = await phone.backups.createBackup(
      BackupSection.values.toSet(),
    );

    await newPhone.backups.restore(
      await newPhone.backups.readBackup(file),
      BackupSection.values.toSet(),
    );

    expect(await newPhone.db.select(newPhone.db.accounts).get(), isEmpty);
    expect(
      await newPhone.db.select(newPhone.db.categories).get(),
      hasLength(6),
    );
  });
}
