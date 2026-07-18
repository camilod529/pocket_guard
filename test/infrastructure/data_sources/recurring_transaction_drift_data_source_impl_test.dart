import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/domain/entities/recurring_transaction.dart';
import 'package:pocket_guard/infrastructure/data_sources/recurring_transaction_drift_data_source_impl.dart';

void main() {
  late AppDatabase testDb;
  late RecurringTransactionDriftDataSourceImpl dataSource;
  late String accountAId;
  late String accountBId;
  late String expenseCategoryId;

  setUp(() async {
    testDb = AppDatabase(NativeDatabase.memory());
    dataSource = RecurringTransactionDriftDataSourceImpl(database: testDb);

    accountAId = 'account-a';
    accountBId = 'account-b';

    await testDb
        .into(testDb.accounts)
        .insert(
          AccountsCompanion.insert(
            id: const Value('account-a'),
            name: 'Checking',
            currency: 'USD',
            balance: const Value(1000),
          ),
        );
    await testDb
        .into(testDb.accounts)
        .insert(
          AccountsCompanion.insert(
            id: const Value('account-b'),
            name: 'Savings',
            currency: 'USD',
            balance: const Value(1000),
          ),
        );

    final categories = await testDb.select(testDb.categories).get();
    expenseCategoryId = categories
        .firstWhere((c) => c.type == TransactionType.expense)
        .id;
  });

  tearDown(() async {
    await testDb.close();
  });

  RecurringTransactionEntity buildRule({
    String? toAccountId,
    DateTime? endDate,
    DateTime? lastGeneratedDate,
    bool isActive = true,
  }) {
    return RecurringTransactionEntity(
      id: 'unused',
      accountId: accountAId,
      toAccountId: toAccountId,
      categoryId: expenseCategoryId,
      amount: 42.5,
      description: 'Netflix',
      frequency: RecurrenceFrequency.monthly,
      startDate: DateTime(2026, 1, 15),
      nextDueDate: DateTime(2026, 2, 15),
      lastGeneratedDate: lastGeneratedDate,
      endDate: endDate,
      isActive: isActive,
    );
  }

  test('createRecurringTransaction then getAllRecurringTransactions round-trips all fields', () async {
    await dataSource.createRecurringTransaction(
      buildRule(
        toAccountId: accountBId,
        endDate: DateTime(2027, 1, 1),
        lastGeneratedDate: DateTime(2026, 1, 15),
      ),
    );

    final rules = await dataSource.getAllRecurringTransactions();

    expect(rules, hasLength(1));
    final rule = rules.single;
    expect(rule.accountId, accountAId);
    expect(rule.toAccountId, accountBId);
    expect(rule.categoryId, expenseCategoryId);
    expect(rule.amount, 42.5);
    expect(rule.description, 'Netflix');
    expect(rule.frequency, RecurrenceFrequency.monthly);
    expect(rule.startDate, DateTime(2026, 1, 15));
    expect(rule.nextDueDate, DateTime(2026, 2, 15));
    expect(rule.lastGeneratedDate, DateTime(2026, 1, 15));
    expect(rule.endDate, DateTime(2027, 1, 1));
    expect(rule.isActive, isTrue);
  });

  test('nullable toAccountId, endDate, and lastGeneratedDate round-trip as null', () async {
    await dataSource.createRecurringTransaction(buildRule());

    final rule = (await dataSource.getAllRecurringTransactions()).single;

    expect(rule.toAccountId, isNull);
    expect(rule.endDate, isNull);
    expect(rule.lastGeneratedDate, isNull);
  });

  test('getRecurringTransactionById returns null for an unknown id', () async {
    expect(await dataSource.getRecurringTransactionById('missing'), isNull);
  });

  test('updateRecurringTransaction persists changes', () async {
    await dataSource.createRecurringTransaction(buildRule());
    final id = (await dataSource.getAllRecurringTransactions()).single.id;

    await dataSource.updateRecurringTransaction(
      id,
      buildRule(isActive: false).copyWith(
        id: id,
        nextDueDate: DateTime(2026, 3, 15),
      ),
    );

    final updated = await dataSource.getRecurringTransactionById(id);
    expect(updated!.isActive, isFalse);
    expect(updated.nextDueDate, DateTime(2026, 3, 15));
  });

  test('deleteRecurringTransaction removes the rule', () async {
    await dataSource.createRecurringTransaction(buildRule());
    final id = (await dataSource.getAllRecurringTransactions()).single.id;

    await dataSource.deleteRecurringTransaction(id);

    expect(await dataSource.getAllRecurringTransactions(), isEmpty);
  });
}
