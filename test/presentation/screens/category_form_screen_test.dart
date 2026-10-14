import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/domain/entities/transaction.dart';
import 'package:pocket_guard/infrastructure/data_sources/category_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/transaction_drift_data_source_impl.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/providers/category/categories_provider.dart';
import 'package:pocket_guard/presentation/screens/category_form_screen.dart';

/// Deleting a category that transactions still use used to show "deleted
/// successfully" (the repository swallowed the error) while the list broke.
void main() {
  testWidgets('deleting an in-use category explains why it failed', (
    tester,
  ) async {
    final testDb = AppDatabase(NativeDatabase.memory());
    addTearDown(testDb.close);
    final categories = CategoryDriftDataSourceImpl(database: testDb);
    await categories.createCategory(
      CategoryEntity(
        id: 'unused',
        label: 'Pets',
        isSystem: false,
        type: TransactionType.expense,
      ),
    );
    final petsId = (await categories.getAllCategories())
        .firstWhere((c) => c.label == 'Pets')
        .id;
    final account = await testDb
        .into(testDb.accounts)
        .insertReturning(
          AccountsCompanion.insert(name: 'Checking', currency: 'USD'),
        );
    await TransactionDriftDataSourceImpl(database: testDb).createTransaction(
      TransactionEntity(
        id: 'unused',
        amount: 10,
        description: 'Food',
        categoryId: petsId,
        date: DateTime(2026),
        accountId: account.id,
      ),
    );

    final container = ProviderContainer(
      overrides: [categoryDataSourceProvider.overrideWith((ref) => categories)],
    );
    addTearDown(container.dispose);
    container.listen(categoriesProvider, (_, _) {});

    final router = GoRouter(
      initialLocation: '/category',
      routes: [
        GoRoute(
          path: '/category',
          builder: (context, state) => CategoryFormScreen(categoryId: petsId),
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
    await tester.pumpAndSettle();
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.deleteAction));
    await tester.pumpAndSettle();

    expect(find.text(l10n.categoryInUseError), findsOneWidget);
    expect(find.text(l10n.categoryDeletedSuccessfully), findsNothing);
    expect(await categories.getCategoryById(petsId), isNotNull);
    expect(container.read(categoriesProvider).hasError, isFalse);
  });
}
