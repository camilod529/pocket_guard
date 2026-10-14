import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/domain/entities/goal_contribution.dart';
import 'package:pocket_guard/domain/entities/savings_goal.dart';
import 'package:pocket_guard/infrastructure/data_sources/account_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/savings_goal_drift_data_source_impl.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/providers/savings_goal/savings_goals_provider.dart';
import 'package:pocket_guard/presentation/screens/goal_detail_screen.dart';

/// Pumps the real detail screen and drives the money-moving UI end to end.
/// Covers layout as much as logic: the account picker uses a LayoutBuilder,
/// which throws if a parent (e.g. AlertDialog's intrinsic sizing) asks it
/// for intrinsic dimensions - something no provider-level test can catch.
void main() {
  const accountId = 'checking';
  late AppDatabase testDb;
  late ProviderContainer container;
  late AppLocalizations l10n;
  late String goalId;

  setUp(() async {
    testDb = AppDatabase(NativeDatabase.memory());
    await testDb
        .into(testDb.accounts)
        .insert(
          AccountsCompanion.insert(
            id: const Value(accountId),
            name: 'Checking',
            currency: 'USD',
            balance: const Value(1000),
          ),
        );
    final dataSource = SavingsGoalDriftDataSourceImpl(database: testDb);
    await dataSource.createGoal(
      SavingsGoalEntity(
        id: 'unused',
        name: 'New Car',
        targetAmount: 5000,
        currency: 'USD',
        targetDate: null,
        isArchived: false,
        createdAt: DateTime(2026),
      ),
    );
    goalId = (await dataSource.getAllGoals()).single.id;

    container = ProviderContainer(
      overrides: [
        accountDataSourceProvider.overrideWith(
          (ref) => AccountDriftDataSourceImpl(database: testDb),
        ),
        savingsGoalDataSourceProvider.overrideWith((ref) => dataSource),
      ],
    );
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  tearDown(() async {
    container.dispose();
    await testDb.close();
  });

  Future<void> pumpDetail(WidgetTester tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('home')),
        ),
        GoRoute(
          path: '/goal/:id',
          builder: (context, state) =>
              GoalDetailScreen(goalId: state.pathParameters['id']!),
        ),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    router.push('/goal/$goalId');
    await tester.pumpAndSettle();
  }

  Future<void> pickAccount(WidgetTester tester) async {
    await tester.tap(find.byType(DropdownMenu<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Checking (USD)').last);
    await tester.pumpAndSettle();
  }

  testWidgets('adding money through the sheet moves it out of the account', (
    tester,
  ) async {
    await pumpDetail(tester);

    await tester.tap(find.widgetWithText(FilledButton, l10n.depositToGoal));
    await tester.pumpAndSettle();
    await pickAccount(tester);
    await tester.enterText(
      find.widgetWithText(TextFormField, l10n.contributionAmountLabel),
      '250',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, l10n.depositToGoal));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(await testDb.getAccountBalance(accountId), 750);
    expect(find.text(l10n.goalDepositSuccess), findsOneWidget);
    expect(find.text('Checking'), findsOneWidget); // history row
  });

  testWidgets('the sheet shows why a deposit was rejected', (tester) async {
    await pumpDetail(tester);

    await tester.tap(find.widgetWithText(FilledButton, l10n.depositToGoal));
    await tester.pumpAndSettle();
    await pickAccount(tester);
    await tester.enterText(
      find.widgetWithText(TextFormField, l10n.contributionAmountLabel),
      '5000',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, l10n.depositToGoal));
    await tester.pumpAndSettle();

    expect(find.text(l10n.goalErrorInsufficientAccountBalance), findsOneWidget);
    expect(await testDb.getAccountBalance(accountId), 1000);
  });

  testWidgets('deleting a funded goal asks for a refund account and returns '
      'the money', (tester) async {
    await container
        .read(savingsGoalsProvider.notifier)
        .addContribution(
          GoalContributionEntity(
            id: 'unused',
            goalId: goalId,
            accountId: accountId,
            amount: 400,
            date: DateTime(2026, 2),
          ),
        );
    await pumpDetail(tester);

    await tester.tap(find.byTooltip(l10n.delete));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(AlertDialog), findsOneWidget);

    // Delete stays disabled until a refund account is picked.
    final deleteButton = find.widgetWithText(FilledButton, l10n.delete);
    expect(tester.widget<FilledButton>(deleteButton).onPressed, isNull);

    await tester.tap(find.widgetWithText(RadioListTile<String>, 'Checking'));
    await tester.pumpAndSettle();
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    expect(await testDb.getAccountBalance(accountId), 1000);
    expect(await testDb.select(testDb.savingsGoals).get(), isEmpty);
    expect(find.text('home'), findsOneWidget);
  });
}
