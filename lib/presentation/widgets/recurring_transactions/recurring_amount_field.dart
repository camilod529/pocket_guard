import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_guard/domain/entities/account.dart';
import 'package:pocket_guard/infrastructure/inputs/formatters/currency_input_formatter.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/providers/recurring_transaction/recurring_transaction_form_provider.dart';
import 'package:pocket_guard/presentation/widgets/shared/forms/custom_form_field.dart';
import 'package:pocket_guard/utils/shared/find_account_by_id.dart';
import 'package:pocket_guard/utils/shared/number_formatting.dart';

/// Recurring transactions' own amount field - kept separate from
/// [lib/presentation/widgets/transactions/amount_field.dart]'s AmountField
/// rather than unified with it, since the two have genuinely diverged:
/// this one shows currency inline in the label instead of a side badge,
/// has no overdraft-check support, and doesn't handle accountsAsync
/// loading/error states.
class RecurringAmountField extends StatelessWidget {
  final RecurringTransactionFormState formState;
  final AsyncValue<List<AccountEntity>> accountsAsync;
  final AppLocalizations l10n;
  final String recurringTransactionId;

  const RecurringAmountField({
    super.key,
    required this.formState,
    required this.accountsAsync,
    required this.l10n,
    required this.recurringTransactionId,
  });

  @override
  Widget build(BuildContext context) {
    final currency =
        findAccountById(accountsAsync.value, formState.accountId)?.currency ??
        'USD';

    return Consumer(
      builder: (context, ref, _) {
        return CustomFormField(
          initialValue: NumberFormatting.formatNumber(formState.amount.value),
          label: '${l10n.amountLabel} ($currency)',
          hintText: l10n.amountHint,
          errorText: formState.isFormPure ? null : formState.amountError,
          prefixIcon: const Icon(Icons.attach_money),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [CurrencyInputFormatter()],
          onChanged: (value) {
            final parsed = NumberFormatting.parseUserInput(value, currency);
            if (parsed != null || value.isEmpty) {
              ref
                  .read(
                    recurringTransactionFormProvider(
                      recurringTransactionId,
                    ).notifier,
                  )
                  .amountChanged(parsed ?? 0);
            }
          },
        );
      },
    );
  }
}
