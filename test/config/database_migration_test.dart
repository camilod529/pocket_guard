import 'dart:io';

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

  /// Builds a current database, then rolls it back to what an install at
  /// [version] looks like by dropping [tablesAddedSince] and setting
  /// user_version. Seeds one account to prove existing data survives.
  Future<File> databaseAtVersion(
    int version,
    List<String> tablesAddedSince,
  ) async {
    final file = File('${tempDir.path}/db_v$version.sqlite');
    final seed = AppDatabase(NativeDatabase(file));
    await seed
        .into(seed.accounts)
        .insert(AccountsCompanion.insert(name: 'Checking', currency: 'USD'));
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
}
