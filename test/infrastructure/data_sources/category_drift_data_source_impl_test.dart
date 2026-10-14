import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/domain/entities/budget.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/domain/entities/transaction.dart';
import 'package:pocket_guard/infrastructure/data_sources/budget_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/category_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/transaction_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/errors/data_exceptions.dart';

void main() {
  late AppDatabase testDb;
  late CategoryDriftDataSourceImpl dataSource;

  setUp(() {
    testDb = AppDatabase(NativeDatabase.memory());
    dataSource = CategoryDriftDataSourceImpl(database: testDb);
  });

  tearDown(() async {
    await testDb.close();
  });

  Future<String> createCategory([
    String label = 'Gadgets',
    TransactionType type = TransactionType.expense,
  ]) async {
    await dataSource.createCategory(
      CategoryEntity(id: 'unused', label: label, isSystem: false, type: type),
    );
    return (await dataSource.getAllCategories())
        .firstWhere((c) => c.label == label)
        .id;
  }

  test('a new database comes with the system categories', () async {
    final categories = await dataSource.getAllCategories();

    expect(categories.where((c) => c.isSystem), hasLength(6));
    expect(
      categories.where((c) => c.type == TransactionType.transfer),
      hasLength(1),
    );
  });

  test('created categories are user categories', () async {
    final id = await createCategory('Pets', TransactionType.expense);

    final category = await dataSource.getCategoryById(id);
    expect(category!.label, 'Pets');
    expect(category.type, TransactionType.expense);
    expect(category.isSystem, isFalse);
  });

  test('updateCategory persists label and type', () async {
    final id = await createCategory();

    await dataSource.updateCategory(
      id,
      CategoryEntity(
        id: id,
        label: 'Bonus',
        isSystem: false,
        type: TransactionType.income,
      ),
    );

    final updated = await dataSource.getCategoryById(id);
    expect(updated!.label, 'Bonus');
    expect(updated.type, TransactionType.income);
  });

  test('searchCategories matches by label', () async {
    await createCategory('Gadgets');

    expect((await dataSource.searchCategories('adget')).map((c) => c.label), [
      'Gadgets',
    ]);
  });

  test('an unused category can be deleted', () async {
    final id = await createCategory();

    await dataSource.deleteCategory(id);

    expect(await dataSource.getCategoryById(id), isNull);
  });

  group('missing ids report DataNotFoundException', () {
    test('update', () async {
      await expectLater(
        dataSource.updateCategory(
          'missing',
          CategoryEntity(
            id: 'missing',
            label: 'X',
            isSystem: false,
            type: TransactionType.expense,
          ),
        ),
        throwsA(isA<DataNotFoundException>()),
      );
    });

    test('delete', () async {
      await expectLater(
        dataSource.deleteCategory('missing'),
        throwsA(isA<DataNotFoundException>()),
      );
    });
  });

  group('a category still in use cannot be deleted', () {
    test('by a transaction', () async {
      final id = await createCategory();
      final account = await testDb
          .into(testDb.accounts)
          .insertReturning(
            AccountsCompanion.insert(name: 'Checking', currency: 'USD'),
          );
      await TransactionDriftDataSourceImpl(database: testDb).createTransaction(
        TransactionEntity(
          id: 'unused',
          amount: 10,
          description: null,
          categoryId: id,
          date: DateTime(2026),
          accountId: account.id,
        ),
      );

      await expectLater(
        dataSource.deleteCategory(id),
        throwsA(isA<ForeignKeyViolation>()),
      );
      expect(await dataSource.getCategoryById(id), isNotNull);
    });

    test('by a budget', () async {
      final id = await createCategory();
      await BudgetDriftDataSourceImpl(database: testDb).createBudget(
        BudgetEntity(
          id: 'unused',
          categoryId: id,
          monthlyLimit: 100,
          currency: 'USD',
          isActive: true,
        ),
      );

      await expectLater(
        dataSource.deleteCategory(id),
        throwsA(isA<ForeignKeyViolation>()),
      );
    });
  });
}
