import 'package:formz/formz.dart';
import 'package:pocket_guard/domain/entities/savings_goal.dart';
import 'package:pocket_guard/infrastructure/errors/data_exceptions.dart';
import 'package:pocket_guard/infrastructure/inputs/generic_string.dart';
import 'package:pocket_guard/infrastructure/inputs/savings_goals/target_amount.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/providers/savings_goal/savings_goal_provider.dart';
import 'package:pocket_guard/presentation/providers/savings_goal/savings_goals_provider.dart';
import 'package:pocket_guard/utils/constants/global_constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'savings_goal_form_provider.g.dart';

/// Sentinel for [SavingsGoalFormState.copyWith] - see BudgetFormState.
const _unset = Object();

enum SavingsGoalSubmitError { none, currencyLocked, unknown }

@Riverpod(keepAlive: false)
class SavingsGoalForm extends _$SavingsGoalForm {
  @override
  Future<SavingsGoalFormState> build(String id) async {
    final isCreating = id == GlobalConstants.createId;

    if (!isCreating) {
      final goal = await ref.watch(savingsGoalProvider(id).future);
      if (goal != null) {
        return SavingsGoalFormState(
          id: goal.id,
          name: GenericStringInput.dirty(goal.name),
          targetAmount: GoalAmount.dirty(goal.targetAmount),
          currency: goal.currency,
          currencyInput: GenericStringInput.dirty(goal.currency),
          targetDate: goal.targetDate,
          isArchived: goal.isArchived,
          createdAt: goal.createdAt,
          isFormValid: true,
        );
      }
    }

    // Same currency defaulting as the budget form: only pre-select when
    // every account shares one currency.
    final accounts = await ref.watch(accountsProvider.future);
    final distinctCurrencies = accounts.map((a) => a.currency).toSet();
    final defaultCurrency = distinctCurrencies.length == 1
        ? distinctCurrencies.first
        : null;

    return SavingsGoalFormState(
      currency: defaultCurrency,
      currencyInput: defaultCurrency != null
          ? GenericStringInput.dirty(defaultCurrency)
          : const GenericStringInput.pure(),
    );
  }

  void archivedChanged(bool isArchived) {
    _update((s) => s.copyWith(isArchived: isArchived));
  }

  void currencyChanged(String? currency) {
    _update(
      (s) => s.copyWith(
        currency: currency,
        currencyInput: currency != null
            ? GenericStringInput.dirty(currency)
            : const GenericStringInput.pure(),
      ),
    );
  }

  void nameChanged(String value) {
    _update((s) => s.copyWith(name: GenericStringInput.dirty(value.trim())));
  }

  Future<bool> onFormSubmit() async {
    final currentState = state.value;
    if (currentState == null) return false;

    // Touch every field so pure ones show their errors.
    final touched = currentState.copyWith(
      name: GenericStringInput.dirty(currentState.name.value),
      targetAmount: GoalAmount.dirty(currentState.targetAmount.value),
      currencyInput: GenericStringInput.dirty(currentState.currency ?? ''),
      isFormPure: false,
      submitError: SavingsGoalSubmitError.none,
    );
    final validState = touched.copyWith(isFormValid: _isValid(touched));
    state = AsyncValue.data(validState);
    if (!validState.isFormValid) return false;

    try {
      final isEditing = validState.id != GlobalConstants.createId;
      final goal = SavingsGoalEntity(
        id: validState.id,
        name: validState.name.value,
        targetAmount: validState.targetAmount.value,
        currency: validState.currency!,
        targetDate: validState.targetDate,
        isArchived: validState.isArchived,
        createdAt: validState.createdAt ?? DateTime.now(),
      );

      final notifier = ref.read(savingsGoalsProvider.notifier);
      if (isEditing) {
        await notifier.updateGoal(validState.id, goal);
      } else {
        await notifier.createGoal(goal);
      }
      return true;
    } catch (e) {
      final current = state.value;
      if (current != null) {
        state = AsyncValue.data(
          current.copyWith(
            submitError:
                e is SavingsGoalValidationException &&
                    e.reason == SavingsGoalError.currencyLocked
                ? SavingsGoalSubmitError.currencyLocked
                : SavingsGoalSubmitError.unknown,
          ),
        );
      }
      return false;
    }
  }

  void targetAmountChanged(double value) {
    _update((s) => s.copyWith(targetAmount: GoalAmount.dirty(value)));
  }

  void targetDateChanged(DateTime? targetDate) {
    _update((s) => s.copyWith(targetDate: targetDate));
  }

  bool _isValid(SavingsGoalFormState s) =>
      Formz.validate([s.name, s.targetAmount, s.currencyInput]);

  void _update(SavingsGoalFormState Function(SavingsGoalFormState) change) {
    final currentState = state.value;
    if (currentState == null) return;

    final changed = change(currentState).copyWith(hasFormBeenModified: true);
    state = AsyncValue.data(changed.copyWith(isFormValid: _isValid(changed)));
  }
}

class SavingsGoalFormState {
  final bool isFormValid;
  final String id;
  final GenericStringInput name;
  final GoalAmount targetAmount;
  final GenericStringInput currencyInput;
  final String? currency;
  final DateTime? targetDate;
  final bool isArchived;

  /// Carried through edits unchanged; null while creating.
  final DateTime? createdAt;
  final bool isFormPure;
  final bool hasFormBeenModified;
  final SavingsGoalSubmitError submitError;

  const SavingsGoalFormState({
    this.isFormValid = false,
    this.id = GlobalConstants.createId,
    this.name = const GenericStringInput.pure(),
    this.targetAmount = const GoalAmount.pure(),
    this.currencyInput = const GenericStringInput.pure(),
    this.currency,
    this.targetDate,
    this.isArchived = false,
    this.createdAt,
    this.isFormPure = true,
    this.hasFormBeenModified = false,
    this.submitError = SavingsGoalSubmitError.none,
  });

  bool get isEditing => id != GlobalConstants.createId;

  SavingsGoalFormState copyWith({
    bool? isFormValid,
    String? id,
    GenericStringInput? name,
    GoalAmount? targetAmount,
    GenericStringInput? currencyInput,
    Object? currency = _unset,
    Object? targetDate = _unset,
    bool? isArchived,
    bool? isFormPure,
    bool? hasFormBeenModified,
    SavingsGoalSubmitError? submitError,
  }) {
    return SavingsGoalFormState(
      isFormValid: isFormValid ?? this.isFormValid,
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currencyInput: currencyInput ?? this.currencyInput,
      currency: identical(currency, _unset)
          ? this.currency
          : currency as String?,
      targetDate: identical(targetDate, _unset)
          ? this.targetDate
          : targetDate as DateTime?,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
      isFormPure: isFormPure ?? this.isFormPure,
      hasFormBeenModified: hasFormBeenModified ?? this.hasFormBeenModified,
      submitError: submitError ?? this.submitError,
    );
  }
}
