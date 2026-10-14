import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/domain/entities/account.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/domain/entities/transaction.dart';
import 'package:pocket_guard/infrastructure/data_sources/account_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/transaction_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/errors/data_exceptions.dart';
import 'package:pocket_guard/utils/constants/global_constants.dart';

void main() {
  late AppDatabase testDb;
  late AccountDriftDataSourceImpl dataSource;

  setUp(() {
    testDb = AppDatabase(NativeDatabase.memory());
    dataSource = AccountDriftDataSourceImpl(database: testDb);
  });

  tearDown(() async {
    await testDb.close();
  });

  AccountEntity buildAccount({
    String name = 'Checking',
    String currency = 'USD',
    double balance = 100,
    AccountType type = AccountType.cash,
    int sortOrder = 0,
  }) => AccountEntity(
    id: GlobalConstants.createId,
    name: name,
    currency: currency,
    balance: balance,
    type: type,
    sortOrder: sortOrder,
  );

  Future<String> createAndGetId([String name = 'Checking']) async {
    await dataSource.createAccount(buildAccount(name: name));
    return (await dataSource.getAllAccounts())
        .firstWhere((a) => a.name == name)
        .id;
  }

  test('createAccount then getAccountById round-trips all fields', () async {
    await dataSource.createAccount(
      buildAccount(
        name: 'Card',
        currency: 'EUR',
        balance: -42.5,
        type: AccountType.credit,
        sortOrder: 3,
      ),
    );

    final id = (await dataSource.getAllAccounts()).single.id;
    final account = await dataSource.getAccountById(id);
    expect(account!.name, 'Card');
    expect(account.currency, 'EUR');
    expect(account.balance, -42.5);
    expect(account.type, AccountType.credit);
    expect(account.sortOrder, 3);
  });

  test('getAccountById returns null for an unknown id', () async {
    expect(await dataSource.getAccountById('missing'), isNull);
  });

  test('updateAccount persists changes', () async {
    final id = await createAndGetId();

    await dataSource.updateAccount(
      id,
      buildAccount(name: 'Main', balance: 250, sortOrder: 2),
    );

    final updated = await dataSource.getAccountById(id);
    expect(updated!.name, 'Main');
    expect(updated.balance, 250);
    expect(updated.sortOrder, 2);
  });

  test(
    'searchAccounts matches by name and returns all for a blank query',
    () async {
      await createAndGetId('Checking');
      await createAndGetId('Savings');

      expect((await dataSource.searchAccounts('sav')).map((a) => a.name), [
        'Savings',
      ]);
      expect(await dataSource.searchAccounts('  '), hasLength(2));
    },
  );

  group('missing ids report DataNotFoundException', () {
    test('update', () async {
      await expectLater(
        dataSource.updateAccount('missing', buildAccount()),
        throwsA(isA<DataNotFoundException>()),
      );
    });

    test('delete', () async {
      await expectLater(
        dataSource.deleteAccount('missing'),
        throwsA(isA<DataNotFoundException>()),
      );
    });
  });

  test('deleting an account also deletes its transactions', () async {
    final id = await createAndGetId();
    final categories = await testDb.select(testDb.categories).get();
    await TransactionDriftDataSourceImpl(database: testDb).createTransaction(
      TransactionEntity(
        id: 'unused',
        amount: 10,
        description: null,
        categoryId: categories
            .firstWhere((c) => c.type == TransactionType.expense)
            .id,
        date: DateTime(2026),
        accountId: id,
      ),
    );

    await dataSource.deleteAccount(id);

    expect(await dataSource.getAllAccounts(), isEmpty);
    expect(await testDb.select(testDb.transactions).get(), isEmpty);
  });
}
