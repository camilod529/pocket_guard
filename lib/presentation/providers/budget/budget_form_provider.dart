import 'package:formz/formz.dart';
import 'package:pocket_guard/domain/entities/budget.dart';
import 'package:pocket_guard/infrastructure/errors/data_exceptions.dart';
import 'package:pocket_guard/infrastructure/inputs/budgets/monthly_limit.dart';
import 'package:pocket_guard/infrastructure/inputs/generic_string.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/providers/budget/budget_provider.dart';
import 'package:pocket_guard/presentation/providers/budget/budgets_provider.dart';
import 'package:pocket_guard/utils/constants/global_constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'budget_form_provider.g.dart';

/// Sentinel for [BudgetFormState.copyWith] - same pattern as
/// TransactionFormState/RecurringTransactionFormState, applied from the
/// start rather than discovered as a bug later: `param ?? this.field` can't
/// distinguish "not passed" from "explicitly cleared to null".
const _unset = Object();

/// Distinguishes *why* [BudgetForm.onFormSubmit] failed so the screen can
/// show a message that actually explains it, instead of one generic
/// "operation failed" snackbar for every possible cause.
enum BudgetSubmitError { none, duplicateCategoryCurrency, unknown }

@Riverpod(keepAlive: false)
class BudgetForm extends _$BudgetForm {
  @override
  Future<BudgetFormState> build(String id) async {
    final isCreating = id == GlobalConstants.createId;

    if (!isCreating) {
      final budget = await ref.watch(budgetProvider(id).future);
      if (budget != null) {
        return BudgetFormState(
          id: budget.id,
          monthlyLimit: BudgetMonthlyLimit.dirty(budget.monthlyLimit),
          categoryId: budget.categoryId,
          category: GenericStringInput.dirty(budget.categoryId),
          currency: budget.currency,
          currencyInput: GenericStringInput.dirty(budget.currency),
          isActive: budget.isActive,
          isFormValid: true,
        );
      }
    }

    // Creating a new budget: if every account is denominated in the same
    // currency (the common case), default to it so most users never have to
    // touch the field. With multiple currencies in play there's no safe
    // default, so leave it unselected and force an explicit choice.
    final accounts = await ref.watch(accountsProvider.future);
    final distinctCurrencies = accounts.map((a) => a.currency).toSet();
    final defaultCurrency = distinctCurrencies.length == 1
        ? distinctCurrencies.first
        : null;

    return BudgetFormState(
      monthlyLimit: const BudgetMonthlyLimit.pure(),
      categoryId: null,
      currency: defaultCurrency,
      currencyInput: defaultCurrency != null
          ? GenericStringInput.dirty(defaultCurrency)
          : const GenericStringInput.pure(),
      isFormValid: false,
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
          monthlyLimit: currentState.monthlyLimit,
          categoryId: categoryId,
          currency: currentState.currency,
        ),
      ),
    );
  }

  void currencyChanged(String? currency) {
    final currentState = state.value;
    if (currentState == null) return;

    final currencyInput = currency != null
        ? GenericStringInput.dirty(currency)
        : const GenericStringInput.pure();
    state = AsyncValue.data(
      currentState.copyWith(
        currency: currency,
        hasFormBeenModified: true,
        currencyInput: currencyInput,
        isFormValid: _isValid(
          monthlyLimit: currentState.monthlyLimit,
          categoryId: currentState.categoryId,
          currency: currency,
        ),
      ),
    );
  }

  void monthlyLimitChanged(double value) {
    final currentState = state.value;
    if (currentState == null) return;

    final monthlyLimit = BudgetMonthlyLimit.dirty(value);
    state = AsyncValue.data(
      currentState.copyWith(
        hasFormBeenModified: true,
        monthlyLimit: monthlyLimit,
        isFormValid: _isValid(
          monthlyLimit: monthlyLimit,
          categoryId: currentState.categoryId,
          currency: currentState.currency,
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

    state = AsyncValue.data(
      validState.copyWith(submitError: BudgetSubmitError.none),
    );

    // Check the already-loaded budgets list for a duplicate (category,
    // currency) pair before ever hitting the database - gives instant,
    // reliable feedback instead of depending on the DB's unique-constraint
    // exception being correctly classified. The DB constraint itself (see
    // Budgets' composite index in database.dart) is still the source of
    // truth and catches this too, as a fallback.
    final existingBudgets = ref.read(budgetsProvider).value ?? const [];
    final isDuplicate = existingBudgets.any(
      (b) =>
          b.id != validState.id &&
          b.categoryId == validState.categoryId &&
          b.currency == validState.currency,
    );
    if (isDuplicate) {
      state = AsyncValue.data(
        validState.copyWith(
          submitError: BudgetSubmitError.duplicateCategoryCurrency,
        ),
      );
      return false;
    }

    try {
      final isEditing = validState.id != GlobalConstants.createId;

      final budget = BudgetEntity(
        id: validState.id,
        categoryId: validState.categoryId!,
        monthlyLimit: validState.monthlyLimit.value,
        currency: validState.currency!,
        isActive: validState.isActive,
      );

      if (isEditing) {
        await ref
            .read(budgetsProvider.notifier)
            .updateBudget(validState.id, budget);
        // budgetProvider(id) is a separate keepAlive cache from
        // budgetsProvider (the list this form and the budget view read
        // from) - it uses ref.read, not ref.watch, so it never picks up
        // the update on its own. Same cache-split bug as
        // accountProvider(id)/accountsProvider; refresh it explicitly the
        // same way the transaction save flow does for accounts.
        await ref.read(budgetProvider(validState.id).notifier).refreshBudget();
      } else {
        await ref.read(budgetsProvider.notifier).createBudget(budget);
      }

      return true;
    } catch (e) {
      final current = state.value;
      if (current != null) {
        state = AsyncValue.data(
          current.copyWith(
            submitError: e is UniqueConstraintViolation
                ? BudgetSubmitError.duplicateCategoryCurrency
                : BudgetSubmitError.unknown,
          ),
        );
      }
      return false;
    }
  }

  bool _isValid({
    required BudgetMonthlyLimit monthlyLimit,
    String? categoryId,
    String? currency,
  }) {
    final category = categoryId != null
        ? GenericStringInput.dirty(categoryId)
        : const GenericStringInput.pure();
    final currencyInput = currency != null
        ? GenericStringInput.dirty(currency)
        : const GenericStringInput.pure();

    return Formz.validate([monthlyLimit, category, currencyInput]);
  }

  Future<void> _touchAllFields() async {
    final currentState = state.value;
    if (currentState == null) return;

    final monthlyLimit = BudgetMonthlyLimit.dirty(
      currentState.monthlyLimit.value,
    );
    final category = currentState.categoryId != null
        ? GenericStringInput.dirty(currentState.categoryId!)
        : const GenericStringInput.pure();
    final currencyInput = currentState.currency != null
        ? GenericStringInput.dirty(currentState.currency!)
        : const GenericStringInput.pure();

    state = AsyncValue.data(
      currentState.copyWith(
        monthlyLimit: monthlyLimit,
        category: category,
        currencyInput: currencyInput,
        isFormPure: false,
        hasFormBeenModified: true,
        isFormValid: _isValid(
          monthlyLimit: monthlyLimit,
          categoryId: currentState.categoryId,
          currency: currentState.currency,
        ),
      ),
    );
  }
}

class BudgetFormState {
  final bool isFormValid;
  final String id;
  final BudgetMonthlyLimit monthlyLimit;
  final GenericStringInput category;
  final String? categoryId;
  final GenericStringInput currencyInput;
  final String? currency;
  final bool isActive;
  final bool isFormPure;
  final bool hasFormBeenModified;
  final BudgetSubmitError submitError;

  const BudgetFormState({
    this.isFormValid = false,
    this.id = GlobalConstants.createId,
    required this.monthlyLimit,
    this.category = const GenericStringInput.pure(),
    required this.categoryId,
    this.currencyInput = const GenericStringInput.pure(),
    required this.currency,
    this.isActive = true,
    this.isFormPure = true,
    this.hasFormBeenModified = false,
    this.submitError = BudgetSubmitError.none,
  });

  String? get monthlyLimitError =>
      monthlyLimit.error != null ? 'Amount must be greater than 0' : null;

  bool get isMonthlyLimitPure => monthlyLimit.isPure;

  /// Same sentinel-copyWith pattern as TransactionFormState/
  /// RecurringTransactionFormState - see their doc comments for why plain
  /// `param ?? this.field` can't clear a field.
  BudgetFormState copyWith({
    bool? isFormValid,
    String? id,
    BudgetMonthlyLimit? monthlyLimit,
    GenericStringInput? category,
    Object? categoryId = _unset,
    GenericStringInput? currencyInput,
    Object? currency = _unset,
    bool? isActive,
    bool? isFormPure,
    bool? hasFormBeenModified,
    BudgetSubmitError? submitError,
  }) {
    return BudgetFormState(
      isFormValid: isFormValid ?? this.isFormValid,
      id: id ?? this.id,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      category: category ?? this.category,
      categoryId: identical(categoryId, _unset)
          ? this.categoryId
          : categoryId as String?,
      currencyInput: currencyInput ?? this.currencyInput,
      currency: identical(currency, _unset)
          ? this.currency
          : currency as String?,
      isActive: isActive ?? this.isActive,
      isFormPure: isFormPure ?? this.isFormPure,
      hasFormBeenModified: hasFormBeenModified ?? this.hasFormBeenModified,
      submitError: submitError ?? this.submitError,
    );
  }
}
