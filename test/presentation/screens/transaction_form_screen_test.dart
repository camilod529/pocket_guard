import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/domain/entities/transaction.dart';
import 'package:pocket_guard/infrastructure/data_sources/account_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/category_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/transaction_drift_data_source_impl.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/providers/category/categories_provider.dart';
import 'package:pocket_guard/presentation/providers/transaction/transaction_form_provider.dart';
import 'package:pocket_guard/presentation/providers/transaction/transactions_provider.dart';
import 'package:pocket_guard/presentation/screens/transaction_form_screen.dart';

/// Reproduces a manual-testing report: editing an existing transfer A -> B
/// into A -> A leaves the Save button disabled (isFormValid correctly goes
/// false) but showed no error explaining why, because the error text was
/// gated on isFormPure, which is only set by _touchAllFields() inside
/// onFormSubmit - and a disabled button can never be tapped to reach it.
void main() {
  const checkingId = 'checking';
  const savingsId = 'savings';

  testWidgets(
    'selecting the same account for from/to on an existing transfer shows '
    'the error immediately, without needing a submit attempt first',
    (tester) async {
      final testDb = AppDatabase(NativeDatabase.memory());
      addTearDown(testDb.close);

      await testDb
          .into(testDb.accounts)
          .insert(
            AccountsCompanion.insert(
              id: const Value(checkingId),
              name: 'Checking',
              currency: 'USD',
              balance: const Value(1000),
            ),
          );
      await testDb
          .into(testDb.accounts)
          .insert(
            AccountsCompanion.insert(
              id: const Value(savingsId),
              name: 'Savings',
              currency: 'USD',
              balance: const Value(1000),
            ),
          );

      final container = ProviderContainer(
        overrides: [
          accountDataSourceProvider.overrideWith(
            (ref) => AccountDriftDataSourceImpl(database: testDb),
          ),
          categoryDataSourceProvider.overrideWith(
            (ref) => CategoryDriftDataSourceImpl(database: testDb),
          ),
          transactionDataSourceProvider.overrideWith(
            (ref) => TransactionDriftDataSourceImpl(database: testDb),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Seed an existing transfer Checking -> Savings via the data source
      // directly, then load the edit form for it exactly like the app
      // would when navigating in from the transaction list.
      final categories = await container.read(categoriesProvider.future);
      final transferCategoryId = categories
          .firstWhere((c) => c.type == TransactionType.transfer)
          .id;
      await container
          .read(transactionDataSourceProvider)
          .createTransaction(
            TransactionEntity(
              id: 'unused',
              description: 'Initial transfer',
              accountId: checkingId,
              toAccountId: savingsId,
              amount: 100,
              date: DateTime(2026),
              categoryId: transferCategoryId,
            ),
          );
      final txId = (await testDb.select(testDb.transactions).get()).single.id;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: TransactionFormScreen(transactionId: txId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      // Save starts disabled (nothing edited yet) - make a valid edit
      // first so the button is actually enabled and comparable to what
      // happens after the invalid one below.
      container
          .read(transactionFormProvider(txId).notifier)
          .amountChanged(150);
      await tester.pump();

      expect(find.text(l10n.sameTransferAccountError), findsNothing);
      expect(
        tester
            .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, l10n.updateTransactionButton),
            )
            .onPressed,
        isNotNull,
        reason: 'a valid edit should leave Save enabled',
      );

      // Point "to" at the same account as "from", the way the dropdown
      // would after the exclusion-filtering fix (it's no longer prevented
      // from being selected, that's the point - it must be caught by
      // validation instead).
      container
          .read(transactionFormProvider(txId).notifier)
          .toAccountChanged(checkingId);
      await tester.pump();

      expect(
        find.text(l10n.sameTransferAccountError),
        findsOneWidget,
        reason:
            'the error must be visible immediately, not only after a '
            'submit attempt the disabled button can no longer trigger',
      );
      expect(
        tester
            .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, l10n.updateTransactionButton),
            )
            .onPressed,
        isNull,
        reason: 'Save must be disabled while from/to are the same account',
      );
    },
  );
}
