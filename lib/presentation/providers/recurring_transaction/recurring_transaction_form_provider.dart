import 'package:formz/formz.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/domain/entities/recurring_transaction.dart';
import 'package:pocket_guard/domain/services/recurring_transaction_catch_up_service.dart';
import 'package:pocket_guard/infrastructure/inputs/generic_string.dart';
import 'package:pocket_guard/infrastructure/inputs/recurring_transactions/amount.dart';
import 'package:pocket_guard/infrastructure/inputs/recurring_transactions/name.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/providers/category/categories_provider.dart';
import 'package:pocket_guard/presentation/providers/recurring_transaction/recurring_transaction_catch_up_provider.dart';
import 'package:pocket_guard/presentation/providers/recurring_transaction/recurring_transaction_provider.dart';
import 'package:pocket_guard/presentation/providers/recurring_transaction/recurring_transactions_provider.dart';
import 'package:pocket_guard/presentation/providers/transaction/transactions_provider.dart';
import 'package:pocket_guard/utils/constants/global_constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recurring_transaction_form_provider.g.dart';

/// Sentinel for [RecurringTransactionFormState.copyWith] - see its doc
/// comment. Same pattern as TransactionFormState.copyWith, applied from the
/// start here rather than discovered as a bug later.
const _unset = Object();

@Riverpod(keepAlive: false)
class RecurringTransactionForm extends _$RecurringTransactionForm {
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
          name: currentState.name,
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

