import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_guard/config/database/database.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('pocket_guard_migration');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  // A pre-v10 transaction date: stored as epoch *milliseconds*.
  final legacyDate = DateTime(2026, 3, 15, 10, 30, 45, 678);

  /// Builds a current database, then rolls it back to what an install at
  /// [version] looks like by dropping [tablesAddedSince] and setting
  /// user_version. Seeds one account, plus one transaction whose date is
  /// written the pre-v10 way (raw epoch milliseconds), to prove existing
  /// data survives and dates get converted.
  Future<File> databaseAtVersion(
    int version,
    List<String> tablesAddedSince,
  ) async {
    final file = File('${tempDir.path}/db_v$version.sqlite');
    final seed = AppDatabase(NativeDatabase(file));
    await seed
        .into(seed.accounts)
        .insert(
          AccountsCompanion.insert(
            id: const Value('acc'),
            name: 'Checking',
            currency: 'USD',
          ),
        );
    final categoryId = (await seed.select(seed.categories).get()).first.id;
    await seed.customStatement(
      'INSERT INTO transactions (id, account_id, category_id, amount, date) '
      "VALUES ('tx', 'acc', ?, 12.5, ?)",
      [categoryId, legacyDate.millisecondsSinceEpoch],
    );
    for (final table in tablesAddedSince) {
      await seed.customStatement('DROP TABLE $table');
    }
    await seed.customStatement('PRAGMA user_version = $version');
    await seed.close();
    return file;
  }

  Future<void> expectUpgraded(File file, List<String> expectedObjects) async {
    final upgraded = AppDatabase(NativeDatabase(file));
    addTearDown(upgraded.close);

    final objects = await upgraded
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type IN ('table', 'index')",
        )
        .map((row) => row.read<String>('name'))
        .get();
    expect(objects, containsAll(expectedObjects));
    expect(await upgraded.select(upgraded.accounts).get(), hasLength(1));
    final transaction =
        (await upgraded.select(upgraded.transactions).get()).single;
    // Same moment, minus the milliseconds dateTime() doesn't store.
    expect(transaction.date, DateTime(2026, 3, 15, 10, 30, 45));
    expect(transaction.amount, 12.5);

    final version = await upgraded
        .customSelect('PRAGMA user_version')
        .map((row) => row.read<int>('user_version'))
        .getSingle();
    expect(version, upgraded.schemaVersion);
  }

  test('upgrading from v7 creates the savings goal and wishlist tables, '
      'keeping existing data', () async {
    // wishlist_items references savings_goals, so drop it first.
    final file = await databaseAtVersion(7, [
      'wishlist_items',
      'goal_contributions',
      'savings_goals',
    ]);

    await expectUpgraded(file, [
      'savings_goals',
      'goal_contributions',
      'goal_contributions_goal_index',
      'wishlist_items',
    ]);
  });

  test('upgrading from v8 creates the wishlist table', () async {
    final file = await databaseAtVersion(8, ['wishlist_items']);

    await expectUpgraded(file, ['wishlist_items']);
  });

  test('upgrading from v9 converts transaction dates from milliseconds '
      'to dateTime()', () async {
    final file = await databaseAtVersion(9, []);

    await expectUpgraded(file, ['transactions']);
  });
}
