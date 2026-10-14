import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/domain/entities/recurring_transaction.dart';
import 'package:pocket_guard/infrastructure/data_sources/account_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/category_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/recurring_transaction_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/transaction_drift_data_source_impl.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/providers/category/categories_provider.dart';
import 'package:pocket_guard/presentation/providers/recurring_transaction/recurring_transaction_catch_up_provider.dart';
import 'package:pocket_guard/presentation/providers/recurring_transaction/recurring_transaction_form_provider.dart';
import 'package:pocket_guard/presentation/providers/recurring_transaction/recurring_transactions_provider.dart';
import 'package:pocket_guard/presentation/providers/transaction/transactions_provider.dart';
import 'package:pocket_guard/utils/constants/global_constants.dart';

class _FailingCreates extends RecurringTransactionDriftDataSourceImpl {
  _FailingCreates(AppDatabase database) : super(database: database);

  @override
  Future<void> createRecurringTransaction(RecurringTransactionEntity rule) =>
      Future.error(StateError('disk full'));
}

/// A rule that wasn't saved must not be reported as saved - the form
/// closes on success, losing what the user entered.
void main() {
  test('a failed save makes the recurring form report failure', () async {
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
        recurringTransactionDataSourceProvider.overrideWith(
          (ref) => _FailingCreates(testDb),
        ),
        currentDateTimeProvider.overrideWith((ref) => DateTime(2026, 3, 1)),
      ],
    );
    addTearDown(container.dispose);
    // Kept alive like the app's recurring list does.
    container.listen(recurringTransactionsProvider, (_, _) {});

    final categoryId = (await container.read(
      categoriesProvider.future,
    )).firstWhere((c) => c.type == TransactionType.expense).id;
    final provider = recurringTransactionFormProvider(GlobalConstants.createId);
    final sub = container.listen(provider, (_, _) {});
    await container.read(provider.future);
    final form = container.read(provider.notifier);
    form.accountChanged('checking');
    form.categoryChanged(categoryId);
    form.amountChanged(15);
    form.nameChanged('Netflix');
    form.startDateChanged(DateTime(2026, 3, 1));

    expect(await form.onFormSubmit(), isFalse);
    expect(container.read(recurringTransactionsProvider).hasError, isFalse);
    expect(await testDb.getAccountBalance('checking'), 1000);
    sub.close();
  });
}
