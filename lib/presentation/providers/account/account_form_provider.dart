import 'package:formz/formz.dart';
import 'package:money_manager_flutter/domain/entities/account.dart';
import 'package:money_manager_flutter/infrastructure/inputs/accounts/currency.dart';
import 'package:money_manager_flutter/infrastructure/inputs/accounts/name.dart';
import 'package:money_manager_flutter/presentation/providers/account/account_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_form_provider.g.dart';

@riverpod
class AccountFormNotifier extends _$AccountFormNotifier {
  @override
  AccountFormState build() {
    return const AccountFormState();
  }

  void currencyChanged(String value) {
    final currency = AccountCurrency.dirty(value.toUpperCase());
    state = state.copyWith(
      currency: currency,
      isValid: Formz.validate([state.name, currency]),
    );
  }

  void nameChanged(String value) {
    final name = AccountName.dirty(value);
    state = state.copyWith(
      name: name,
      isValid: Formz.validate([name, state.currency]),
    );
  }

  void setEditing(String accountId) {
    state = state.copyWith(accountId: accountId, isEditing: true);
  }

  Future<void> submit() async {
    if (!state.isValid || state.isSubmitting) return;

    _touchAllFields();
    if (!state.isValid) return;

    state = state.copyWith(isSubmitting: true);

    try {
      final account = AccountEntity(
        id: state.accountId,
        name: state.name.value,
        currency: state.currency.value,
      );

      final isEditing = state.accountId != 'create';

      if (isEditing && state.accountId != 'create') {
        await ref
            .read(accountProvider.notifier)
            .updateAccount(state.accountId, account);
      } else {
        await ref.read(accountProvider.notifier).createAccount(account);
      }
      await ref.read(accountProvider.notifier).refresh();
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  void _touchAllFields() {
    final name = AccountName.dirty(state.name.value);
    final currency = AccountCurrency.dirty(state.currency.value);
    state = state.copyWith(
      hasSubmitted: true,
      name: name,
      currency: currency,
      isValid: Formz.validate([name, currency]),
    );
  }
}

class AccountFormState {
  final bool hasSubmitted;
  final bool isSubmitting;
  final bool isLoading;
  final bool isEditing;
  final bool isValid;
  final String accountId;
  final AccountName name;
  final AccountCurrency currency;

  const AccountFormState({
    this.hasSubmitted = false,
    this.isSubmitting = false,
    this.isLoading = false,
    this.isEditing = false,
    this.isValid = false,
    this.accountId = 'create',
    this.name = const AccountName.pure(),
    this.currency = const AccountCurrency.pure(),
  });

  AccountFormState copyWith({
    bool? hasSubmitted,
    bool? isSubmitting,
    bool? isLoading,
    bool? isEditing,
    bool? isValid,
    String? accountId,
    AccountName? name,
    AccountCurrency? currency,
  }) {
    return AccountFormState(
      hasSubmitted: hasSubmitted ?? this.hasSubmitted,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isLoading: isLoading ?? this.isLoading,
      isEditing: isEditing ?? this.isEditing,
      isValid: isValid ?? this.isValid,
      accountId: accountId ?? this.accountId,
      name: name ?? this.name,
      currency: currency ?? this.currency,
    );
  }
}
