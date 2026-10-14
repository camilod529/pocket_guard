import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/config/router/router.dart';
import 'package:pocket_guard/config/router/routes.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/domain/entities/transaction.dart';
import 'package:pocket_guard/infrastructure/backup/backup_file_codec.dart';
import 'package:pocket_guard/infrastructure/data_sources/transaction_drift_data_source_impl.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/main.dart' as app;
import 'package:pocket_guard/presentation/screens/backup_restore_screen.dart';

/// Backup and restore on a device. The share sheet and the file picker are
/// system UI a Flutter test can't operate, so this:
///   1. drives the backup screen for real up to the share sheet (capture
///      it from the host with `xcrun simctl io booted screenshot`), then
///   2. reads back the .pgbackup file the app actually wrote, changes the
///      data, and drives the restore screen with it.
/// Run with:
/// ```
/// flutter drive --driver=test_driver/integration_test.dart \
///   --target=integration_test/backup_test.dart -d <device>
/// ```
/// Uses the app's real on-device database: run it on a simulator.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('backup and restore end to end', (tester) async {
    // --- Seed: one account with one transaction ---
    await database
        .into(database.accounts)
        .insert(
          AccountsCompanion.insert(
            id: const Value('e2e-checking'),
            name: 'Checking',
            currency: 'USD',
            balance: const Value(1000),
          ),
          mode: InsertMode.insertOrReplace,
        );
    await (database.delete(
      database.transactions,
    )..where((t) => t.description.equals('E2E backup lunch'))).go();
    final food = await (database.select(
      database.categories,
    )..where((c) => c.type.equalsValue(TransactionType.expense))).get();
    await TransactionDriftDataSourceImpl().createTransaction(
      TransactionEntity(
        id: 'unused',
        amount: 30,
        description: 'E2E backup lunch',
        categoryId: food.first.id,
        date: DateTime.now(),
        accountId: 'e2e-checking',
      ),
    );
    Future<double> balance() => database.getAccountBalance('e2e-checking');
    expect(await balance(), 970);

    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    final l10n = AppLocalizations.of(
      tester.element(find.byType(Scaffold).first),
    )!;

    var step = 0;
    Future<void> shot(String name) async {
      await tester.pumpAndSettle();
      await binding.takeScreenshot(
        'backup_${(++step).toString().padLeft(2, '0')}_$name',
      );
    }

    // --- Backup screen ---
    await tester.tap(find.text(l10n.more).last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text(l10n.backupAndRestore),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text(l10n.backupAndRestore));
    await tester.pumpAndSettle();
    await shot('backup_screen');

    // Untick settings; categories stay locked by money/budgets/wishlist.
    await tester.tap(find.text(l10n.backupSectionSettings));
    await tester.pumpAndSettle();
    final categories = tester.widget<CheckboxListTile>(
      find.widgetWithText(CheckboxListTile, l10n.backupSectionCategories),
    );
    expect(categories.value, isTrue);
    expect(categories.onChanged, isNull);

    await tester.enterText(
      find.widgetWithText(TextFormField, l10n.backupPasswordLabel),
      'e2e-secret',
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, l10n.backupPasswordConfirmLabel),
      'e2e-secret',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text(l10n.backupPasswordWarning), findsOneWidget);
    await shot('options_filled');

    // Creates the file (PBKDF2 runs in an isolate), then opens the share
    // sheet - which stays up; the test doesn't wait on it.
    final createButton = find.widgetWithText(
      FilledButton,
      l10n.createBackupButton,
    );
    await tester.ensureVisible(createButton);
    await tester.pumpAndSettle();
    await tester.tap(createButton);
    final dir = await getTemporaryDirectory();
    final now = DateTime.now();
    final file = File(
      '${dir.path}/PocketGuard-${now.year}-'
      '${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}.${BackupFileCodec.fileExtension}',
    );
    for (var i = 0; i < 40 && !file.existsSync(); i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    expect(file.existsSync(), isTrue, reason: 'the app wrote the backup');
    // Give the share sheet time to appear for a host-side screenshot.
    await tester.pump(const Duration(seconds: 6));

    // From here on the share sheet is still up over the app (a user would
    // close it first), so the backup screen's spinner keeps animating
    // underneath and pumpAndSettle would never return: pump fixed time.
    Future<void> settle() => tester.pump(const Duration(milliseconds: 800));
    Future<void> shotNow(String name) async {
      await settle();
      await binding.takeScreenshot(
        'backup_${(++step).toString().padLeft(2, '0')}_$name',
      );
    }

    // --- The written file: encrypted, and decodes with the password ---
    final bytes = await file.readAsBytes();
    final codec = BackupFileCodec();
    expect(codec.isEncrypted(bytes), isTrue);
    final contents = await codec.decode(bytes, password: 'e2e-secret');
    expect(
      contents.tables['transactions']!.map((t) => t['description']),
      contains('E2E backup lunch'),
    );
    expect(contents.settings, isEmpty);

    // --- Change the data after the backup ---
    await (database.delete(
      database.transactions,
    )..where((t) => t.description.equals('E2E backup lunch'))).go();
    await (database.update(database.accounts)
          ..where((a) => a.id.equals('e2e-checking')))
        .write(const AccountsCompanion(balance: Value(5)));
    expect(await balance(), 5);

    // --- Restore screen, as reached after picking the file ---
    appRouter.push(Routes.backupRestore, extra: contents);
    await settle();
    // Scoped: the backup screen (which lists Settings) is still underneath.
    expect(
      find.descendant(
        of: find.byType(BackupRestoreScreen),
        matching: find.text(l10n.backupSectionSettings),
      ),
      findsNothing,
    );
    await shotNow('restore_screen');

    await tester.tap(find.widgetWithText(FilledButton, l10n.restoreButton));
    await settle();
    await shotNow('restore_confirm');
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, l10n.restoreButton),
      ),
    );
    for (var i = 0; i < 20 && await balance() != 970; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    await settle();

    expect(await balance(), 970);
    final restored = await (database.select(
      database.transactions,
    )..where((t) => t.description.equals('E2E backup lunch'))).get();
    expect(restored, hasLength(1));
    expect(find.text(l10n.restoreSuccess), findsOneWidget);
    await shotNow('restored');

    // The Accounts screen reflects it (providers were invalidated).
    appRouter.go(Routes.accounts);
    await settle();
    expect(find.text('USD970.00'), findsOneWidget);
    await shotNow('accounts_after_restore');
  });
}
