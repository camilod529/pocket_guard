import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/infrastructure/data_sources/account_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/category_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/transaction_drift_data_source_impl.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/providers/category/categories_provider.dart';
import 'package:pocket_guard/presentation/providers/transaction/transaction_prefill.dart';
import 'package:pocket_guard/presentation/providers/transaction/transactions_provider.dart';
import 'package:pocket_guard/presentation/screens/transaction_form_screen.dart';
import 'package:pocket_guard/utils/constants/global_constants.dart';

/// The wishlist purchase flow depends on two things from the transaction
/// form: prefilled values must actually show up in the fields (they read
/// initialValue only once), and a successful save must pop with `true`.
void main() {
  testWidgets('prefilled values show in the form, and saving pops true', (
    tester,
  ) async {
    final testDb = AppDatabase(NativeDatabase.memory());
    addTearDown(testDb.close);
    await testDb
        .into(testDb.accounts)
        .insert(
          AccountsCompanion.insert(
            id: const Value('checking'),
            name: 'Checking',
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
    final categoryId = (await container.read(
      categoriesProvider.future,
    )).firstWhere((c) => c.type == TransactionType.expense).id;

    bool? popResult;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('home')),
        ),
        GoRoute(
          path: '/transaction/form/:id',
          builder: (context, state) => TransactionFormScreen(
            transactionId: state.pathParameters['id']!,
            prefill: state.extra as TransactionPrefill?,
          ),
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
    router
        .push<bool>(
          '/transaction/form/${GlobalConstants.createId}',
          extra: TransactionPrefill(
            amount: 250,
            categoryId: categoryId,
            accountId: 'checking',
            description: 'Headphones',
          ),
        )
        .then((result) => popResult = result);
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text('Headphones'), findsOneWidget);
    expect(find.text('250.00'), findsOneWidget);
    expect(find.text('Checking (USD)'), findsWidgets);

    final save = find.widgetWithText(
      ElevatedButton,
      l10n.createTransactionButton,
    );
    expect(tester.widget<ElevatedButton>(save).onPressed, isNotNull);
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(popResult, isTrue);
    expect(await testDb.getAccountBalance('checking'), 750);
    final saved = (await testDb.select(testDb.transactions).get()).single;
    expect(saved.description, 'Headphones');
    expect(saved.categoryId, categoryId);
  });
}
