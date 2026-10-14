import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/domain/entities/budget.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/domain/entities/goal_contribution.dart';
import 'package:pocket_guard/domain/entities/savings_goal.dart';
import 'package:pocket_guard/domain/entities/transaction.dart';
import 'package:pocket_guard/domain/entities/wishlist_item.dart';
import 'package:pocket_guard/domain/services/affordability_calculator.dart';
import 'package:pocket_guard/infrastructure/data_sources/account_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/budget_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/category_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/savings_goal_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/transaction_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/wishlist_drift_data_source_impl.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/providers/budget/budgets_provider.dart';
import 'package:pocket_guard/presentation/providers/category/categories_provider.dart';
import 'package:pocket_guard/presentation/providers/savings_goal/savings_goals_provider.dart';
import 'package:pocket_guard/presentation/providers/transaction/transactions_provider.dart';
import 'package:pocket_guard/presentation/providers/wishlist/wishlist_affordability_provider.dart';
import 'package:pocket_guard/presentation/providers/wishlist/wishlist_provider.dart';

/// Wires the real providers over one in-memory database and checks that
/// accounts, this month's budget and savings jars all feed the verdict.
void main() {
  late AppDatabase testDb;
  late ProviderContainer container;
  late String categoryId;

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
        budgetDataSourceProvider.overrideWith(
          (ref) => BudgetDriftDataSourceImpl(database: testDb),
        ),
        savingsGoalDataSourceProvider.overrideWith(
          (ref) => SavingsGoalDriftDataSourceImpl(database: testDb),
        ),
        wishlistDataSourceProvider.overrideWith(
          (ref) => WishlistDriftDataSourceImpl(database: testDb),
        ),
      ],
    );

    final categories = await container.read(categoriesProvider.future);
    categoryId = categories
        .firstWhere((c) => c.type == TransactionType.expense)
        .id;

    await testDb
        .into(testDb.accounts)
        .insert(
          AccountsCompanion.insert(
            id: const Value('usd'),
            name: 'Checking',
            currency: 'USD',
            balance: const Value(1000),
          ),
        );
    await testDb
        .into(testDb.accounts)
        .insert(
          AccountsCompanion.insert(
            id: const Value('eur'),
            name: 'Euro',
            currency: 'EUR',
            balance: const Value(5000),
          ),
        );
  });

  tearDown(() async {
    container.dispose();
    await testDb.close();
  });

  Future<void> addItem(
    String name,
    double price, {
    String? categoryId,
    String? goalId,
  }) {
    return container
        .read(wishlistProvider.notifier)
        .createItem(
          WishlistItemEntity(
            id: 'unused',
            name: name,
            price: price,
            currency: 'USD',
            categoryId: categoryId,
            goalId: goalId,
            purchasedAt: null,
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<Affordability> verdictFor(String name) async {
    // Listen (like the Wishlist screen's watch) rather than a bare read:
    // read() releases the auto-dispose chain while budgetProgressProvider
    // is still mid-build, which disposes it out from under itself.
    final sub = container.listen(wishlistAffordabilityProvider, (_, _) {});
    try {
      final all = await container.read(wishlistAffordabilityProvider.future);
      return all.firstWhere((a) => a.item.name == name);
    } finally {
      sub.close();
    }
  }

  test('funds only count accounts in the item currency', () async {
    await addItem('Laptop', 1500);

    final verdict = await verdictFor('Laptop');
    // The 5000 EUR account must not make a USD item affordable.
    expect(verdict.status, AffordabilityStatus.insufficientFunds);
    expect(verdict.shortfall, 500);
  });

  test('a budget with this month\'s spending already applied makes it '
      'over budget', () async {
    await container
        .read(budgetsProvider.notifier)
        .createBudget(
          BudgetEntity(
            id: 'unused',
            categoryId: categoryId,
            monthlyLimit: 300,
            currency: 'USD',
            isActive: true,
          ),
        );
    await container
        .read(transactionsProvider.notifier)
        .createTransaction(
          TransactionEntity(
            id: 'unused',
            amount: 100,
            description: 'Dinner',
            categoryId: categoryId,
            date: DateTime.now(),
            accountId: 'usd',
          ),
        );
    await addItem('Shoes', 250, categoryId: categoryId);
    await addItem('Lamp', 150, categoryId: categoryId);

    // 300 limit - 100 spent = 200 left this month.
    final shoes = await verdictFor('Shoes');
    expect(shoes.status, AffordabilityStatus.overBudget);
    expect(shoes.shortfall, 50);
    expect((await verdictFor('Lamp')).status, AffordabilityStatus.affordable);
  });

  test('a linked jar counts toward the price, and covering it fully is '
      'flagged', () async {
    final goals = container.read(savingsGoalsProvider.notifier);
    await goals.createGoal(
      SavingsGoalEntity(
        id: 'unused',
        name: 'Tech',
        targetAmount: 1000,
        currency: 'USD',
        targetDate: null,
        isArchived: false,
        createdAt: DateTime.now(),
      ),
    );
    final goalId = (await container.read(
      savingsGoalsProvider.future,
    )).single.id;
    await goals.addContribution(
      GoalContributionEntity(
        id: 'unused',
        goalId: goalId,
        accountId: 'usd',
        amount: 600,
        date: DateTime.now(),
      ),
    );
    // Account now holds 400; the jar holds 600.
    await addItem('Camera', 900, goalId: goalId);
    await addItem('Phone', 500, goalId: goalId);
    await addItem('TV', 900); // same price, not linked

    final camera = await verdictFor('Camera');
    expect(camera.status, AffordabilityStatus.affordable);
    expect(camera.coveredByGoal, isFalse);
    expect((await verdictFor('Phone')).coveredByGoal, isTrue);

    final tv = await verdictFor('TV');
    expect(tv.status, AffordabilityStatus.insufficientFunds);
    expect(tv.shortfall, 500);
  });

  test('marking an item purchased updates the verdict', () async {
    await addItem('Book', 20);
    final item = (await container.read(wishlistProvider.future)).single;

    await container.read(wishlistProvider.notifier).markPurchased(item);

    final verdict = await verdictFor('Book');
    expect(verdict.status, AffordabilityStatus.purchased);
    expect(verdict.item.purchasedAt, isNotNull);
  });
}
