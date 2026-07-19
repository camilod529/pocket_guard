import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/domain/entities/account.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/infrastructure/data_sources/account_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/budget_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/category_drift_data_source_impl.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/providers/budget/budget_form_provider.dart';
import 'package:pocket_guard/presentation/providers/budget/budget_provider.dart';
import 'package:pocket_guard/presentation/providers/budget/budgets_provider.dart';
import 'package:pocket_guard/presentation/providers/category/categories_provider.dart';
import 'package:pocket_guard/utils/constants/global_constants.dart';

void main() {
  late AppDatabase testDb;
  late ProviderContainer container;

  setUp(() async {
    testDb = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        categoryDataSourceProvider.overrideWith(
          (ref) => CategoryDriftDataSourceImpl(database: testDb),
        ),
        budgetDataSourceProvider.overrideWith(
          (ref) => BudgetDriftDataSourceImpl(database: testDb),
        ),
        accountDataSourceProvider.overrideWith(
          (ref) => AccountDriftDataSourceImpl(database: testDb),
        ),
      ],
    );

    await container.read(categoriesProvider.future);
  });

  tearDown(() async {
    container.dispose();
    await testDb.close();
  });

  Future<String> expenseCategoryId({int skip = 0}) async {
    final categories = await container.read(categoriesProvider.future);
    return categories
        .where((c) => c.type == TransactionType.expense)
        .elementAt(skip)
        .id;
  }

  Future<void> createAccount(String currency) async {
    final dataSource = AccountDriftDataSourceImpl(database: testDb);
    await dataSource.createAccount(
      AccountEntity(
        id: GlobalConstants.createId,
        name: currency,
        currency: currency,
        balance: 0,
        type: AccountType.cash,
        sortOrder: 0,
      ),
    );
  }

  test('creating a valid budget persists it', () async {
    await createAccount('USD');

    final sub = container.listen(
      budgetFormProvider(GlobalConstants.createId),
      (_, _) {},
    );
    await container.read(budgetFormProvider(GlobalConstants.createId).future);
    final notifier = container.read(
      budgetFormProvider(GlobalConstants.createId).notifier,
    );

    notifier.categoryChanged(await expenseCategoryId());
    notifier.monthlyLimitChanged(500);

    expect(await notifier.onFormSubmit(), isTrue);

    final budgets = await container.read(budgetsProvider.future);
    expect(budgets, hasLength(1));
    expect(budgets.single.monthlyLimit, 500);
    expect(budgets.single.currency, 'USD');
    sub.close();
  });

  test(
    'with a single account currency, the budget currency defaults to it',
    () async {
      await createAccount('EUR');

      final sub = container.listen(
        budgetFormProvider(GlobalConstants.createId),
        (_, _) {},
      );
      final formState = await container.read(
        budgetFormProvider(GlobalConstants.createId).future,
      );

      expect(formState.currency, 'EUR');
      sub.close();
    },
  );

  test('with multiple account currencies, nothing is defaulted and submitting '
      'without picking one is rejected', () async {
    await createAccount('USD');
    await createAccount('EUR');

    final sub = container.listen(
      budgetFormProvider(GlobalConstants.createId),
      (_, _) {},
    );
    final formState = await container.read(
      budgetFormProvider(GlobalConstants.createId).future,
    );
    expect(formState.currency, isNull);

    final notifier = container.read(
      budgetFormProvider(GlobalConstants.createId).notifier,
    );
    notifier.categoryChanged(await expenseCategoryId());
    notifier.monthlyLimitChanged(500);

    expect(await notifier.onFormSubmit(), isFalse);
    expect(await container.read(budgetsProvider.future), isEmpty);
    sub.close();
  });

  test('submitting without selecting a category is rejected', () async {
    await createAccount('USD');

    final sub = container.listen(
      budgetFormProvider(GlobalConstants.createId),
      (_, _) {},
    );
    await container.read(budgetFormProvider(GlobalConstants.createId).future);
    final notifier = container.read(
      budgetFormProvider(GlobalConstants.createId).notifier,
    );

    notifier.monthlyLimitChanged(500);

    expect(await notifier.onFormSubmit(), isFalse);
    expect(await container.read(budgetsProvider.future), isEmpty);
    sub.close();
  });

  test('submitting a zero monthly limit is rejected', () async {
    await createAccount('USD');

    final sub = container.listen(
      budgetFormProvider(GlobalConstants.createId),
      (_, _) {},
    );
    await container.read(budgetFormProvider(GlobalConstants.createId).future);
    final notifier = container.read(
      budgetFormProvider(GlobalConstants.createId).notifier,
    );

    notifier.categoryChanged(await expenseCategoryId());
    notifier.monthlyLimitChanged(0);

    expect(await notifier.onFormSubmit(), isFalse);
    expect(await container.read(budgetsProvider.future), isEmpty);
    sub.close();
  });

  test('editing an existing budget updates its limit', () async {
    await createAccount('USD');

    final createSub = container.listen(
      budgetFormProvider(GlobalConstants.createId),
      (_, _) {},
    );
    await container.read(budgetFormProvider(GlobalConstants.createId).future);
    final createNotifier = container.read(
      budgetFormProvider(GlobalConstants.createId).notifier,
    );
    createNotifier.categoryChanged(await expenseCategoryId());
    createNotifier.monthlyLimitChanged(200);
    await createNotifier.onFormSubmit();
    createSub.close();

    final id = (await container.read(budgetsProvider.future)).single.id;

    final editSub = container.listen(budgetFormProvider(id), (_, _) {});
    await container.read(budgetFormProvider(id).future);
    final editNotifier = container.read(budgetFormProvider(id).notifier);
    editNotifier.monthlyLimitChanged(750);

    expect(await editNotifier.onFormSubmit(), isTrue);

    final budgets = await container.read(budgetsProvider.future);
    expect(budgets.single.monthlyLimit, 750);
    editSub.close();
  });

  test('editing a budget refreshes the single-item cache too, not just the '
      'list - regression for the two caches drifting apart', () async {
    await createAccount('USD');

    final createSub = container.listen(
      budgetFormProvider(GlobalConstants.createId),
      (_, _) {},
    );
    await container.read(budgetFormProvider(GlobalConstants.createId).future);
    final createNotifier = container.read(
      budgetFormProvider(GlobalConstants.createId).notifier,
    );
    createNotifier.categoryChanged(await expenseCategoryId());
    createNotifier.monthlyLimitChanged(1000);
    await createNotifier.onFormSubmit();
    createSub.close();

    final id = (await container.read(budgetsProvider.future)).single.id;

    // Populate budgetProvider(id)'s cache before editing, the same way
    // opening the edit screen a second time would.
    final budgetSub = container.listen(budgetProvider(id), (_, _) {});
    await container.read(budgetProvider(id).future);

    final editSub = container.listen(budgetFormProvider(id), (_, _) {});
    await container.read(budgetFormProvider(id).future);
    final editNotifier = container.read(budgetFormProvider(id).notifier);
    editNotifier.monthlyLimitChanged(100000000000);
    expect(await editNotifier.onFormSubmit(), isTrue);
    editSub.close();

    final cachedBudget = await container.read(budgetProvider(id).future);
    expect(cachedBudget!.monthlyLimit, 100000000000);
    budgetSub.close();
  });

  test(
    'a second budget for an already-budgeted category fails to submit',
    () async {
      await createAccount('USD');
      final categoryId = await expenseCategoryId();

      final firstSub = container.listen(
        budgetFormProvider(GlobalConstants.createId),
        (_, _) {},
      );
      await container.read(budgetFormProvider(GlobalConstants.createId).future);
      final firstNotifier = container.read(
        budgetFormProvider(GlobalConstants.createId).notifier,
      );
      firstNotifier.categoryChanged(categoryId);
      firstNotifier.monthlyLimitChanged(300);
      expect(await firstNotifier.onFormSubmit(), isTrue);
      firstSub.close();

      // A fresh create-form instance (simulating the user opening "add
      // budget" again) targeting the same category the UI is supposed to
      // have already filtered out - the provider layer should still fail
      // gracefully rather than crash if that filtering is ever bypassed.
      final secondSub = container.listen(
        budgetFormProvider(GlobalConstants.createId),
        (_, _) {},
      );
      await container.read(budgetFormProvider(GlobalConstants.createId).future);
      final secondNotifier = container.read(
        budgetFormProvider(GlobalConstants.createId).notifier,
      );
      secondNotifier.categoryChanged(categoryId);
      secondNotifier.monthlyLimitChanged(100);

      expect(await secondNotifier.onFormSubmit(), isFalse);
      expect(await container.read(budgetsProvider.future), hasLength(1));
      // The screen reads this to show a specific "you already have a
      // budget for this category/currency" message instead of a generic
      // "operation failed" one.
      expect(
        container
            .read(budgetFormProvider(GlobalConstants.createId))
            .value
            ?.submitError,
        BudgetSubmitError.duplicateCategoryCurrency,
      );
      secondSub.close();
    },
  );

  test('a second budget for the same category in a different currency '
      'succeeds - budgets are scoped per (category, currency)', () async {
    await createAccount('USD');
    await createAccount('COP');
    final categoryId = await expenseCategoryId();

    final firstSub = container.listen(
      budgetFormProvider(GlobalConstants.createId),
      (_, _) {},
    );
    await container.read(budgetFormProvider(GlobalConstants.createId).future);
    final firstNotifier = container.read(
      budgetFormProvider(GlobalConstants.createId).notifier,
    );
    firstNotifier.categoryChanged(categoryId);
    firstNotifier.currencyChanged('USD');
    firstNotifier.monthlyLimitChanged(300);
    expect(await firstNotifier.onFormSubmit(), isTrue);
    firstSub.close();

    final secondSub = container.listen(
      budgetFormProvider(GlobalConstants.createId),
      (_, _) {},
    );
    await container.read(budgetFormProvider(GlobalConstants.createId).future);
    final secondNotifier = container.read(
      budgetFormProvider(GlobalConstants.createId).notifier,
    );
    secondNotifier.categoryChanged(categoryId);
    secondNotifier.currencyChanged('COP');
    secondNotifier.monthlyLimitChanged(500000);

    expect(await secondNotifier.onFormSubmit(), isTrue);
    final budgets = await container.read(budgetsProvider.future);
    expect(budgets, hasLength(2));
    expect(budgets.every((b) => b.categoryId == categoryId), isTrue);
    expect(budgets.map((b) => b.currency).toSet(), {'USD', 'COP'});
    secondSub.close();
  });
}
