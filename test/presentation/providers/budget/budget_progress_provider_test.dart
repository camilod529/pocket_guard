import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/domain/entities/account.dart';
import 'package:pocket_guard/domain/entities/budget.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/domain/entities/transaction.dart';
import 'package:pocket_guard/infrastructure/data_sources/account_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/budget_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/category_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/transaction_drift_data_source_impl.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/providers/budget/budget_progress_provider.dart';
import 'package:pocket_guard/presentation/providers/budget/budgets_provider.dart';
import 'package:pocket_guard/presentation/providers/category/categories_provider.dart';
import 'package:pocket_guard/presentation/providers/transaction/transactions_provider.dart';
import 'package:pocket_guard/utils/constants/global_constants.dart';

void main() {
  late AppDatabase testDb;
  late ProviderContainer container;
  late AccountDriftDataSourceImpl accountDataSource;
  late BudgetDriftDataSourceImpl budgetDataSource;
  late TransactionDriftDataSourceImpl transactionDataSource;
  late String expenseCategoryId;

  setUp(() async {
    testDb = AppDatabase(NativeDatabase.memory());
    accountDataSource = AccountDriftDataSourceImpl(database: testDb);
    budgetDataSource = BudgetDriftDataSourceImpl(database: testDb);
    transactionDataSource = TransactionDriftDataSourceImpl(database: testDb);

    container = ProviderContainer(
      overrides: [
        categoryDataSourceProvider.overrideWith(
          (ref) => CategoryDriftDataSourceImpl(database: testDb),
        ),
        budgetDataSourceProvider.overrideWith((ref) => budgetDataSource),
        accountDataSourceProvider.overrideWith((ref) => accountDataSource),
        transactionDataSourceProvider.overrideWith(
          (ref) => transactionDataSource,
        ),
      ],
    );

    final categories = await container.read(categoriesProvider.future);
    expenseCategoryId = categories
        .firstWhere((c) => c.type == TransactionType.expense)
        .id;
  });

  tearDown(() async {
    container.dispose();
    await testDb.close();
  });

  Future<String> createAccount(String currency) async {
    await accountDataSource.createAccount(
      AccountEntity(
        id: GlobalConstants.createId,
        name: currency,
        currency: currency,
        balance: 1000,
        type: AccountType.cash,
        sortOrder: 0,
      ),
    );
    final accounts = await accountDataSource.getAllAccounts();
    return accounts.firstWhere((a) => a.currency == currency).id;
  }

  test(
    'only sums transactions from accounts matching the budget currency',
    () async {
      final usdAccountId = await createAccount('USD');
      final eurAccountId = await createAccount('EUR');

      await budgetDataSource.createBudget(
        BudgetEntity(
          id: 'unused',
          categoryId: expenseCategoryId,
          monthlyLimit: 500,
          currency: 'USD',
          isActive: true,
        ),
      );

      final now = DateTime.now();
      await transactionDataSource.createTransaction(
        TransactionEntity(
          id: 'unused',
          accountId: usdAccountId,
          amount: 100,
          date: now,
          categoryId: expenseCategoryId,
        ),
      );
      // Same category, but a different currency's account - must not count
      // toward this USD budget's spending.
      await transactionDataSource.createTransaction(
        TransactionEntity(
          id: 'unused',
          accountId: eurAccountId,
          amount: 300,
          date: now,
          categoryId: expenseCategoryId,
        ),
      );

      final sub = container.listen(budgetProgressProvider, (_, _) {});
      final progress = await container.read(budgetProgressProvider.future);

      expect(progress, hasLength(1));
      expect(progress.single.spent, 100);
      expect(progress.single.remaining, 400);
      sub.close();
    },
  );
}
