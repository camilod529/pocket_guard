import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_guard/domain/entities/account.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/providers/recurring_transaction/recurring_transaction_form_provider.dart';
import 'package:pocket_guard/presentation/widgets/shared/forms/account_selector_field.dart';
import 'package:pocket_guard/utils/shared/find_account_by_id.dart';

class TransferAccountFields extends ConsumerWidget {
  final RecurringTransactionFormState formState;
  final AsyncValue<List<AccountEntity>> accountsAsync;
  final AppLocalizations l10n;
  final String recurringTransactionId;

  const TransferAccountFields({
    super.key,
    required this.formState,
    required this.accountsAsync,
    required this.l10n,
    required this.recurringTransactionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fromAccount = findAccountById(
      accountsAsync.value,
      formState.accountId,
    );
    final toAccount = findAccountById(
      accountsAsync.value,
      formState.toAccountId,
    );

    final notifier = ref.read(
      recurringTransactionFormProvider(recurringTransactionId).notifier,
    );

    return Column(
      children: [
        AccountSelectorField(
          accountsAsync: accountsAsync,
          l10n: l10n,
          accountId: formState.accountId,
          isFormPure: formState.isFormPure,
          labelOverride: l10n.fromAccountLabel,
          targetCurrency: toAccount?.currency,
          onChanged: notifier.accountChanged,
        ),
        const SizedBox(height: 16),
        AccountSelectorField(
          accountsAsync: accountsAsync,
          l10n: l10n,
          accountId: formState.toAccountId,
          isFormPure: formState.isFormPure,
          labelOverride: l10n.toAccountLabel,
          targetCurrency: fromAccount?.currency,
          onChanged: notifier.toAccountChanged,
        ),
        // Unconditional, not gated on isFormPure: this is a direct
        // consequence of the two selections just made, not an "empty
        // field" warning that should wait for a submit attempt (see the
        // transaction form's same-bug fix earlier this session - a
        // disabled Save button can never trigger a submit attempt).
        if (formState.accountId != null &&
            formState.accountId == formState.toAccountId)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 8),
            child: Text(
              l10n.sameTransferAccountError,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
