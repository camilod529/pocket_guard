import 'package:formz/formz.dart';
import 'package:money_manager_flutter/domain/entities/account.dart';
import 'package:money_manager_flutter/infrastructure/inputs/accounts/balance.dart';
import 'package:money_manager_flutter/infrastructure/inputs/accounts/currency.dart';
import 'package:money_manager_flutter/infrastructure/inputs/accounts/name.dart';
import 'package:money_manager_flutter/presentation/providers/account/account_provider.dart';
import 'package:money_manager_flutter/presentation/providers/account/accounts_provider.dart';
import 'package:money_manager_flutter/utils/constants/global_constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_form_provider.g.dart';

@riverpod
class AccountForm extends _$AccountForm {
  void balanceChanged(double value) {
    final currentState = state.value;
    if (currentState == null) return;

    final balance = AccountBalanceInput.dirty(value);
    state = AsyncValue.data(
      currentState.copyWith(
        balance: balance,
        isFormValid: Formz.validate([
          currentState.name,
          currentState.currency,
          balance,
        ]),
      ),
    );
  }

  @override
  Future<AccountFormState> build(String accountId) async {
    // Load account data if editing
    if (accountId != GlobalConstants.createId) {
      final account = await ref.watch(accountProvider(accountId).future);

      if (account != null) {
        return AccountFormState(
          id: account.id,
          name: AccountName.dirty(account.name),
          currency: AccountCurrency.dirty(account.currency),
          balance: AccountBalanceInput.dirty(account.balance),
          isFormValid: true,
        );
      }
    }

    // Return empty state for create mode
    return const AccountFormState(id: GlobalConstants.createId);
  }

  void currencyChanged(String value) {
    final currentState = state.value;
    if (currentState == null) return;

    final currency = AccountCurrency.dirty(value.toUpperCase());
    state = AsyncValue.data(
      currentState.copyWith(
        currency: currency,
        isFormValid: Formz.validate([
          currentState.name,
          currency,
          currentState.balance,
        ]),
      ),
    );
  }

  void nameChanged(String value) {
    final currentState = state.value;
    if (currentState == null) return;

    final name = AccountName.dirty(value);
    state = AsyncValue.data(
      currentState.copyWith(
        name: name,
        isFormValid: Formz.validate([
          name,
          currentState.currency,
          currentState.balance,
        ]),
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
      final account = AccountEntity(
        id: validState.id,
        name: validState.name.value,
        currency: validState.currency.value,
        balance: validState.balance.value,
      );

      final isEditing = validState.id != GlobalConstants.createId;

      if (isEditing) {
        await ref
            .read(accountsProvider.notifier)
            .updateAccount(validState.id, account);

        await ref
            .read(accountProvider(validState.id).notifier)
            .refreshAccount();
      } else {
        await ref.read(accountsProvider.notifier).createAccount(account);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  void _touchAllFields() {
    final currentState = state.value;
    if (currentState == null) return;

    final name = AccountName.dirty(currentState.name.value);
    final currency = AccountCurrency.dirty(currentState.currency.value);
    final balance = AccountBalanceInput.dirty(currentState.balance.value);

    state = AsyncValue.data(
      currentState.copyWith(
        name: name,
        currency: currency,
        balance: balance,
        isFormPure: false,
        isFormValid: Formz.validate([name, currency, balance]),
      ),
    );
  }
}

class AccountFormState {
  final bool isFormValid;
  final String id;
  final AccountName name;
  final AccountCurrency currency;
  final AccountBalanceInput balance;
  final bool isFormPure;

  const AccountFormState({
    this.isFormValid = false,
    this.isFormPure = true,
    this.balance = const AccountBalanceInput.pure(),
    this.id = GlobalConstants.createId,
    this.name = const AccountName.pure(),
    this.currency = const AccountCurrency.pure(),
  });

  AccountFormState copyWith({
    bool? isFormValid,
    String? id,
    AccountName? name,
    AccountCurrency? currency,
    bool? isFormPure,
    AccountBalanceInput? balance,
  }) {
    return AccountFormState(
      isFormValid: isFormValid ?? this.isFormValid,
      id: id ?? this.id,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      isFormPure: isFormPure ?? this.isFormPure,
      balance: balance ?? this.balance,
    );
  }
}
