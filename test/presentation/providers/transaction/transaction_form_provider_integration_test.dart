import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/infrastructure/data_sources/account_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/category_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/transaction_drift_data_source_impl.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/providers/category/categories_provider.dart';
import 'package:pocket_guard/presentation/providers/transaction/transaction_form_provider.dart';
import 'package:pocket_guard/presentation/providers/transaction/transactions_provider.dart';
import 'package:pocket_guard/utils/constants/global_constants.dart';

/// Drives the real TransactionForm notifier the way the UI does (one
/// mutator call per user action, then onFormSubmit), instead of calling
/// TransactionDriftDataSourceImpl directly like the other test file does.
/// Written to reproduce a manual-testing report: A1 create transfer, A2
/// edit to swap from/to, A3 edit amount, A4 edit type to expense - where
/// the reported result was checking=970 (correct) but savings=950
/// (should have reverted to 1000).
void main() {
  late AppDatabase testDb;
  late ProviderContainer container;
  const checkingId = 'checking';
  const savingsId = 'savings';

  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 10));

  Future<double> balanceOf(String accountId) => testDb.getAccountBalance(accountId);

  /// What the Accounts screen (which watches accountsProvider, not the raw
  /// DB or accountProvider(id)) would actually render for this account.
  Future<double> displayedBalanceOf(
    ProviderContainer container,
    String accountId,
  ) async {
    final accounts = await container.read(accountsProvider.future);
    return accounts.firstWhere((a) => a.id == accountId).balance;
  }

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

    // Pre-warm categories so typeChanged's internal await resolves fast.
    await container.read(categoriesProvider.future);
  });

  tearDown(() async {
    container.dispose();
    await testDb.close();
  });

  test('A1-A4 manual test sequence produces correct balances at every step', () async {
    // Keep accountsProvider alive for the whole test, like the Accounts
    // screen would while mounted in the app's persistent bottom-nav shell -
    // otherwise a missed invalidation wouldn't be observable here.
    final accountsSub = container.listen(accountsProvider, (_, _) {});
    addTearDown(accountsSub.close);

    // A1: create a transfer Checking -> Savings, amount 200.
    // autoDispose providers get torn down once nothing listens to them, so
    // each phase holds a live subscription for as long as it needs the
    // notifier - otherwise state mutations throw "used after disposed".
    var sub = container.listen(
      transactionFormProvider(GlobalConstants.createId),
      (_, _) {},
    );
    await container.read(transactionFormProvider(GlobalConstants.createId).future);
    var notifier = container.read(
      transactionFormProvider(GlobalConstants.createId).notifier,
    );

    notifier.typeChanged(TransactionType.transfer);
    await settle();
    notifier.accountChanged(checkingId);
    notifier.toAccountChanged(savingsId);
    notifier.amountChanged(200);
    notifier.descriptionChanged('A1');

    expect(await notifier.onFormSubmit(), isTrue, reason: 'A1 submit');
    expect(await balanceOf(checkingId), 800, reason: 'A1 checking');
    expect(await balanceOf(savingsId), 1200, reason: 'A1 savings');
    expect(
      await displayedBalanceOf(container, checkingId),
      800,
      reason: 'A1 checking as shown on Accounts screen',
    );
    expect(
      await displayedBalanceOf(container, savingsId),
      1200,
      reason: 'A1 savings as shown on Accounts screen',
    );
    sub.close();

    final txId = (await testDb.select(testDb.transactions).get()).single.id;

    sub = container.listen(transactionFormProvider(txId), (_, _) {});

    // A2: edit to swap From/To (Savings -> Checking), same amount.
    await container.read(transactionFormProvider(txId).future);
    notifier = container.read(transactionFormProvider(txId).notifier);

    notifier.accountChanged(savingsId);
    notifier.toAccountChanged(checkingId);

    expect(await notifier.onFormSubmit(), isTrue, reason: 'A2 submit');
    expect(await balanceOf(checkingId), 1200, reason: 'A2 checking');
    expect(await balanceOf(savingsId), 800, reason: 'A2 savings');

    // A3: edit the amount only, to 50.
    await container.read(transactionFormProvider(txId).future);
    notifier = container.read(transactionFormProvider(txId).notifier);

    notifier.amountChanged(50);

    expect(await notifier.onFormSubmit(), isTrue, reason: 'A3 submit');
    expect(await balanceOf(checkingId), 1050, reason: 'A3 checking');
    expect(await balanceOf(savingsId), 950, reason: 'A3 savings');

    // A4: edit type to Expense, account Checking, amount 30.
    await container.read(transactionFormProvider(txId).future);
    notifier = container.read(transactionFormProvider(txId).notifier);

    notifier.typeChanged(TransactionType.expense);
    await settle();
    notifier.accountChanged(checkingId);
    final categories = await container.read(categoriesProvider.future);
    final expenseCategoryId = categories
        .firstWhere((c) => c.type == TransactionType.expense)
        .id;
    notifier.categoryChanged(expenseCategoryId);
    notifier.amountChanged(30);

    expect(await notifier.onFormSubmit(), isTrue, reason: 'A4 submit');
    expect(await balanceOf(checkingId), 970, reason: 'A4 checking');
    expect(await balanceOf(savingsId), 1000, reason: 'A4 savings');
    expect(
      await displayedBalanceOf(container, checkingId),
      970,
      reason: 'A4 checking as shown on Accounts screen',
    );
    expect(
      await displayedBalanceOf(container, savingsId),
      1000,
      reason:
          'A4 savings as shown on Accounts screen - this is the one that '
          'regresses if the account it dropped out of stops being refreshed',
    );
    sub.close();
  });
}
