import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/domain/entities/savings_goal.dart';
import 'package:pocket_guard/domain/entities/wishlist_item.dart';
import 'package:pocket_guard/infrastructure/data_sources/savings_goal_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/wishlist_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/errors/data_exceptions.dart';

void main() {
  late AppDatabase testDb;
  late WishlistDriftDataSourceImpl dataSource;

  setUp(() {
    testDb = AppDatabase(NativeDatabase.memory());
    dataSource = WishlistDriftDataSourceImpl(database: testDb);
  });

  tearDown(() async {
    await testDb.close();
  });

  WishlistItemEntity buildItem({
    String name = 'Headphones',
    double price = 250,
    String? categoryId,
    String? goalId,
    DateTime? purchasedAt,
  }) {
    return WishlistItemEntity(
      id: 'unused',
      name: name,
      price: price,
      currency: 'USD',
      categoryId: categoryId,
      goalId: goalId,
      purchasedAt: purchasedAt,
      createdAt: DateTime(2026),
    );
  }

  Future<String> expenseCategoryId() async {
    final categories = await testDb.select(testDb.categories).get();
    return categories.firstWhere((c) => c.type == TransactionType.expense).id;
  }

  Future<String> createGoal() async {
    final goals = SavingsGoalDriftDataSourceImpl(database: testDb);
    await goals.createGoal(
      SavingsGoalEntity(
        id: 'unused',
        name: 'Tech',
        targetAmount: 500,
        currency: 'USD',
        targetDate: null,
        isArchived: false,
        createdAt: DateTime(2026),
      ),
    );
    return (await goals.getAllGoals()).single.id;
  }

  test('createItem then getItemById round-trips all fields', () async {
    final categoryId = await expenseCategoryId();
    final goalId = await createGoal();
    await dataSource.createItem(
      buildItem(price: 99.99, categoryId: categoryId, goalId: goalId),
    );

    final id = (await dataSource.getAllItems()).single.id;
    final item = await dataSource.getItemById(id);
    expect(item!.name, 'Headphones');
    expect(item.price, 99.99);
    expect(item.currency, 'USD');
    expect(item.categoryId, categoryId);
    expect(item.goalId, goalId);
    expect(item.isPurchased, isFalse);
  });

  test('updateItem can mark purchased and clear links', () async {
    final categoryId = await expenseCategoryId();
    await dataSource.createItem(buildItem(categoryId: categoryId));
    final item = (await dataSource.getAllItems()).single;
    final purchasedAt = DateTime(2026, 5, 1);

    await dataSource.updateItem(
      item.id,
      item.copyWith(purchasedAt: purchasedAt, categoryId: null),
    );

    final updated = await dataSource.getItemById(item.id);
    expect(updated!.purchasedAt, purchasedAt);
    expect(updated.categoryId, isNull);
  });

  test('deleteItem removes it, and unknown ids throw', () async {
    await dataSource.createItem(buildItem());
    final id = (await dataSource.getAllItems()).single.id;

    await dataSource.deleteItem(id);

    expect(await dataSource.getAllItems(), isEmpty);
    await expectLater(
      dataSource.deleteItem(id),
      throwsA(isA<DataNotFoundException>()),
    );
  });

  test('deleting the linked goal or category keeps the item, just '
      'unlinked', () async {
    final goalId = await createGoal();
    final categoryRow = await testDb
        .into(testDb.categories)
        .insertReturning(
          CategoriesCompanion.insert(
            label: 'Gadgets',
            type: TransactionType.expense,
            origin: CategoryOrigin.user,
          ),
        );
    await dataSource.createItem(
      buildItem(categoryId: categoryRow.id, goalId: goalId),
    );

    await SavingsGoalDriftDataSourceImpl(database: testDb).deleteGoal(goalId);
    await (testDb.delete(
      testDb.categories,
    )..where((tbl) => tbl.id.equals(categoryRow.id))).go();

    final item = (await dataSource.getAllItems()).single;
    expect(item.goalId, isNull);
    expect(item.categoryId, isNull);
  });
}
