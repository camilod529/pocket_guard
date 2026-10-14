import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/domain/entities/account.dart';
import 'package:pocket_guard/infrastructure/data_sources/account_drift_data_source_impl.dart';
import 'package:pocket_guard/presentation/providers/account/account_form_provider.dart';
import 'package:pocket_guard/presentation/providers/account/account_provider.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/utils/constants/global_constants.dart';

/// Fails every write, to check failures reach the form instead of being
/// swallowed into the list provider's state.
class _FailingWrites extends AccountDriftDataSourceImpl {
  _FailingWrites(AppDatabase database) : super(database: database);

  @override
  Future<void> createAccount(AccountEntity account) =>
      Future.error(StateError('disk full'));

  @override
  Future<void> updateAccount(String id, AccountEntity account) =>
      Future.error(StateError('disk full'));
}

void main() {
  late AppDatabase testDb;
  late ProviderContainer container;

  ProviderContainer containerWith(AccountDriftDataSourceImpl dataSource) {
    final c = ProviderContainer(
      overrides: [accountDataSourceProvider.overrideWith((ref) => dataSource)],
    );
    addTearDown(c.dispose);
    // Kept alive like the app does (the Accounts and Calendar screens watch
    // it) - it's auto-dispose, and its methods no-op once disposed.
    c.listen(accountsProvider, (_, _) {});
    return c;
  }

  setUp(() {
    testDb = AppDatabase(NativeDatabase.memory());
    container = containerWith(AccountDriftDataSourceImpl(database: testDb));
  });

  tearDown(() async {
    await testDb.close();
  });

  Future<bool> submitForm(
    String id, {
    String? name,
    String currency = 'USD',
    double? balance,
    AccountType? type,
  }) async {
    final provider = accountFormProvider(id);
    final sub = container.listen(provider, (_, _) {});
    try {
      await container.read(provider.future);
      final form = container.read(provider.notifier);
      if (name != null) form.nameChanged(name);
      form.currencyChanged(currency);
      if (balance != null) form.balanceChanged(balance);
      if (type != null) form.typeChanged(type);
      return await form.onFormSubmit();
    } finally {
      sub.close();
    }
  }

  Future<List<AccountEntity>> accountsOfType(AccountType type) async {
    final all = await container.read(accountsProvider.future);
    return all.where((a) => a.type == type).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  // New accounts default to the asset type.
  test('creating accounts appends each to the end of its type', () async {
    expect(await submitForm(GlobalConstants.createId, name: 'Wallet'), isTrue);
    expect(await submitForm(GlobalConstants.createId, name: 'Piggy'), isTrue);
    expect(
      await submitForm(
        GlobalConstants.createId,
        name: 'Visa',
        type: AccountType.credit,
      ),
      isTrue,
    );

    final assets = await accountsOfType(AccountType.asset);
    expect(assets.map((a) => (a.name, a.sortOrder)), [
      ('Wallet', 0),
      ('Piggy', 1),
    ]);
    expect((await accountsOfType(AccountType.credit)).single.sortOrder, 0);
  });

  test('the form rejects an invalid currency without saving', () async {
    expect(
      await submitForm(
        GlobalConstants.createId,
        name: 'Wallet',
        currency: 'us',
      ),
      isFalse,
    );
    expect(await container.read(accountsProvider.future), isEmpty);
  });

  test('editing keeps the sort order and refreshes the single-account '
      'cache', () async {
    await submitForm(GlobalConstants.createId, name: 'Wallet');
    await submitForm(GlobalConstants.createId, name: 'Piggy');
    final piggy = (await accountsOfType(AccountType.asset)).last;
    expect(
      (await container.read(accountProvider(piggy.id).future))!.name,
      'Piggy',
    );

    expect(await submitForm(piggy.id, name: 'Jar', balance: 75), isTrue);

    final cached = await container.read(accountProvider(piggy.id).future);
    expect(cached!.name, 'Jar');
    expect(cached.balance, 75);
    expect(cached.sortOrder, 1);
  });

  test('a failed save is reported to the form, and the list stays '
      'usable', () async {
    container = containerWith(_FailingWrites(testDb));

    expect(await submitForm(GlobalConstants.createId, name: 'Wallet'), isFalse);
    final list = container.read(accountsProvider);
    expect(list.hasError, isFalse);
  });

  group('reorderAccounts takes the final position (onReorderItem)', () {
    setUp(() async {
      for (final name in ['Alpha', 'Bravo', 'Charlie', 'Delta']) {
        expect(await submitForm(GlobalConstants.createId, name: name), isTrue);
      }
    });

    Future<List<String>> order() async =>
        (await accountsOfType(AccountType.asset)).map((a) => a.name).toList();

    test('moving down', () async {
      await container
          .read(accountsProvider.notifier)
          .reorderAccounts(0, 2, await accountsOfType(AccountType.asset));
      expect(await order(), ['Bravo', 'Charlie', 'Alpha', 'Delta']);
    });

    test('moving up', () async {
      await container
          .read(accountsProvider.notifier)
          .reorderAccounts(3, 1, await accountsOfType(AccountType.asset));
      expect(await order(), ['Alpha', 'Delta', 'Bravo', 'Charlie']);
    });
  });
}
