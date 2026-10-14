import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/domain/entities/transaction.dart';
import 'package:pocket_guard/infrastructure/data_sources/account_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/category_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/transaction_drift_data_source_impl.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/providers/category/categories_provider.dart';
import 'package:pocket_guard/presentation/providers/transaction/transaction_form_provider.dart';
import 'package:pocket_guard/presentation/providers/transaction/transactions_provider.dart';
import 'package:pocket_guard/utils/constants/global_constants.dart';

class _FailingWrites extends TransactionDriftDataSourceImpl {
  _FailingWrites(AppDatabase database) : super(database: database);

  @override
  Future<void> createTransaction(TransactionEntity transaction) =>
      Future.error(StateError('disk full'));

  @override
  Future<void> deleteTransaction(String id) =>
      Future.error(StateError('disk full'));
}

/// A transaction that wasn't saved must never be reported as saved: the
/// form closes on success (and the wishlist marks an item bought), so a
/// swallowed failure loses the user's data without telling them.
void main() {
  late AppDatabase testDb;
  late ProviderContainer container;

  setUp(() async {
    testDb = AppDatabase(NativeDatabase.memory());
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
    container = ProviderContainer(
      overrides: [
        accountDataSourceProvider.overrideWith(
          (ref) => AccountDriftDataSourceImpl(database: testDb),
        ),
        categoryDataSourceProvider.overrideWith(
          (ref) => CategoryDriftDataSourceImpl(database: testDb),
        ),
        transactionDataSourceProvider.overrideWith(
          (ref) => _FailingWrites(testDb),
        ),
      ],
    );
    // Kept alive like the app's calendar does.
    container.listen(transactionsProvider, (_, _) {});
  });

  tearDown(() async {
    container.dispose();
    await testDb.close();
  });

  test('a failed create makes the form report failure', () async {
    final categoryId = (await container.read(
      categoriesProvider.future,
    )).firstWhere((c) => c.type == TransactionType.expense).id;
    final provider = transactionFormProvider(GlobalConstants.createId);
    final sub = container.listen(provider, (_, _) {});
    await container.read(provider.future);
    final form = container.read(provider.notifier);
    form.amountChanged(25);
    form.descriptionChanged('Lunch');
    form.categoryChanged(categoryId);
    form.accountChanged('checking');

    expect(await form.onFormSubmit(), isFalse);
    expect(await testDb.getAccountBalance('checking'), 1000);
    expect(container.read(transactionsProvider).hasError, isFalse);
    sub.close();
  });

  test('a failed delete throws to the caller', () async {
    await TransactionDriftDataSourceImpl(database: testDb).createTransaction(
      TransactionEntity(
        id: 'unused',
        amount: 25,
        description: 'Lunch',
        categoryId: (await container.read(
          categoriesProvider.future,
        )).firstWhere((c) => c.type == TransactionType.expense).id,
        date: DateTime.now(),
        accountId: 'checking',
      ),
    );
    final id = (await testDb.select(testDb.transactions).get()).single.id;

    await expectLater(
      container.read(transactionsProvider.notifier).deleteTransaction(id),
      throwsA(anything),
    );
    expect(await testDb.select(testDb.transactions).get(), hasLength(1));
  });
}
