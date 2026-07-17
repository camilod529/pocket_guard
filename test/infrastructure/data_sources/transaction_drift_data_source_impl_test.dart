import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/domain/entities/transaction.dart';
import 'package:pocket_guard/infrastructure/data_sources/transaction_drift_data_source_impl.dart';

void main() {
  late AppDatabase testDb;
  late TransactionDriftDataSourceImpl dataSource;
  late String accountAId;
  late String accountBId;
  late String transferCategoryId;
  late String expenseCategoryId;

  Future<double> balanceOf(String accountId) => testDb.getAccountBalance(accountId);

  Future<String> onlyTransactionId() async {
    final rows = await testDb.select(testDb.transactions).get();
    expect(rows, hasLength(1));
    return rows.single.id;
  }

  setUp(() async {
    testDb = AppDatabase(NativeDatabase.memory());
    dataSource = TransactionDriftDataSourceImpl(database: testDb);

    accountAId = 'account-a';
    accountBId = 'account-b';

    await testDb
        .into(testDb.accounts)
        .insert(
          AccountsCompanion.insert(
            id: const Value('account-a'),
            name: 'Account A',
            currency: 'USD',
            balance: const Value(1000),
          ),
        );
    await testDb
        .into(testDb.accounts)
        .insert(
          AccountsCompanion.insert(
            id: const Value('account-b'),
            name: 'Account B',
            currency: 'USD',
            balance: const Value(1000),
          ),
        );

    final categories = await testDb.select(testDb.categories).get();
    transferCategoryId = categories
        .firstWhere((c) => c.type == TransactionType.transfer)
        .id;
    expenseCategoryId = categories
        .firstWhere((c) => c.type == TransactionType.expense)
        .id;
  });

  tearDown(() async {
    await testDb.close();
  });

  test('creating a transfer debits the source and credits the destination', () async {
    await dataSource.createTransaction(
      TransactionEntity(
        id: 'unused',
        accountId: accountAId,
        toAccountId: accountBId,
        amount: 100,
        date: DateTime(2026),
        categoryId: transferCategoryId,
      ),
    );

    expect(await balanceOf(accountAId), 900);
    expect(await balanceOf(accountBId), 1100);
  });

  test('editing a transfer to swap the from/to accounts nets out correctly', () async {
    await dataSource.createTransaction(
      TransactionEntity(
        id: 'unused',
        accountId: accountAId,
        toAccountId: accountBId,
        amount: 100,
        date: DateTime(2026),
        categoryId: transferCategoryId,
      ),
    );
    final id = await onlyTransactionId();

    // Same amount, but now flowing B -> A instead of A -> B.
    await dataSource.updateTransaction(
      id,
      TransactionEntity(
        id: id,
        accountId: accountBId,
        toAccountId: accountAId,
        amount: 100,
        date: DateTime(2026),
        categoryId: transferCategoryId,
      ),
    );

    expect(await balanceOf(accountAId), 1100);
    expect(await balanceOf(accountBId), 900);
  });

  test('editing a transfer amount only re-applies the new delta', () async {
    await dataSource.createTransaction(
      TransactionEntity(
        id: 'unused',
        accountId: accountAId,
        toAccountId: accountBId,
        amount: 100,
        date: DateTime(2026),
        categoryId: transferCategoryId,
      ),
    );
    final id = await onlyTransactionId();

    await dataSource.updateTransaction(
      id,
      TransactionEntity(
        id: id,
        accountId: accountAId,
        toAccountId: accountBId,
        amount: 50,
        date: DateTime(2026),
        categoryId: transferCategoryId,
      ),
    );

    expect(await balanceOf(accountAId), 950);
    expect(await balanceOf(accountBId), 1050);
  });

  test('editing a transfer into an expense reverses both legs and applies the new type', () async {
    await dataSource.createTransaction(
      TransactionEntity(
        id: 'unused',
        accountId: accountAId,
        toAccountId: accountBId,
        amount: 100,
        date: DateTime(2026),
        categoryId: transferCategoryId,
      ),
    );
    final id = await onlyTransactionId();

    await dataSource.updateTransaction(
      id,
      TransactionEntity(
        id: id,
        accountId: accountAId,
        amount: 30,
        date: DateTime(2026),
        categoryId: expenseCategoryId,
      ),
    );

    expect(await balanceOf(accountAId), 970);
    expect(await balanceOf(accountBId), 1000);
  });

  test('deleting an edited transfer reverses the latest (not the original) effect', () async {
    await dataSource.createTransaction(
      TransactionEntity(
        id: 'unused',
        accountId: accountAId,
        toAccountId: accountBId,
        amount: 100,
        date: DateTime(2026),
        categoryId: transferCategoryId,
      ),
    );
    final id = await onlyTransactionId();

    await dataSource.updateTransaction(
      id,
      TransactionEntity(
        id: id,
        accountId: accountBId,
        toAccountId: accountAId,
        amount: 100,
        date: DateTime(2026),
        categoryId: transferCategoryId,
      ),
    );

    await dataSource.deleteTransaction(id);

    expect(await balanceOf(accountAId), 1000);
    expect(await balanceOf(accountBId), 1000);
  });
}
