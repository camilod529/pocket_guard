import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/domain/entities/budget.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/infrastructure/data_sources/budget_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/errors/data_exceptions.dart';

void main() {
  late AppDatabase testDb;
  late BudgetDriftDataSourceImpl dataSource;
  late String expenseCategoryId;
  late String otherExpenseCategoryId;

  setUp(() async {
    testDb = AppDatabase(NativeDatabase.memory());
    dataSource = BudgetDriftDataSourceImpl(database: testDb);

    final categories = await testDb.select(testDb.categories).get();
    final expenseCategories = categories.where(
      (c) => c.type == TransactionType.expense,
    );
    expenseCategoryId = expenseCategories.first.id;
    otherExpenseCategoryId = expenseCategories.elementAt(1).id;
  });

  tearDown(() async {
    await testDb.close();
  });

  BudgetEntity buildBudget({
    String? categoryId,
    double monthlyLimit = 500,
    String currency = 'USD',
    bool isActive = true,
  }) {
    return BudgetEntity(
      id: 'unused',
      categoryId: categoryId ?? expenseCategoryId,
      monthlyLimit: monthlyLimit,
      currency: currency,
      isActive: isActive,
    );
  }

  test('createBudget then getAllBudgets round-trips all fields', () async {
    await dataSource.createBudget(
      buildBudget(monthlyLimit: 250.5, currency: 'EUR'),
    );

    final budgets = await dataSource.getAllBudgets();

    expect(budgets, hasLength(1));
    final budget = budgets.single;
    expect(budget.categoryId, expenseCategoryId);
    expect(budget.monthlyLimit, 250.5);
    expect(budget.currency, 'EUR');
    expect(budget.isActive, isTrue);
  });

  test('getBudgetById returns null for an unknown id', () async {
    expect(await dataSource.getBudgetById('missing'), isNull);
  });

  test('updateBudget persists changes', () async {
    await dataSource.createBudget(buildBudget());
    final id = (await dataSource.getAllBudgets()).single.id;

    await dataSource.updateBudget(
      id,
      buildBudget(isActive: false, monthlyLimit: 999).copyWith(id: id),
    );

    final updated = await dataSource.getBudgetById(id);
    expect(updated!.isActive, isFalse);
    expect(updated.monthlyLimit, 999);
  });

  test('deleteBudget removes the budget', () async {
    await dataSource.createBudget(buildBudget());
    final id = (await dataSource.getAllBudgets()).single.id;

    await dataSource.deleteBudget(id);

    expect(await dataSource.getAllBudgets(), isEmpty);
  });

  test('deleteBudget throws DataNotFoundException for an unknown id', () {
    expect(
      () => dataSource.deleteBudget('missing'),
      throwsA(isA<DataNotFoundException>()),
    );
  });

  test(
    'creating a second budget for the same category and currency violates '
    'the unique constraint',
    () async {
      await dataSource.createBudget(buildBudget());

      expect(
        () => dataSource.createBudget(buildBudget()),
        throwsA(isA<DataException>()),
      );
    },
  );

  test(
    'a second budget for the same category but a different currency is '
    'allowed',
    () async {
      await dataSource.createBudget(buildBudget(currency: 'USD'));
      await dataSource.createBudget(buildBudget(currency: 'COP'));

      final budgets = await dataSource.getAllBudgets();
      expect(budgets, hasLength(2));
      expect(budgets.every((b) => b.categoryId == expenseCategoryId), isTrue);
    },
  );

  test('two budgets for different categories are both allowed', () async {
    await dataSource.createBudget(buildBudget());
    await dataSource.createBudget(
      buildBudget(categoryId: otherExpenseCategoryId),
    );

    expect(await dataSource.getAllBudgets(), hasLength(2));
  });
}
