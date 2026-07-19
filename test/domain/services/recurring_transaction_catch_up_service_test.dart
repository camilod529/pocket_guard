import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/domain/entities/recurring_transaction.dart';
import 'package:pocket_guard/domain/services/recurring_transaction_catch_up_service.dart';
import 'package:pocket_guard/infrastructure/data_sources/recurring_transaction_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/transaction_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/repositories/recurring_transaction_repository_impl.dart';
import 'package:pocket_guard/infrastructure/repositories/transaction_repository_impl.dart';

void main() {
  late AppDatabase testDb;
  late RecurringTransactionCatchUpService service;
  late RecurringTransactionDriftDataSourceImpl recurringDataSource;
  const checkingId = 'checking';
  const savingsId = 'savings';

  Future<double> balanceOf(String accountId) => testDb.getAccountBalance(accountId);

  setUp(() async {
    testDb = AppDatabase(NativeDatabase.memory());

    recurringDataSource = RecurringTransactionDriftDataSourceImpl(
      database: testDb,
    );
    service = RecurringTransactionCatchUpService(
      recurringTransactionRepository: RecurringTransactionRepositoryImpl(
        dataSource: recurringDataSource,
      ),
      transactionRepository: TransactionRepositoryImpl(
        dataSource: TransactionDriftDataSourceImpl(database: testDb),
      ),
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
  });

  tearDown(() async {
    await testDb.close();
  });

  Future<String> expenseCategoryId() async {
    final categories = await testDb.select(testDb.categories).get();
    return categories.firstWhere((c) => c.type == TransactionType.expense).id;
  }

  Future<String> transferCategoryId() async {
    final categories = await testDb.select(testDb.categories).get();
    return categories
        .firstWhere((c) => c.type == TransactionType.transfer)
        .id;
  }

  test('generates a due expense rule and advances its nextDueDate', () async {
    await recurringDataSource.createRecurringTransaction(
      RecurringTransactionEntity(
        id: 'unused',
        accountId: checkingId,
        categoryId: await expenseCategoryId(),
        amount: 15,
        description: 'Netflix',
        frequency: RecurrenceFrequency.monthly,
        startDate: DateTime(2026, 1, 1),
        nextDueDate: DateTime(2026, 1, 1),
        isActive: true,
      ),
    );

    final summary = await service.run(now: DateTime(2026, 1, 1));

    expect(summary.generatedCount, 1);
    expect(await balanceOf(checkingId), 985);

    final rule = (await recurringDataSource.getAllRecurringTransactions())
        .single;
    expect(rule.nextDueDate, DateTime(2026, 2, 1));
    expect(rule.lastGeneratedDate, DateTime(2026, 1, 1));
  });

  test('backfills a 3-months-overdue rule as 3 separate transactions', () async {
    await recurringDataSource.createRecurringTransaction(
      RecurringTransactionEntity(
        id: 'unused',
        accountId: checkingId,
        categoryId: await expenseCategoryId(),
        amount: 100,
        description: 'Rent',
        frequency: RecurrenceFrequency.monthly,
        startDate: DateTime(2026, 1, 1),
        nextDueDate: DateTime(2026, 1, 1),
        isActive: true,
      ),
    );

    final summary = await service.run(now: DateTime(2026, 3, 15));

    expect(summary.generatedCount, 3);
    expect(await balanceOf(checkingId), 700);
  });

  test('generates a due transfer rule affecting both accounts', () async {
    await recurringDataSource.createRecurringTransaction(
      RecurringTransactionEntity(
        id: 'unused',
        accountId: checkingId,
        toAccountId: savingsId,
        categoryId: await transferCategoryId(),
        amount: 200,
        description: 'Auto-save',
        frequency: RecurrenceFrequency.monthly,
        startDate: DateTime(2026, 1, 1),
        nextDueDate: DateTime(2026, 1, 1),
        isActive: true,
      ),
    );

    final summary = await service.run(now: DateTime(2026, 1, 1));

    expect(summary.generatedCount, 1);
    expect(await balanceOf(checkingId), 800);
    expect(await balanceOf(savingsId), 1200);
  });

  test('a rule not yet due generates nothing', () async {
    await recurringDataSource.createRecurringTransaction(
      RecurringTransactionEntity(
        id: 'unused',
        accountId: checkingId,
        categoryId: await expenseCategoryId(),
        amount: 15,
        description: 'Netflix',
        frequency: RecurrenceFrequency.monthly,
        startDate: DateTime(2026, 2, 1),
        nextDueDate: DateTime(2026, 2, 1),
        isActive: true,
      ),
    );

    final summary = await service.run(now: DateTime(2026, 1, 1));

    expect(summary.generatedCount, 0);
    expect(await balanceOf(checkingId), 1000);
  });

  test('a paused (inactive) rule is skipped even if due', () async {
    await recurringDataSource.createRecurringTransaction(
      RecurringTransactionEntity(
        id: 'unused',
        accountId: checkingId,
        categoryId: await expenseCategoryId(),
        amount: 15,
        description: 'Netflix',
        frequency: RecurrenceFrequency.monthly,
        startDate: DateTime(2026, 1, 1),
        nextDueDate: DateTime(2026, 1, 1),
        isActive: false,
      ),
    );

    final summary = await service.run(now: DateTime(2026, 1, 1));

    expect(summary.generatedCount, 0);
    expect(await balanceOf(checkingId), 1000);
  });

  test('running catch-up twice with the same now is idempotent', () async {
    await recurringDataSource.createRecurringTransaction(
      RecurringTransactionEntity(
        id: 'unused',
        accountId: checkingId,
        categoryId: await expenseCategoryId(),
        amount: 15,
        description: 'Netflix',
        frequency: RecurrenceFrequency.monthly,
        startDate: DateTime(2026, 1, 1),
        nextDueDate: DateTime(2026, 1, 1),
        isActive: true,
      ),
    );

    await service.run(now: DateTime(2026, 1, 1));
    final secondSummary = await service.run(now: DateTime(2026, 1, 1));

    expect(secondSummary.generatedCount, 0);
    expect(await balanceOf(checkingId), 985);
  });

  test('a rule whose endDate has passed generates its final occurrence and deactivates', () async {
    await recurringDataSource.createRecurringTransaction(
      RecurringTransactionEntity(
        id: 'unused',
        accountId: checkingId,
        categoryId: await expenseCategoryId(),
        amount: 15,
        description: 'Trial subscription',
        frequency: RecurrenceFrequency.monthly,
        startDate: DateTime(2026, 1, 1),
        nextDueDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 1),
        isActive: true,
      ),
    );

    final summary = await service.run(now: DateTime(2026, 6, 1));

    expect(summary.generatedCount, 1);
    final rule = (await recurringDataSource.getAllRecurringTransactions())
        .single;
    expect(rule.isActive, isFalse);
  });
}
