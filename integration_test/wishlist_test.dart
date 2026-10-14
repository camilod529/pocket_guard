import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/domain/entities/goal_contribution.dart';
import 'package:pocket_guard/domain/entities/savings_goal.dart';
import 'package:pocket_guard/infrastructure/data_sources/savings_goal_drift_data_source_impl.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/main.dart' as app;

/// Walks the real app on a device through the Wishlist, including buying
/// an item with money from a savings jar. Run with:
/// ```
/// flutter drive --driver=test_driver/integration_test.dart \
///   --target=integration_test/wishlist_test.dart -d <device>
/// ```
/// Uses the app's real on-device database: it resets an "e2e-checking"
/// account and replaces any "E2E ..." goals/items, and leaves a purchase
/// transaction behind - run it on a simulator, not a phone with real data.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('wishlist end to end', (tester) async {
    // --- Seed: 1000 USD account, 300 of it moved into an "E2E Tech" jar ---
    await (database.delete(
      database.wishlistItems,
    )..where((t) => t.name.like('E2E %'))).go();
    final oldGoals = await (database.select(
      database.savingsGoals,
    )..where((t) => t.name.like('E2E %'))).get();
    for (final goal in oldGoals) {
      await (database.delete(
        database.goalContributions,
      )..where((t) => t.goalId.equals(goal.id))).go();
      await (database.delete(
        database.savingsGoals,
      )..where((t) => t.id.equals(goal.id))).go();
    }
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
    final goals = SavingsGoalDriftDataSourceImpl();
    await goals.createGoal(
      SavingsGoalEntity(
        id: 'unused',
        name: 'E2E Tech',
        targetAmount: 1000,
        currency: 'USD',
        targetDate: null,
        isArchived: false,
        createdAt: DateTime.now(),
      ),
    );
    final goalId = (await goals.getAllGoals())
        .firstWhere((g) => g.name == 'E2E Tech')
        .id;
    await goals.addContribution(
      GoalContributionEntity(
        id: 'unused',
        goalId: goalId,
        accountId: 'e2e-checking',
        amount: 300,
        date: DateTime.now(),
      ),
    );
    Future<double> balance() => database.getAccountBalance('e2e-checking');
    Future<double> saved() async =>
        (await goals.getSavedAmounts())[goalId] ?? 0;
    expect(await balance(), 700);

    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    final l10n = AppLocalizations.of(
      tester.element(find.byType(Scaffold).first),
    )!;

    var step = 0;
    Future<void> shot(String name) async {
      await tester.pumpAndSettle();
      await binding.takeScreenshot(
        'wishlist_${(++step).toString().padLeft(2, '0')}_$name',
      );
    }

    Future<void> tapText(String text) async {
      await tester.tap(find.text(text).last);
      await tester.pumpAndSettle();
    }

    Future<void> addItem(String name, String price, {String? goal}) async {
      await tester.tap(find.byTooltip(l10n.addWishlistItem));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, l10n.wishlistItemNameLabel),
        name,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, l10n.wishlistPriceLabel),
        price,
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      if (goal != null) {
        await tester.tap(
          // .first: the floating label renders twice inside the menu.
          find
              .widgetWithText(DropdownMenu<String>, l10n.wishlistGoalLabel)
              .first,
        );
        await tester.pumpAndSettle();
        await tapText(goal);
        await shot('form_${name.split(' ').last.toLowerCase()}');
      }
      await tester.tap(
        find.widgetWithText(ElevatedButton, l10n.createWishlistItemButton),
      );
      await tester.pumpAndSettle();
    }

    Finder buyButtonFor(String name) => find.descendant(
      of: find.ancestor(of: find.text(name), matching: find.byType(Card)),
      matching: find.widgetWithText(FilledButton, l10n.buyWishlistItem),
    );

    // --- Open the Wishlist from More ---
    await tapText(l10n.more);
    await shot('more_screen');
    await tapText(l10n.wishlist);
    await shot('wishlist_start');

    // --- An item the linked jar fully covers ---
    await addItem('E2E Headphones', '250', goal: 'E2E Tech');
    expect(find.text(l10n.wishlistCoveredByGoal('E2E Tech')), findsOneWidget);

    // --- An item there isn't enough money for: Buy is disabled ---
    await addItem('E2E Laptop', '2000');
    expect(
      find.text(l10n.wishlistInsufficientFunds('USD1,300.00')),
      findsOneWidget,
    );
    expect(
      tester.widget<FilledButton>(buyButtonFor('E2E Laptop')).onPressed,
      isNull,
    );
    await shot('verdicts');

    // --- Buy the headphones with the jar's money ---
    await tester.tap(buyButtonFor('E2E Headphones'));
    await tester.pumpAndSettle();
    await shot('use_savings_dialog');
    await tester.tap(find.widgetWithText(RadioListTile<String>, 'Checking'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(FilledButton, l10n.wishlistUseGoalConfirm),
    );
    await tester.pumpAndSettle();

    // Jar paid the account; the prefilled form hasn't been saved yet.
    expect(await saved(), 50);
    expect(await balance(), 950);
    expect(find.text('E2E Headphones'), findsOneWidget);
    expect(find.text('250.00'), findsOneWidget);
    await shot('prefilled_transaction');

    // The item has no category, so the form (correctly) waits for one.
    await tester.tap(
      find.widgetWithText(DropdownMenu<String>, l10n.categoryLabel).first,
    );
    await tester.pumpAndSettle();
    await tapText('Food & Dining');

    final save = find.widgetWithText(
      ElevatedButton,
      l10n.createTransactionButton,
    );
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(await balance(), 700);
    expect(find.text(l10n.wishlistPurchasedSection), findsOneWidget);
    expect(buyButtonFor('E2E Headphones'), findsNothing);
    await shot('after_purchase');

    // --- Accounts shows the same 700 ---
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tapText(l10n.accounts);
    expect(find.text('USD700.00'), findsOneWidget);
    await shot('accounts_after_purchase');

    // --- Insights: Checking's balance trend ends at today's 700 ---
    await tapText(l10n.calendar);
    await tester.tap(find.byIcon(Icons.bar_chart_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Checking'));
    await tester.pumpAndSettle();
    // The page (first scroll view) - the chip rows scroll sideways too.
    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -300),
    );
    expect(find.text(l10n.balanceTrend), findsOneWidget);
    await shot('insights_balance_trend');
  });
}
