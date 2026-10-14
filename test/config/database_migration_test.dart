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

  test('upgrading from v7 creates the savings goal tables and index, '
      'keeping existing data', () async {
    final file = File('${tempDir.path}/db.sqlite');

    // Build a current database, then roll it back to what a v7 install
    // looks like: no goal tables, user_version 7.
    final seed = AppDatabase(NativeDatabase(file));
    await seed
        .into(seed.accounts)
        .insert(AccountsCompanion.insert(name: 'Checking', currency: 'USD'));
    await seed.customStatement('DROP TABLE goal_contributions');
    await seed.customStatement('DROP TABLE savings_goals');
    await seed.customStatement('PRAGMA user_version = 7');
    await seed.close();

    final upgraded = AppDatabase(NativeDatabase(file));
    addTearDown(upgraded.close);

    final tables = await upgraded
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type IN ('table', 'index')",
        )
        .map((row) => row.read<String>('name'))
        .get();
    expect(
      tables,
      containsAll([
        'savings_goals',
        'goal_contributions',
        'goal_contributions_goal_index',
      ]),
    );
    expect(await upgraded.select(upgraded.accounts).get(), hasLength(1));

    final version = await upgraded
        .customSelect('PRAGMA user_version')
        .map((row) => row.read<int>('user_version'))
        .getSingle();
    expect(version, 8);
  });
}
