import 'dart:io';
import 'dart:typed_data';

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
import 'package:pocket_guard/presentation/screens/backup_screen.dart';

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

/// A .pgbackup the OS opened with the app lands on BackupScreen with its
/// path; from there it must go through the same unlock/preview flow as a
/// picked file, and the app's temp copy must be cleaned up.
void main() {
  late AppDatabase db;
  late BackupRepositoryImpl repository;
  late Directory tempDir;
  late AppLocalizations l10n;
  BackupContents? previewed;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = BackupRepositoryImpl(
      dataSource: BackupDriftDataSourceImpl(database: db),
      settings: _NoSettings(),
      iterations: 1000,
      runCodecInIsolate: false,
    );
    tempDir = await Directory.systemTemp.createTemp('incoming');
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
    previewed = null;
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  Future<String> writeFile(List<int> bytes) async {
    final file = File('${tempDir.path}/incoming-test.pgbackup');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  /// The screen reads the file after its first frame. Each step of real
  /// file I/O completes on the real event loop but continues in the test's
  /// fake-async zone, so alternate between the two a few times.
  Future<void> letRealIoFinish(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
    }
    await tester.pumpAndSettle();
  }

  Future<void> open(WidgetTester tester, String path) async {
    final router = GoRouter(
      initialLocation: '/backup',
      routes: [
        GoRoute(
          path: '/backup',
          builder: (context, state) => BackupScreen(incomingFilePath: path),
        ),
        GoRoute(
          path: '/backup/restore',
          builder: (context, state) {
            previewed = state.extra! as BackupContents;
            return const Scaffold(body: Text('preview'));
          },
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [backupRepositoryProvider.overrideWith((ref) => repository)],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await letRealIoFinish(tester);
  }

  testWidgets('an unencrypted backup goes straight to the preview', (
    tester,
  ) async {
    late String path;
    await tester.runAsync(() async {
      path = await writeFile(
        await repository.createBackup({BackupSection.categories}),
      );
    });

    await open(tester, path);

    expect(find.text('preview'), findsOneWidget);
    expect(previewed!.manifest.sections, {BackupSection.categories});
    expect(File(path).existsSync(), isFalse, reason: 'temp copy removed');
  });

  testWidgets('an encrypted backup asks for its password first', (
    tester,
  ) async {
    late String path;
    await tester.runAsync(() async {
      path = await writeFile(
        await repository.createBackup({
          BackupSection.categories,
        }, password: 'pw'),
      );
    });

    await open(tester, path);

    expect(find.text(l10n.backupPasswordPromptTitle), findsOneWidget);
    expect(find.text('preview'), findsNothing);

    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      'pw',
    );
    await tester.tap(
      find.widgetWithText(FilledButton, l10n.backupUnlockButton),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pumpAndSettle();

    expect(find.text('preview'), findsOneWidget);
  });

  testWidgets('a file that isn\'t a backup says so and goes nowhere', (
    tester,
  ) async {
    late String path;
    await tester.runAsync(() async {
      path = await writeFile(Uint8List.fromList('hello'.codeUnits));
    });

    await open(tester, path);

    expect(find.text(l10n.backupErrorNotABackup), findsOneWidget);
    expect(find.text('preview'), findsNothing);
    expect(File(path).existsSync(), isFalse);
  });
}
