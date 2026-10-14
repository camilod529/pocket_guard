import 'package:formz/formz.dart';
import 'package:pocket_guard/domain/entities/wishlist_item.dart';
import 'package:pocket_guard/infrastructure/inputs/generic_string.dart';
import 'package:pocket_guard/infrastructure/inputs/savings_goals/target_amount.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/providers/savings_goal/savings_goals_provider.dart';
import 'package:pocket_guard/presentation/providers/wishlist/wishlist_provider.dart';
import 'package:pocket_guard/utils/constants/global_constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wishlist_form_provider.g.dart';

/// Sentinel for [WishlistFormState.copyWith] - see BudgetFormState.
const _unset = Object();

@Riverpod(keepAlive: false)
class WishlistForm extends _$WishlistForm {
  @override
  Future<WishlistFormState> build(String id) async {
    if (id != GlobalConstants.createId) {
      final items = await ref.watch(wishlistProvider.future);
      final item = items.where((i) => i.id == id).firstOrNull;
      if (item != null) {
        return WishlistFormState(
          id: item.id,
          name: GenericStringInput.dirty(item.name),
          price: GoalAmount.dirty(item.price),
          currency: item.currency,
          currencyInput: GenericStringInput.dirty(item.currency),
          categoryId: item.categoryId,
          goalId: item.goalId,
          purchasedAt: item.purchasedAt,
          createdAt: item.createdAt,
          isFormValid: true,
        );
      }
    }

    // Same currency defaulting as the budget and goal forms.
    final accounts = await ref.watch(accountsProvider.future);
    final distinctCurrencies = accounts.map((a) => a.currency).toSet();
    final defaultCurrency = distinctCurrencies.length == 1
        ? distinctCurrencies.first
        : null;

    return WishlistFormState(
      currency: defaultCurrency,
      currencyInput: defaultCurrency != null
          ? GenericStringInput.dirty(defaultCurrency)
          : const GenericStringInput.pure(),
    );
  }

  void categoryChanged(String? categoryId) {
    _update((s) => s.copyWith(categoryId: categoryId));
  }

  void currencyChanged(String? currency) {
    final goals = ref.read(savingsGoalsProvider).value ?? const [];
    _update((s) {
      // A jar in a different currency can't pay for the item - drop it.
      final linkedGoal = goals.where((g) => g.id == s.goalId).firstOrNull;
      return s.copyWith(
        currency: currency,
        currencyInput: currency != null
            ? GenericStringInput.dirty(currency)
            : const GenericStringInput.pure(),
        goalId: linkedGoal?.currency == currency ? s.goalId : null,
      );
    });
  }

  void goalChanged(String? goalId) {
    _update((s) => s.copyWith(goalId: goalId));
  }

  void nameChanged(String value) {
    _update((s) => s.copyWith(name: GenericStringInput.dirty(value.trim())));
  }

  Future<bool> onFormSubmit() async {
    final currentState = state.value;
    if (currentState == null) return false;

    final touched = currentState.copyWith(
      name: GenericStringInput.dirty(currentState.name.value),
      price: GoalAmount.dirty(currentState.price.value),
      currencyInput: GenericStringInput.dirty(currentState.currency ?? ''),
      isFormPure: false,
      hasSubmitError: false,
    );
    final validState = touched.copyWith(isFormValid: _isValid(touched));
    state = AsyncValue.data(validState);
    if (!validState.isFormValid) return false;

    try {
      final item = WishlistItemEntity(
        id: validState.id,
        name: validState.name.value,
        price: validState.price.value,
        currency: validState.currency!,
        categoryId: validState.categoryId,
        goalId: validState.goalId,
        purchasedAt: validState.purchasedAt,
        createdAt: validState.createdAt ?? DateTime.now(),
      );

      final notifier = ref.read(wishlistProvider.notifier);
      if (validState.id != GlobalConstants.createId) {
        await notifier.updateItem(validState.id, item);
      } else {
        await notifier.createItem(item);
      }
      return true;
    } catch (e) {
      final current = state.value;
      if (current != null) {
        state = AsyncValue.data(current.copyWith(hasSubmitError: true));
      }
      return false;
    }
  }

  void priceChanged(double value) {
    _update((s) => s.copyWith(price: GoalAmount.dirty(value)));
  }

  bool _isValid(WishlistFormState s) =>
      Formz.validate([s.name, s.price, s.currencyInput]);

  void _update(WishlistFormState Function(WishlistFormState) change) {
    final currentState = state.value;
    if (currentState == null) return;

    final changed = change(currentState);
    state = AsyncValue.data(changed.copyWith(isFormValid: _isValid(changed)));
  }
}

class WishlistFormState {
  final bool isFormValid;
  final String id;
  final GenericStringInput name;
  final GoalAmount price;
  final GenericStringInput currencyInput;
  final String? currency;
  final String? categoryId;
  final String? goalId;

  /// Carried through edits unchanged.
  final DateTime? purchasedAt;
  final DateTime? createdAt;
  final bool isFormPure;
  final bool hasSubmitError;

  const WishlistFormState({
    this.isFormValid = false,
    this.id = GlobalConstants.createId,
    this.name = const GenericStringInput.pure(),
    this.price = const GoalAmount.pure(),
    this.currencyInput = const GenericStringInput.pure(),
    this.currency,
    this.categoryId,
    this.goalId,
    this.purchasedAt,
    this.createdAt,
    this.isFormPure = true,
    this.hasSubmitError = false,
  });

  bool get isEditing => id != GlobalConstants.createId;

  WishlistFormState copyWith({
    bool? isFormValid,
    GenericStringInput? name,
    GoalAmount? price,
    GenericStringInput? currencyInput,
    Object? currency = _unset,
    Object? categoryId = _unset,
    Object? goalId = _unset,
    bool? isFormPure,
    bool? hasSubmitError,
  }) {
    return WishlistFormState(
      isFormValid: isFormValid ?? this.isFormValid,
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      currencyInput: currencyInput ?? this.currencyInput,
      currency: identical(currency, _unset)
          ? this.currency
          : currency as String?,
      categoryId: identical(categoryId, _unset)
          ? this.categoryId
          : categoryId as String?,
      goalId: identical(goalId, _unset) ? this.goalId : goalId as String?,
      purchasedAt: purchasedAt,
      createdAt: createdAt,
      isFormPure: isFormPure ?? this.isFormPure,
      hasSubmitError: hasSubmitError ?? this.hasSubmitError,
    );
  }
}
