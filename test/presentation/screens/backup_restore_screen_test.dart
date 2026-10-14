import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/domain/data_sources/settings_data_source.dart';
import 'package:pocket_guard/domain/entities/backup.dart';
import 'package:pocket_guard/infrastructure/data_sources/backup_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/repositories/backup_repository_impl.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/providers/backup/backup_provider.dart';
import 'package:pocket_guard/presentation/screens/backup_restore_screen.dart';

class _NoSettings implements SettingsDataSource {
  @override
  Future<String?> getLocale() async => null;
  @override
  Future<int?> getThemeIndex() async => null;
  @override
  Future<void> saveLocale(String locale) async {}
  @override
  Future<void> saveThemeIndex(int index) async {}
}

void main() {
  testWidgets('shows what the backup holds, locks required sections, and '
      'restores after confirmation', (tester) async {
    late AppDatabase source;
    late AppDatabase target;
    late BackupContents contents;
    late BackupRepositoryImpl targetRepository;
    // Real database I/O, outside the widget tester's fake async zone.
    await tester.runAsync(() async {
      source = AppDatabase(NativeDatabase.memory());
      target = AppDatabase(NativeDatabase.memory());
      for (final name in ['Checking', 'Savings']) {
        await source
            .into(source.accounts)
            .insert(
              AccountsCompanion.insert(
                name: name,
                currency: 'USD',
                balance: const Value(50),
              ),
            );
      }
      BackupRepositoryImpl repo(AppDatabase db) => BackupRepositoryImpl(
        dataSource: BackupDriftDataSourceImpl(database: db),
        settings: _NoSettings(),
        iterations: 1000,
        runCodecInIsolate: false,
      );
      final file = await repo(
        source,
      ).createBackup({BackupSection.money, BackupSection.budgets});
      targetRepository = repo(target);
      contents = await targetRepository.readBackup(file);
    });
    addTearDown(() async {
      await source.close();
      await target.close();
    });

    final router = GoRouter(
      initialLocation: '/restore',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('home')),
          routes: [
            GoRoute(
              path: 'restore',
              builder: (context, state) =>
                  BackupRestoreScreen(contents: contents),
            ),
          ],
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          backupRepositoryProvider.overrideWith((ref) => targetRepository),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    // Only what the file holds is offered: no wishlist or settings.
    expect(find.text(l10n.backupSectionMoney), findsOneWidget);
    expect(find.text(l10n.backupSectionBudgets), findsOneWidget);
    expect(find.text(l10n.backupSectionCategories), findsOneWidget);
    expect(find.text(l10n.backupSectionWishlist), findsNothing);
    expect(find.text(l10n.backupSectionSettings), findsNothing);
    // 2 accounts and nothing else in the money tables.
    expect(find.textContaining(l10n.backupItemCount(2)), findsOneWidget);

    CheckboxListTile tile(String title) => tester.widget<CheckboxListTile>(
      find.widgetWithText(CheckboxListTile, title),
    );
    // Categories are needed by money and budgets: checked and locked.
    expect(tile(l10n.backupSectionCategories).value, isTrue);
    expect(tile(l10n.backupSectionCategories).onChanged, isNull);

    // The backup has no budgets: not pre-ticked, since restoring an empty
    // section would wipe this device's budgets. It can still be ticked.
    expect(tile(l10n.backupSectionBudgets).value, isFalse);
    expect(tile(l10n.backupSectionBudgets).onChanged, isNotNull);
    expect(tile(l10n.backupSectionMoney).value, isTrue);

    await tester.tap(find.widgetWithText(FilledButton, l10n.restoreButton));
    await tester.pumpAndSettle();
    expect(find.text(l10n.restoreConfirmTitle), findsOneWidget);

    // Nothing is written before confirming.
    await tester.runAsync(() async {
      expect(await target.select(target.accounts).get(), isEmpty);
    });

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, l10n.restoreButton),
      ),
    );
    // Let the real restore run, then the UI settle.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      expect(await target.select(target.accounts).get(), hasLength(2));
    });
    expect(find.text(l10n.restoreSuccess), findsOneWidget);
    expect(find.text('home'), findsOneWidget);
  });
}