    final amount = RecurringTransactionAmount.dirty(value);
    state = AsyncValue.data(
      currentState.copyWith(
        hasFormBeenModified: true,
        amount: amount,
        isFormValid: _isValid(
          amount: amount,
          name: currentState.name,
          categoryId: currentState.categoryId,
          accountId: currentState.accountId,
          toAccountId: currentState.toAccountId,
          type: currentState.type,
        ),
      ),
    );
  }

  @override
  Future<RecurringTransactionFormState> build(String id) async {
    final isCreating = id == GlobalConstants.createId;

    if (!isCreating) {
      final rule = await ref.watch(recurringTransactionProvider(id).future);
      if (rule != null) {
        final category = await ref.watch(
          categoryProvider(rule.categoryId).future,
        );
        if (category == null) {
          throw Exception('Category not found for recurring transaction');
        }

        return RecurringTransactionFormState(
          id: rule.id,
          amount: RecurringTransactionAmount.dirty(rule.amount),
          name: RecurringTransactionName.dirty(rule.description),
          categoryId: rule.categoryId,
          category: GenericStringInput.dirty(rule.categoryId),
          type: category.type,
          isFormValid: true,
          accountId: rule.accountId,
          account: GenericStringInput.dirty(rule.accountId),
          toAccountId: rule.toAccountId,
          toAccount: rule.toAccountId != null
              ? GenericStringInput.dirty(rule.toAccountId!)
              : const GenericStringInput.pure(),
          frequency: rule.frequency,
          startDate: rule.startDate,
          nextDueDate: rule.nextDueDate,
          endDate: rule.endDate,
          isActive: rule.isActive,
        );
      }
    }

    final now = DateTime.now();
    return RecurringTransactionFormState(
      type: TransactionType.expense,
      startDate: now,
      nextDueDate: now,
      amount: const RecurringTransactionAmount.pure(),
      name: const RecurringTransactionName.pure(),
      toAccount: const GenericStringInput.pure(),
      isFormValid: false,
      accountId: null,
      categoryId: null,
      toAccountId: null,
      frequency: RecurrenceFrequency.monthly,
      endDate: null,
      isActive: true,
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
          name: currentState.name,
          amount: currentState.amount,
          categoryId: categoryId,
          accountId: currentState.accountId,
          toAccountId: currentState.toAccountId,
          type: currentState.type,
        ),
      ),
    );
  }

  void endDateChanged(DateTime? date) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(endDate: date, hasFormBeenModified: true),
    );
  }

  void frequencyChanged(RecurrenceFrequency frequency) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(frequency: frequency, hasFormBeenModified: true),
    );
  }

  void isActiveChanged(bool isActive) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(isActive: isActive, hasFormBeenModified: true),
    );
  }

  void nameChanged(String value) {
    final currentState = state.value;
    if (currentState == null) return;

    final name = RecurringTransactionName.dirty(value);
    state = AsyncValue.data(
      currentState.copyWith(
        hasFormBeenModified: true,
        name: name,
        isFormValid: _isValid(
          name: name,
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

    await _touchAllFields();

    final validState = state.value;
    if (validState == null || !validState.isFormValid) return false;

    try {
      final isEditing = validState.id != GlobalConstants.createId;

      final rule = RecurringTransactionEntity(
        id: validState.id,
        accountId: validState.accountId!,
        toAccountId: validState.type == TransactionType.transfer
            ? validState.toAccountId
            : null,
        categoryId: validState.categoryId!,
        amount: validState.amount.value,
        description: validState.name.value,
        frequency: validState.frequency,
        startDate: validState.startDate,
        nextDueDate: validState.nextDueDate,
        endDate: validState.endDate,
        isActive: validState.isActive,
      );

      if (isEditing) {
        await ref
            .read(recurringTransactionsProvider.notifier)
            .updateRecurringTransaction(validState.id, rule);
      } else {
        await ref
            .read(recurringTransactionsProvider.notifier)
            .createRecurringTransaction(rule);
      }

      // Generate immediately if the rule (or an edit to it) is already due,
      // rather than requiring the user to relaunch the app to see anything
      // happen. Reuses the same catch-up service as app-open/background so
      // there's only one place that decides "is this due".
      final service = RecurringTransactionCatchUpService(
        recurringTransactionRepository: ref.read(
          recurringTransactionRepositoryProvider,
        ),
        transactionRepository: ref.read(transactionRepositoryProvider),
      );
      final summary = await service.run(now: ref.read(currentDateTimeProvider));
      if (summary.generatedCount > 0) {
        ref.invalidate(transactionsProvider);
        ref.invalidate(accountsProvider);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  void startDateChanged(DateTime date) {
    final currentState = state.value;
    if (currentState == null) return;

    // A rule that hasn't started generating yet moves its next occurrence
    // with the start date. Once it's been created, nextDueDate reflects
    // actual generation progress and editing startDate shouldn't rewind it.
    final isCreating = currentState.id == GlobalConstants.createId;

    state = AsyncValue.data(
      currentState.copyWith(
        startDate: date,
        nextDueDate: isCreating ? date : currentState.nextDueDate,
        hasFormBeenModified: true,
      ),
    );
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
          name: currentState.name,
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

    state = AsyncValue.data(
      currentState.copyWith(
        type: type,
        hasFormBeenModified: true,
        categoryId: null,
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
    required RecurringTransactionName name,
    required RecurringTransactionAmount amount,
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
      final accountsDiffer = accountId != null && accountId != toAccountId;
      return Formz.validate([name, amount, account, toAccount]) &&
          accountsDiffer;
    }

    return Formz.validate([name, amount, category, account]);
  }

  Future<void> _touchAllFields() async {
    final currentState = state.value;
    if (currentState == null) return;

    final amount = RecurringTransactionAmount.dirty(currentState.amount.value);
    final name = RecurringTransactionName.dirty(currentState.name.value);
    final category = currentState.categoryId != null
        ? GenericStringInput.dirty(currentState.categoryId!)
        : const GenericStringInput.pure();
    final account = currentState.accountId != null
        ? GenericStringInput.dirty(currentState.accountId!)
        : const GenericStringInput.pure();
    final toAccount = currentState.toAccountId != null
        ? GenericStringInput.dirty(currentState.toAccountId!)
        : const GenericStringInput.pure();

    state = AsyncValue.data(
      currentState.copyWith(
        amount: amount,
        name: name,
        category: category,
        account: account,
        toAccount: toAccount,
        isFormPure: false,
        hasFormBeenModified: true,
        isFormValid: _isValid(
          name: name,
          amount: amount,
          categoryId: currentState.categoryId,
          accountId: currentState.accountId,
          toAccountId: currentState.toAccountId,
          type: currentState.type,
        ),
      ),
    );
  }
}

class RecurringTransactionFormState {
  final bool isFormValid;
  final String id;
  final RecurringTransactionAmount amount;
  final RecurringTransactionName name;
  final GenericStringInput category;
  final GenericStringInput account;
  final GenericStringInput toAccount;
  final String? toAccountId;
  final String? categoryId;
  final String? accountId;
  final TransactionType type;
  final RecurrenceFrequency frequency;
  final DateTime startDate;
  final DateTime nextDueDate;
  final DateTime? endDate;
  final bool isActive;
  final bool isFormPure;
  final bool hasFormBeenModified;

  const RecurringTransactionFormState({
    this.isFormValid = false,
    this.id = GlobalConstants.createId,
    this.amount = const RecurringTransactionAmount.pure(),
    this.name = const RecurringTransactionName.pure(),
    this.category = const GenericStringInput.pure(),
    this.account = const GenericStringInput.pure(),
    this.toAccount = const GenericStringInput.pure(),
    this.toAccountId,
    this.categoryId,
    this.accountId,
    required this.type,
    required this.frequency,
    required this.startDate,
    required this.nextDueDate,
    this.endDate,
    this.isActive = true,
    this.isFormPure = true,
    this.hasFormBeenModified = false,
  });

  String? get nameError =>
      name.error != null ? 'Name is required (2-200 characters)' : null;

  String? get amountError =>
      amount.error != null ? 'Amount must be greater than 0' : null;

  bool get isAmountPure => amount.isPure;
  bool get isNamePure => name.isPure;

  /// Same sentinel-copyWith pattern as TransactionFormState - see its doc
  /// comment for why plain `param ?? this.field` can't clear a field.
  RecurringTransactionFormState copyWith({
    bool? isFormValid,
    String? id,
    RecurringTransactionAmount? amount,
    RecurringTransactionName? name,
    GenericStringInput? category,
    GenericStringInput? account,
    GenericStringInput? toAccount,
    Object? toAccountId = _unset,
    Object? categoryId = _unset,
    TransactionType? type,
    RecurrenceFrequency? frequency,
    DateTime? startDate,
    DateTime? nextDueDate,
    Object? endDate = _unset,
    bool? isActive,
    bool? isFormPure,
    Object? accountId = _unset,
    bool? hasFormBeenModified,
  }) {
    return RecurringTransactionFormState(
      isFormValid: isFormValid ?? this.isFormValid,
      id: id ?? this.id,
      amount: amount ?? this.amount,
      name: name ?? this.name,
      category: category ?? this.category,
      account: account ?? this.account,
      categoryId: identical(categoryId, _unset)
          ? this.categoryId
          : categoryId as String?,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      endDate: identical(endDate, _unset) ? this.endDate : endDate as DateTime?,
      isActive: isActive ?? this.isActive,
      isFormPure: isFormPure ?? this.isFormPure,
      accountId: identical(accountId, _unset)
          ? this.accountId
          : accountId as String?,
      hasFormBeenModified: hasFormBeenModified ?? this.hasFormBeenModified,
      toAccount: toAccount ?? this.toAccount,
      toAccountId: identical(toAccountId, _unset)
          ? this.toAccountId
          : toAccountId as String?,
    );
  }
}
