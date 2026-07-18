import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_guard/domain/entities/account.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/providers/transaction/transaction_form_provider.dart';
import 'package:pocket_guard/presentation/widgets/shared/forms/custom_form_field.dart';
import 'package:pocket_guard/utils/shared/find_account_by_id.dart';
import 'package:pocket_guard/utils/shared/number_formatting.dart';

class AmountField extends ConsumerWidget {
  final TransactionFormState formState;
  final AsyncValue<List<AccountEntity>> accountsAsync;
  final AppLocalizations l10n;
  final String transactionId;
  final DateTime? selectedDate;

  const AmountField({
    super.key,
    required this.formState,
    required this.accountsAsync,
    required this.l10n,
    required this.transactionId,
    this.selectedDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return accountsAsync.when(
      data: (accounts) => _buildAmountFieldWithCurrency(context, ref, accounts),
      loading: () => _buildLoadingField(),
      error: (error, stack) => _buildErrorField(error),
    );
  }

  Widget _buildAmountFieldWithCurrency(
    BuildContext context,
    WidgetRef ref,
    List<AccountEntity> accounts,
  ) {
    final currency =
        findAccountById(accounts, formState.accountId)?.currency ?? 'USD';

    return Row(
      children: [
        Expanded(
          child: CustomFormField(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            initialValue: NumberFormatting.formatNumber(formState.amount.value),
            label: l10n.amountLabel,
            hintText: l10n.amountHint,
            errorText: formState.isFormPure
                ? null
                : (formState.amountError ?? formState.overdraftError),
            prefixIcon: const Icon(Icons.attach_money),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            onChanged: (value) => _handleAmountChange(ref, value, currency),
          ),
        ),
        _buildCurrencyBadge(context, currency),
      ],
    );
  }

  Widget _buildCurrencyBadge(BuildContext context, String currency) {
    return Container(
      width: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Center(
        child: Text(
          currency.isEmpty ? 'USD' : currency,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildErrorField(Object error) {
    return CustomFormField(
      label: l10n.amountLabel,
      hintText: l10n.amountHint,
      prefixIcon: const Icon(Icons.attach_money),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      readOnly: true,
      errorText: l10n.errorLoadingAccounts(error.toString()),
    );
  }

  Widget _buildLoadingField() {
    return CustomFormField(
      label: l10n.amountLabel,
      hintText: l10n.amountHint,
      prefixIcon: const Icon(Icons.attach_money),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      readOnly: true,
    );
  }

  void _handleAmountChange(WidgetRef ref, String value, String currency) {
    final parsedValue = NumberFormatting.parseUserInput(value, currency);
    if (parsedValue != null || value.isEmpty) {
      ref
          .read(
            transactionFormProvider(
              transactionId,
              selectedDate: selectedDate,
            ).notifier,
          )
          .amountChanged(parsedValue ?? formState.amount.value);
    }
  }
}
