import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_guard/domain/entities/account.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/providers/transaction/transaction_form_provider.dart';
import 'package:pocket_guard/presentation/widgets/shared/forms/account_selector_field.dart';
import 'package:pocket_guard/presentation/widgets/transactions/amount_field.dart';
import 'package:pocket_guard/presentation/widgets/transactions/date_time_fields.dart';
import 'package:pocket_guard/presentation/widgets/transactions/description_field.dart';
import 'package:pocket_guard/utils/shared/dates/calendar_date_formatter.dart';
import 'package:pocket_guard/utils/shared/find_account_by_id.dart';
import 'package:pocket_guard/utils/shared/number_formatting.dart';

class TransferForm extends ConsumerStatefulWidget {
  final String transactionId;
  final DateTime? selectedDate;
  final TransactionFormState formState;
  final AsyncValue<List<AccountEntity>> accountsAsync;
  final TextEditingController dateController;
  final TextEditingController timeController;
  final VoidCallback selectDate;
  final VoidCallback selectTime;

  const TransferForm({
    super.key,
    this.selectedDate,
    required this.transactionId,
    required this.formState,
    required this.accountsAsync,
    required this.dateController,
    required this.timeController,
    required this.selectDate,
    required this.selectTime,
  });

  @override
  ConsumerState<TransferForm> createState() => _TransferFormState();
}

class _TransferFormState extends ConsumerState<TransferForm> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    _updateControllers(widget.formState);
    return _buildTransferFormContent(
      formState: widget.formState,
      accountsAsync: widget.accountsAsync,
      l10n: l10n,
    );
  }

  Widget _buildTransferFormContent({
    required TransactionFormState formState,
    required AsyncValue<List<AccountEntity>> accountsAsync,
    required AppLocalizations l10n,
  }) {
    final fromAccount = findAccountById(
      accountsAsync.value,
      formState.accountId,
    );
    final toAccount = findAccountById(
      accountsAsync.value,
      formState.toAccountId,
    );

    final fromCurrency = fromAccount?.currency;
    final toCurrency = toAccount?.currency;
    final fromAccountName = fromAccount?.name ?? '';
    final toAccountName = toAccount?.name ?? '';

    return Column(
      children: [
        AccountSelectorField(
          accountsAsync: accountsAsync,
          l10n: l10n,
          isFormPure: formState.isFormPure,
          labelOverride: l10n.fromAccountLabel,
          targetCurrency: toCurrency,
          onChanged: (value) => ref
              .read(
                transactionFormProvider(
                  widget.transactionId,
                  selectedDate: widget.selectedDate,
                ).notifier,
              )
              .accountChanged(value),
          accountId: formState.accountId,
        ),
        const SizedBox(height: 16),
        AccountSelectorField(
          accountsAsync: accountsAsync,
          l10n: l10n,
          isFormPure: formState.isFormPure,
          targetCurrency: fromCurrency,
          labelOverride: l10n.toAccountLabel,
          onChanged: (value) => ref
              .read(
                transactionFormProvider(
                  widget.transactionId,
                  selectedDate: widget.selectedDate,
                ).notifier,
              )
              .toAccountChanged(value),
          accountId: formState.toAccountId,
        ),
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
        const SizedBox(height: 16),
        AmountField(
          formState: formState,
          accountsAsync: accountsAsync,
          l10n: l10n,
          transactionId: widget.transactionId,
          selectedDate: widget.selectedDate,
        ),
        const SizedBox(height: 16),
        DescriptionField(
          formState: formState,
          l10n: l10n,
          transactionId: widget.transactionId,
          selectedDate: widget.selectedDate,
        ),
        const SizedBox(height: 24),
        DateTimeFields(
          l10n: l10n,
          dateController: widget.dateController,
          selectDate: widget.selectDate,
          timeController: widget.timeController,
          selectTime: widget.selectTime,
        ),
        if (formState.accountId != null && formState.toAccountId != null)
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.transferSummary(
                      NumberFormatting.formatNumber(formState.amount.value),
                      fromAccountName,
                      toAccountName,
                    ),
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 32),
      ],
    );
  }

  void _updateControllers(TransactionFormState formState) {
    final formatter = CalendarDateFormatter(Localizations.localeOf(context));
    widget.dateController.text = formatter.formatFullDate(formState.date);
    widget.timeController.text = formatter.formatTime(formState.date);
  }
}
