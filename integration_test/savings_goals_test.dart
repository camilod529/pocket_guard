import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/main.dart' as app;

/// Walks the real app on a device through the Savings Goals feature,
/// screenshotting each step. Run with:
/// ```
/// flutter drive --driver=test_driver/integration_test.dart \
///   --target=integration_test/savings_goals_test.dart -d <device>
/// ```
/// Uses the app's real on-device database: it seeds (or resets) an
/// "e2e-checking" account to 1000 USD and leaves it behind - run it on a
/// simulator, not a phone with real data.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('savings goal end to end', (tester) async {
    // Seed one account straight into the app's real database - the account
    // form isn't what's under test here.
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
    Future<double> balance() => database.getAccountBalance('e2e-checking');

    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    final l10n = AppLocalizations.of(tester.element(find.byType(Scaffold).first))!;

    var step = 0;
    Future<void> shot(String name) async {
      await tester.pumpAndSettle();
      await binding.takeScreenshot('${(++step).toString().padLeft(2, '0')}_$name');
    }

    Future<void> tapText(String text) async {
      await tester.tap(find.text(text).last);
      await tester.pumpAndSettle();
    }

    Future<void> pickCheckingInSheet() async {
      await tester.tap(find.byType(DropdownMenu<String>).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Checking (USD)').last);
      await tester.pumpAndSettle();
    }

    Future<void> moveMoney({required bool withdraw, required String amount}) async {
      await tester.tap(
        find.widgetWithText(
          withdraw ? OutlinedButton : FilledButton,
          withdraw ? l10n.withdrawFromGoal : l10n.depositToGoal,
        ),
      );
      await tester.pumpAndSettle();
      await pickCheckingInSheet();
      await tester.enterText(
        find.widgetWithText(TextFormField, l10n.contributionAmountLabel),
        amount,
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(
          ElevatedButton,
          withdraw ? l10n.withdrawFromGoal : l10n.depositToGoal,
        ),
      );
      await tester.pumpAndSettle();
    }

    // --- Open Savings Goals from More ---
    await tapText(l10n.more);
    await shot('more_screen');
    await tapText(l10n.goals);
    await shot('goals_empty');

    // --- Create a goal with a target date next month ---
    await tester.tap(find.byTooltip(l10n.addGoal));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, l10n.goalNameLabel),
      'New Car',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, l10n.goalTargetAmountLabel),
      '2000',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tapText(l10n.goalTargetDateLabel);
    await tester.tap(
      find.byTooltip(
        MaterialLocalizations.of(
          tester.element(find.byType(DatePickerDialog)),
        ).nextMonthTooltip,
      ),
    );
    await tester.pumpAndSettle();
    await tapText('15');
    await tapText(
      MaterialLocalizations.of(
        tester.element(find.byType(DatePickerDialog)),
      ).okButtonLabel,
    );
    await shot('goal_form_filled');
    await tester.tap(find.widgetWithText(ElevatedButton, l10n.createGoalButton));
    await tester.pumpAndSettle();
    expect(find.text('New Car'), findsOneWidget);
    await shot('goals_list_new_goal');

    // --- Detail: deposit 300 ---
    await tapText('New Car');
    await shot('goal_detail_empty');
    await moveMoney(withdraw: false, amount: '300');
    expect(find.text(l10n.goalDepositSuccess), findsOneWidget);
    expect(await balance(), 700);
    await shot('after_deposit_300');

    // --- Overdraw is rejected with a reason, nothing moves ---
    await moveMoney(withdraw: false, amount: '5000');
    expect(find.text(l10n.goalErrorInsufficientAccountBalance), findsOneWidget);
    await shot('overdraw_rejected');
    expect(await balance(), 700);
    await tester.tapAt(const Offset(20, 80)); // dismiss the sheet
    await tester.pumpAndSettle();

    // --- Withdraw 100 back ---
    await moveMoney(withdraw: true, amount: '100');
    expect(find.text(l10n.goalWithdrawSuccess), findsOneWidget);
    expect(await balance(), 800);
    await shot('after_withdraw_100');

    // --- Edit: rename, and the detail title follows ---
    await tester.tap(find.byTooltip(l10n.edit));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, l10n.goalNameLabel),
      'Used Car',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text(l10n.goalCurrencyLockedHint), findsOneWidget);
    await shot('edit_form_currency_locked');
    await tester.tap(find.widgetWithText(ElevatedButton, l10n.updateGoalButton));
    await tester.pumpAndSettle();
    expect(find.text('Used Car'), findsWidgets);
    await shot('detail_after_rename');

    // --- Accounts tab reflects the money in the jar ---
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tapText(l10n.accounts);
    expect(find.text('USD800.00'), findsOneWidget);
    await shot('accounts_balance_800');

    // --- Delete with refund ---
    await tapText(l10n.more);
    await tapText(l10n.goals);
    await tapText('Used Car');
    await tester.tap(find.byTooltip(l10n.delete));
    await tester.pumpAndSettle();
    await shot('refund_dialog');
    await tester.tap(find.widgetWithText(RadioListTile<String>, 'Checking'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, l10n.delete));
    await tester.pumpAndSettle();
    // Only this test's goal - others (e.g. wishlist_test's) may exist.
    expect(find.text('Used Car'), findsNothing);
    expect(await balance(), 1000);
    await shot('goal_deleted_refunded');

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tapText(l10n.accounts);
    expect(find.text('USD1,000.00'), findsOneWidget);
    await shot('accounts_balance_restored');
  });
}
