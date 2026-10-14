import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/infrastructure/data_sources/account_drift_data_source_impl.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/views/account_view.dart';
import 'package:pocket_guard/utils/shared/number_formatting.dart';

void main() {
  testWidgets('each account row shows its balance', (tester) async {
    final testDb = AppDatabase(NativeDatabase.memory());
    addTearDown(testDb.close);
    for (final (name, balance) in [('Checking', 1234.5), ('Card', -80.0)]) {
      await testDb
          .into(testDb.accounts)
          .insert(
            AccountsCompanion.insert(
              name: name,
              currency: 'USD',
              balance: Value(balance),
            ),
          );
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountDataSourceProvider.overrideWith(
            (ref) => AccountDriftDataSourceImpl(database: testDb),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AccountView(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(NumberFormatting.formatCurrencyWithSymbol(1234.5, 'USD')),
      findsOneWidget,
    );
    final negative = tester.widget<Text>(
      find.text(NumberFormatting.formatCurrencyWithSymbol(-80, 'USD')),
    );
    expect(
      negative.style?.color,
      Theme.of(tester.element(find.byType(AccountView))).colorScheme.error,
    );
  });
}
