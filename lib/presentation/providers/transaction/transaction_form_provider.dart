import 'package:formz/formz.dart';
import 'package:money_manager_flutter/domain/entities/category.dart';
import 'package:money_manager_flutter/domain/entities/transaction.dart';
import 'package:money_manager_flutter/infrastructure/inputs/generic_string.dart';
import 'package:money_manager_flutter/infrastructure/inputs/transactions/amount.dart';
import 'package:money_manager_flutter/infrastructure/inputs/transactions/description.dart';
import 'package:money_manager_flutter/presentation/providers/category/categories_provider.dart';
import 'package:money_manager_flutter/presentation/providers/transaction/transaction_provider.dart';
import 'package:money_manager_flutter/presentation/providers/transaction/transactions_provider.dart';
import 'package:money_manager_flutter/utils/constants/global_constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_form_provider.g.dart';

@riverpod
class TransactionForm extends _$TransactionForm {
  void accountChanged(String? accountId) {
    final currentState = state.value;
    if (currentState == null) return;

    final account = accountId != null
        ? GenericStringInput.dirty(accountId)
        : const GenericStringInput.pure();
    state = AsyncValue.data(
      currentState.copyWith(
        accountId: accountId,
        account: account,
        isFormValid: _isValid(
          currentState.description,
          currentState.amount,
          currentState.categoryId,
          accountId,
        ),
      ),
    );
  }

  void amountChanged(String value) {
    final currentState = state.value;
    if (currentState == null) return;

    final amount = TransactionAmount.dirty(value);
    state = AsyncValue.data(
      currentState.copyWith(
        amount: amount,
        isFormValid: _isValid(
          currentState.description,
          amount,
          currentState.categoryId,
          currentState.accountId,
        ),
      ),
    );
  }

  @override
  Future<TransactionFormState> build(String transactionId) async {
    final isCreating = transactionId == GlobalConstants.createId;

    if (!isCreating) {
      final transaction = await ref.watch(
        transactionProvider(transactionId).future,
      );
      if (transaction != null) {
        final category = await ref.watch(
          categoryProvider(transaction.categoryId).future,
        );

        if (category == null) {
          throw Exception('Category not found for transaction');
        }

        return TransactionFormState(
          id: transaction.id,
          amount: TransactionAmount.dirty(transaction.amount.toString()),
          description: TransactionDescription.dirty(
            transaction.description ?? '',
          ),
          categoryId: transaction.categoryId.isEmpty
              ? null
              : transaction.categoryId,
          date: transaction.date,
          type: category.type,
          isFormValid: true,
          accountId: transaction.accountId.isEmpty
              ? null
              : transaction.accountId,
        );
      }
    }

    // Default to expense for new transactions
    return TransactionFormState(
      type: TransactionType.expense,
      date: DateTime.now(),
      amount: const TransactionAmount.pure(),
      description: const TransactionDescription.pure(),
      isFormValid: false,
      accountId: null,
      categoryId: null,
    );
  }

  void categoryChanged(String? categoryId) {
    final currentState = state.value;
    if (currentState == null) return;

    final category = categoryId != null
        ? GenericStringInput.dirty(categoryId)
        : const GenericStringInput.pure();
    state = AsyncValue.data(
      currentState.copyWith(
        categoryId: categoryId,
        category: category,
        isFormValid: _isValid(
          currentState.description,
          currentState.amount,
          categoryId,
          currentState.accountId,
        ),
      ),
    );
  }

  void dateChanged(DateTime date) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(date: date));
  }

  void descriptionChanged(String value) {
    final currentState = state.value;
    if (currentState == null) return;

    final description = TransactionDescription.dirty(value);
    state = AsyncValue.data(
      currentState.copyWith(
        description: description,
        isFormValid: _isValid(
          description,
          currentState.amount,
          currentState.categoryId,
          currentState.accountId,
        ),
      ),
    );
  }

  Future<bool> onFormSubmit() async {
    final currentState = state.value;
    if (currentState == null) return false;

    _touchAllFields();

    final validState = state.value;
    if (validState == null || !validState.isFormValid) return false;

    try {
      final transaction = TransactionEntity(
        id: validState.id,
        amount: double.parse(validState.amount.value),
        description: validState.description.value,
        categoryId: validState.categoryId!,
        date: validState.date,
        accountId: validState.accountId!,
      );

      final isEditing = validState.id != GlobalConstants.createId;

      if (isEditing) {
        await ref
            .read(transactionsProvider.notifier)
            .updateTransaction(validState.id, transaction);
      } else {
        await ref
            .read(transactionsProvider.notifier)
            .createTransaction(transaction);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  void typeChanged(TransactionType type) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(
        type: type,
        categoryId: null, // Reset category when type changes
        category: const GenericStringInput.pure(),
        isFormValid: false,
      ),
    );
  }

  bool _isValid(
    TransactionDescription description,
    TransactionAmount amount,
    String? categoryId,
    String? accountId,
  ) {
    final category = categoryId != null
        ? GenericStringInput.dirty(categoryId)
        : const GenericStringInput.pure();
    final account = accountId != null
        ? GenericStringInput.dirty(accountId)
        : const GenericStringInput.pure();

    return Formz.validate([description, amount, category, account]);
  }

  void _touchAllFields() {
    final currentState = state.value;
    if (currentState == null) return;

    final amount = TransactionAmount.dirty(currentState.amount.value);
    final description = TransactionDescription.dirty(
      currentState.description.value,
    );
    final category = currentState.categoryId != null
        ? GenericStringInput.dirty(currentState.categoryId!)
        : const GenericStringInput.pure();

    final account = currentState.accountId != null
        ? GenericStringInput.dirty(currentState.accountId!)
        : const GenericStringInput.pure();

    state = AsyncValue.data(
      currentState.copyWith(
        amount: amount,
        description: description,
        category: category,
        account: account,
        isFormValid: Formz.validate([amount, description, category, account]),
      ),
    );
  }
}

class TransactionFormState {
  final bool isFormValid;
  final String id;
  final TransactionAmount amount;
  final TransactionDescription description;
  final GenericStringInput category;
  final GenericStringInput account;
  final String? categoryId;
  final String? accountId;
  final DateTime date;
  final TransactionType type;
  final bool isPure;

  const TransactionFormState({
    this.isFormValid = false,
    this.id = GlobalConstants.createId,
    this.amount = const TransactionAmount.pure(),
    this.description = const TransactionDescription.pure(),
    this.category = const GenericStringInput.pure(),
    this.account = const GenericStringInput.pure(),
    this.categoryId,
    this.accountId,
    required this.date,
    required this.type,
    this.isPure = true,
  });

  String? get amountError =>
      amount.error != null ? 'Amount must be greater than 0' : null;

  String? get descriptionError => description.error != null
      ? 'Description is required (2-200 characters)'
      : null;
  bool get isAmountPure => amount.isPure;
  bool get isDescriptionPure => description.isPure;
  TransactionFormState copyWith({
    bool? isFormValid,
    String? id,
    TransactionAmount? amount,
    TransactionDescription? description,
    GenericStringInput? category,
    GenericStringInput? account,
    String? categoryId,
    DateTime? date,
    TransactionType? type,
    bool? isPure,
    String? accountId,
  }) {
    return TransactionFormState(
      isFormValid: isFormValid ?? this.isFormValid,
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      category: category ?? this.category,
      account: account ?? this.account,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      type: type ?? this.type,
      isPure: isPure ?? this.isPure,
      accountId: accountId ?? this.accountId,
    );
  }
}
