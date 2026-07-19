import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/presentation/providers/transaction/transaction_form_provider.dart';

void main() {
  TransactionFormState baseState() => TransactionFormState(
    date: DateTime(2026),
    type: TransactionType.transfer,
    accountId: 'account-a',
    categoryId: 'category-transfer',
    toAccountId: 'account-b',
  );

  test('copyWith with an argument omitted keeps the existing value', () {
    final state = baseState().copyWith(hasFormBeenModified: true);

    expect(state.accountId, 'account-a');
    expect(state.categoryId, 'category-transfer');
    expect(state.toAccountId, 'account-b');
  });

  test('copyWith with an explicit null clears accountId/categoryId/toAccountId', () {
    final state = baseState().copyWith(
      type: TransactionType.expense,
      accountId: null,
      categoryId: null,
      toAccountId: null,
    );

    expect(state.type, TransactionType.expense);
    expect(state.accountId, isNull);
    expect(state.categoryId, isNull);
    expect(state.toAccountId, isNull);
  });

  test('copyWith with a new value replaces the existing one', () {
    final state = baseState().copyWith(
      accountId: 'account-c',
      categoryId: 'category-expense',
      toAccountId: 'account-d',
    );

    expect(state.accountId, 'account-c');
    expect(state.categoryId, 'category-expense');
    expect(state.toAccountId, 'account-d');
  });
}
