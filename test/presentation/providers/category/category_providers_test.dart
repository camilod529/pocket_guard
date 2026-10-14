import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/domain/entities/transaction.dart';
import 'package:pocket_guard/infrastructure/data_sources/category_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/transaction_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/errors/data_exceptions.dart';
import 'package:pocket_guard/presentation/providers/category/categories_provider.dart';
import 'package:pocket_guard/presentation/providers/category/category_form_provider.dart';
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
      ],
    );
    // Kept alive like the app does (the category list and every form with
    // a category picker watch it) - it's auto-dispose, and its methods
    // no-op once disposed.
    container.listen(categoriesProvider, (_, _) {});
    await container.read(categoriesProvider.future);
  });

  tearDown(() async {
    container.dispose();
    await testDb.close();
  });

  Future<bool> submitForm(
    String id,
    String name, [
    TransactionType type = TransactionType.expense,
  ]) async {
    final provider = categoryFormProvider(id);
    final sub = container.listen(provider, (_, _) {});
    try {
      await container.read(provider.future);
      final form = container.read(provider.notifier);
      form.nameChanged(name);
      form.typeChanged(type);
      return await form.onFormSubmit();
    } finally {
      sub.close();
    }
  }

  Future<CategoryEntity> categoryNamed(String label) async =>
      (await container.read(
        categoriesProvider.future,
      )).firstWhere((c) => c.label == label);

  test('the form creates and edits a user category', () async {
    expect(await submitForm(GlobalConstants.createId, 'Pets'), isTrue);
    final pets = await categoryNamed('Pets');
    expect(pets.isSystem, isFalse);

    expect(
      await submitForm(pets.id, 'Side job', TransactionType.income),
      isTrue,
    );
    final edited = await categoryNamed('Side job');
    expect(edited.id, pets.id);
    expect(edited.type, TransactionType.income);
  });

  test('deleting a category still used by a transaction fails loudly and '
      'leaves the list intact', () async {
    await submitForm(GlobalConstants.createId, 'Pets');
    final pets = await categoryNamed('Pets');
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
        categoryId: pets.id,
        date: DateTime(2026),
        accountId: account.id,
      ),
    );

    await expectLater(
      container.read(categoriesProvider.notifier).deleteCategory(pets.id),
      throwsA(isA<ForeignKeyViolation>()),
    );

    final list = container.read(categoriesProvider);
    expect(list.hasError, isFalse);
    expect(list.value!.map((c) => c.id), contains(pets.id));
  });

  test('an unused category deletes', () async {
    await submitForm(GlobalConstants.createId, 'Pets');
    final pets = await categoryNamed('Pets');

    await container.read(categoriesProvider.notifier).deleteCategory(pets.id);

    expect(
      (await container.read(categoriesProvider.future)).map((c) => c.id),
      isNot(contains(pets.id)),
    );
  });
}
