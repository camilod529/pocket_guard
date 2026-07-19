import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/domain/entities/category.dart';
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

void main() {
  late AppDatabase testDb;
  late ProviderContainer container;
  const checkingId = 'checking';
  const savingsId = 'savings';
  final fakeNow = DateTime(2026, 3, 1);

  setUp(() async {
    testDb = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
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
          (ref) => RecurringTransactionDriftDataSourceImpl(database: testDb),
        ),
        currentDateTimeProvider.overrideWith((ref) => fakeNow),
      ],
    );

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

    await container.read(categoriesProvider.future);
  });

  tearDown(() async {
    container.dispose();
    await testDb.close();
  });

  Future<String> expenseCategoryId() async {
    final categories = await container.read(categoriesProvider.future);
    return categories.firstWhere((c) => c.type == TransactionType.expense).id;
  }

  test('creating an expense rule persists it and generates the first occurrence since startDate is due', () async {
    final sub = container.listen(
      recurringTransactionFormProvider(GlobalConstants.createId),
      (_, _) {},
    );
    await container.read(
      recurringTransactionFormProvider(GlobalConstants.createId).future,
    );
    final notifier = container.read(
      recurringTransactionFormProvider(GlobalConstants.createId).notifier,
    );

    notifier.accountChanged(checkingId);
    notifier.categoryChanged(await expenseCategoryId());
    notifier.amountChanged(15);
    notifier.nameChanged('Netflix');
    notifier.startDateChanged(fakeNow);

    expect(await notifier.onFormSubmit(), isTrue);

    final rules = await container.read(recurringTransactionsProvider.future);
    expect(rules, hasLength(1));
    expect(rules.single.description, 'Netflix');

    // startDate == fakeNow, so onFormSubmit's immediate catch-up pass
    // should have already generated the first transaction. Checked via the
    // raw balance, not transactionsProvider - that applies a "current
    // month" filter (real DateTime.now(), not fakeNow) that would exclude
    // a transaction dated in the test's simulated month.
    expect(await testDb.getAccountBalance(checkingId), 985);
    sub.close();
  });

  test('creating a transfer rule with the same from/to account is rejected', () async {
    final sub = container.listen(
      recurringTransactionFormProvider(GlobalConstants.createId),
      (_, _) {},
    );
    await container.read(
      recurringTransactionFormProvider(GlobalConstants.createId).future,
    );
    final notifier = container.read(
      recurringTransactionFormProvider(GlobalConstants.createId).notifier,
    );

    notifier.typeChanged(TransactionType.transfer);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    notifier.accountChanged(checkingId);
    notifier.toAccountChanged(checkingId);
    notifier.amountChanged(100);
    notifier.nameChanged('Auto-save');

    expect(
      container
          .read(recurringTransactionFormProvider(GlobalConstants.createId))
          .value
          ?.isFormValid,
      isFalse,
    );
    expect(await notifier.onFormSubmit(), isFalse);
    expect(await container.read(recurringTransactionsProvider.future), isEmpty);
    sub.close();
  });

  test('creating a valid transfer rule succeeds', () async {
    final sub = container.listen(
      recurringTransactionFormProvider(GlobalConstants.createId),
      (_, _) {},
    );
    await container.read(
      recurringTransactionFormProvider(GlobalConstants.createId).future,
    );
    final notifier = container.read(
      recurringTransactionFormProvider(GlobalConstants.createId).notifier,
    );

    notifier.typeChanged(TransactionType.transfer);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    notifier.accountChanged(checkingId);
    notifier.toAccountChanged(savingsId);
    notifier.amountChanged(100);
    notifier.nameChanged('Auto-save');
    notifier.startDateChanged(fakeNow.add(const Duration(days: 30)));

    expect(await notifier.onFormSubmit(), isTrue);

    final rules = await container.read(recurringTransactionsProvider.future);
    expect(rules, hasLength(1));
    expect(rules.single.toAccountId, savingsId);
    // Not due yet (startDate is in the future), so no transaction yet.
    expect(await container.read(transactionsProvider.future), isEmpty);
    sub.close();
  });

  test('editing an existing rule updates it without duplicating it', () async {
    var sub = container.listen(
      recurringTransactionFormProvider(GlobalConstants.createId),
      (_, _) {},
    );
    await container.read(
      recurringTransactionFormProvider(GlobalConstants.createId).future,
    );
    var notifier = container.read(
      recurringTransactionFormProvider(GlobalConstants.createId).notifier,
    );
    notifier.accountChanged(checkingId);
    notifier.categoryChanged(await expenseCategoryId());
    notifier.amountChanged(15);
    notifier.nameChanged('Netflix');
    notifier.startDateChanged(fakeNow.add(const Duration(days: 10)));
    await notifier.onFormSubmit();
    sub.close();

    final ruleId = (await container.read(
      recurringTransactionsProvider.future,
    )).single.id;

    sub = container.listen(recurringTransactionFormProvider(ruleId), (_, _) {});
    await container.read(recurringTransactionFormProvider(ruleId).future);
    notifier = container.read(
      recurringTransactionFormProvider(ruleId).notifier,
    );
    notifier.amountChanged(20);
    await notifier.onFormSubmit();

    final rules = await container.read(recurringTransactionsProvider.future);
    expect(rules, hasLength(1));
    expect(rules.single.amount, 20);
    sub.close();
  });
}
