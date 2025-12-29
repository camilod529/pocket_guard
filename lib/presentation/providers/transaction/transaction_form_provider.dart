import 'package:formz/formz.dart';
import 'package:money_manager_flutter/domain/entities/category.dart';
import 'package:money_manager_flutter/domain/entities/transaction.dart';
import 'package:money_manager_flutter/infrastructure/inputs/generic_string.dart';
import 'package:money_manager_flutter/infrastructure/inputs/transactions/amount.dart';
import 'package:money_manager_flutter/infrastructure/inputs/transactions/description.dart';
import 'package:money_manager_flutter/presentation/providers/account/account_provider.dart';
import 'package:money_manager_flutter/presentation/providers/category/categories_provider.dart';
import 'package:money_manager_flutter/presentation/providers/transaction/transaction_provider.dart';
import 'package:money_manager_flutter/presentation/providers/transaction/transactions_provider.dart';
import 'package:money_manager_flutter/utils/constants/global_constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_form_provider.g.dart';

@Riverpod(keepAlive: false)
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
        hasFormBeenModified: true,
        isFormValid: _isValid(
          description: currentState.description,
          amount: currentState.amount,
          categoryId: currentState.categoryId,
          accountId: accountId,
          toAccountId: currentState.toAccountId,
          type: currentState.type,
        ),
      ),
    );
  }

  void amountChanged(double value) {
    final currentState = state.value;
    if (currentState == null) return;

    final amount = TransactionAmount.dirty(value);
    state = AsyncValue.data(
      currentState.copyWith(
        hasFormBeenModified: true,
        amount: amount,
        isFormValid: _isValid(
          amount: amount,
          description: currentState.description,
          categoryId: currentState.categoryId,
          accountId: currentState.accountId,
          toAccountId: currentState.toAccountId,
          type: currentState.type,
        ),
      ),
    );
  }

  @override
  Future<TransactionFormState> build(
    String transactionId, {
    DateTime? selectedDate,
  }) async {
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
          amount: TransactionAmount.dirty(transaction.amount),
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
          account: transaction.accountId.isNotEmpty
              ? GenericStringInput.dirty(transaction.accountId)
              : const GenericStringInput.pure(),
          category: GenericStringInput.dirty(transaction.categoryId),
          // Handle transfer fields
          toAccountId: transaction.toAccountId,
          toAccount: transaction.toAccountId != null
              ? GenericStringInput.dirty(transaction.toAccountId!)
              : const GenericStringInput.pure(),
        );
      }
    }

    // Default to expense for new transactions
    return TransactionFormState(
      type: TransactionType.expense,
      date:
          selectedDate?.copyWith(
            hour: DateTime.now().hour,
            minute: DateTime.now().minute,
            second: DateTime.now().second,
          ) ??
          DateTime.now(),
      amount: const TransactionAmount.pure(),
      description: const TransactionDescription.pure(),
      toAccount: const GenericStringInput.pure(),
      isFormValid: false,
      accountId: null,
      categoryId: null,
      toAccountId: null,
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
        hasFormBeenModified: true,
        category: category,
        isFormValid: _isValid(
          description: currentState.description,
          amount: currentState.amount,
          categoryId: categoryId,
          accountId: currentState.accountId,
          toAccountId: currentState.toAccountId,
          type: currentState.type,
        ),
      ),
    );
  }

  void dateChanged(DateTime date) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(date: date, hasFormBeenModified: true),
    );
  }

  void descriptionChanged(String value) {
    final currentState = state.value;
    if (currentState == null) return;

    final description = TransactionDescription.dirty(value);
    state = AsyncValue.data(
      currentState.copyWith(
        hasFormBeenModified: true,
        description: description,
        isFormValid: _isValid(
          description: description,
          amount: currentState.amount,
          categoryId: currentState.categoryId,
          accountId: currentState.accountId,
          toAccountId: currentState.toAccountId,
          type: currentState.type,
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
      // Create transaction entity based on type
      final transaction = TransactionEntity(
        id: validState.id,
        amount: validState.amount.value,
        description: validState.description.value,
        categoryId: validState.categoryId!,
        date: validState.date,
        accountId: validState.accountId!,
        // Include toAccountId for transfers
        toAccountId: validState.type == TransactionType.transfer
            ? validState.toAccountId
            : null,
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

      // Refresh affected accounts
      ref
          .read(accountProvider(transaction.accountId).notifier)
          .refreshAccount();

      // If transfer, also refresh the destination account
      if (validState.type == TransactionType.transfer &&
          transaction.toAccountId != null) {
        ref
            .read(accountProvider(transaction.toAccountId!).notifier)
            .refreshAccount();
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  void toAccountChanged(String? toAccountId) {
    final currentState = state.value;
    if (currentState == null) return;

    final toAccount = toAccountId != null
        ? GenericStringInput.dirty(toAccountId)
        : const GenericStringInput.pure();

    state = AsyncValue.data(
      currentState.copyWith(
        toAccountId: toAccountId,
        toAccount: toAccount,
        hasFormBeenModified: true,
        isFormValid: _isValid(
          description: currentState.description,
          amount: currentState.amount,
          categoryId: currentState.categoryId,
          accountId: currentState.accountId,
          toAccountId: toAccountId,
          type: currentState.type,
        ),
      ),
    );
  }

  void typeChanged(TransactionType type) async {
    final currentState = state.value;
    if (currentState == null) return;

    if (type == TransactionType.transfer) {
      // Auto-select transfer category if none selected
      final categories = await ref.read(categoriesProvider.future);
      final transferCategory = categories.firstWhere(
        (cat) => cat.type == TransactionType.transfer,
      );
      state = AsyncValue.data(
        currentState.copyWith(
          type: type,
          categoryId: transferCategory.id,
          category: GenericStringInput.dirty(transferCategory.id),
          hasFormBeenModified: true,
          accountId: null,
          account: const GenericStringInput.pure(),
          toAccountId: null,
          toAccount: const GenericStringInput.pure(),
          isFormValid: false,
        ),
      );
      return;
    }

    // For income/expense, reset category and accounts
    state = AsyncValue.data(
      currentState.copyWith(
        type: type,
        hasFormBeenModified: true,
        categoryId: null, // Reset category for income/expense
        category: const GenericStringInput.pure(),
        accountId: currentState.accountId,
        account: currentState.account,
        toAccountId: null,
        toAccount: const GenericStringInput.pure(),
        isFormValid: false,
      ),
    );
  }

  bool _isValid({
    required TransactionDescription description,
    required TransactionAmount amount,
    String? categoryId,
    String? accountId,
    String? toAccountId,
    required TransactionType type,
  }) {
    final category = categoryId != null
        ? GenericStringInput.dirty(categoryId)
        : const GenericStringInput.pure();
    final account = accountId != null
        ? GenericStringInput.dirty(accountId)
        : const GenericStringInput.pure();
    final toAccount = toAccountId != null
        ? GenericStringInput.dirty(toAccountId)
        : const GenericStringInput.pure();

    if (type == TransactionType.transfer) {
      // For transfer: description + amount + from + to
      // No category required for transfers
      return Formz.validate([description, amount, account, toAccount]);
    }

    // For income/expense: description + amount + category + account
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
    final toAccount = currentState.toAccountId != null
        ? GenericStringInput.dirty(currentState.toAccountId!)
        : const GenericStringInput.pure();

    final List<FormzInput> fieldsToValidate;
    if (currentState.type == TransactionType.transfer) {
      fieldsToValidate = [amount, description, account, toAccount];
    } else {
      fieldsToValidate = [amount, description, category, account];
    }

    state = AsyncValue.data(
      currentState.copyWith(
        amount: amount,
        description: description,
        category: category,
        account: account,
        toAccount: toAccount,
        isFormPure: false,
        hasFormBeenModified: true,
        isFormValid: Formz.validate(fieldsToValidate),
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
  final GenericStringInput toAccount;
  final String? toAccountId;
  final String? categoryId;
  final String? accountId;
  final DateTime date;
  final TransactionType type;
  final bool isFormPure;
  final bool hasFormBeenModified;

  const TransactionFormState({
    this.isFormValid = false,
    this.id = GlobalConstants.createId,
    this.amount = const TransactionAmount.pure(),
    this.description = const TransactionDescription.pure(),
    this.category = const GenericStringInput.pure(),
    this.account = const GenericStringInput.pure(),
    this.toAccount = const GenericStringInput.pure(),
    this.toAccountId,
    this.categoryId,
    this.accountId,
    required this.date,
    required this.type,
    this.isFormPure = true,
    this.hasFormBeenModified = false,
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
    GenericStringInput? toAccount,
    String? toAccountId,
    String? categoryId,
    DateTime? date,
    TransactionType? type,
    bool? isFormPure,
    String? accountId,
    bool? hasFormBeenModified,
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
      isFormPure: isFormPure ?? this.isFormPure,
      accountId: accountId ?? this.accountId,
      hasFormBeenModified: hasFormBeenModified ?? this.hasFormBeenModified,
      toAccount: toAccount ?? this.toAccount,
      toAccountId: toAccountId ?? this.toAccountId,
    );
  }
}
