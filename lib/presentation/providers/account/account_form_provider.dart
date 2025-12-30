import 'package:formz/formz.dart';
import 'package:pocket_guard/domain/entities/account.dart';
import 'package:pocket_guard/infrastructure/inputs/accounts/balance.dart';
import 'package:pocket_guard/infrastructure/inputs/accounts/currency.dart';
import 'package:pocket_guard/infrastructure/inputs/accounts/name.dart';
import 'package:pocket_guard/presentation/providers/account/account_provider.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/utils/constants/global_constants.dart';
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
          type: account.type,
          isFormValid: true,
        );
      }
    }

    // Return empty state for create mode
    return const AccountFormState(
      id: GlobalConstants.createId,
      type: AccountType.asset,
    );
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
    _touchAllFields();

    final currentState = state.value;

    if (currentState == null || !currentState.isFormValid) return false;

    try {
      final isEditing = currentState.id != GlobalConstants.createId;
      int finalSortOrder = 0;

      if (isEditing) {
        // 1. Fetch current data to preserve existing sort order
        final existingAccount = await ref.read(
          accountProvider(currentState.id).future,
        );
        finalSortOrder = existingAccount?.sortOrder ?? 0;
      } else {
        // 2. Calculate next sort order: Count accounts of the SAME type
        final allAccounts = await ref.read(accountsProvider.future);
        finalSortOrder = allAccounts
            .where((a) => a.type == currentState.type)
            .length;
      }

      final account = AccountEntity(
        id: currentState.id,
        name: currentState.name.value,
        currency: currentState.currency.value,
        balance: currentState.balance.value,
        type: currentState.type,
        sortOrder: finalSortOrder,
      );

      if (isEditing) {
        await ref
            .read(accountsProvider.notifier)
            .updateAccount(currentState.id, account);
        await ref
            .read(accountProvider(currentState.id).notifier)
            .refreshAccount();
      } else {
        await ref.read(accountsProvider.notifier).createAccount(account);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  void typeChanged(AccountType value) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(
        type: value,
        isFormValid: Formz.validate([
          currentState.name,
          currentState.currency,
          currentState.balance,
        ]),
      ),
    );
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
  final AccountType type;
  final bool isFormPure;

  const AccountFormState({
    this.isFormValid = false,
    this.isFormPure = true,
    this.balance = const AccountBalanceInput.pure(),
    this.id = GlobalConstants.createId,
    this.name = const AccountName.pure(),
    this.currency = const AccountCurrency.pure(),
    required this.type,
  });

  AccountFormState copyWith({
    bool? isFormValid,
    String? id,
    AccountName? name,
    AccountCurrency? currency,
    bool? isFormPure,
    AccountBalanceInput? balance,
    AccountType? type,
  }) {
    return AccountFormState(
      isFormValid: isFormValid ?? this.isFormValid,
      id: id ?? this.id,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      isFormPure: isFormPure ?? this.isFormPure,
      balance: balance ?? this.balance,
      type: type ?? this.type,
    );
  }
}
