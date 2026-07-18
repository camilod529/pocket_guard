import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/domain/entities/recurring_transaction.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/providers/category/categories_provider.dart';
import 'package:pocket_guard/presentation/providers/recurring_transaction/recurring_transaction_form_provider.dart';
import 'package:pocket_guard/presentation/providers/recurring_transaction/recurring_transactions_provider.dart';
import 'package:pocket_guard/presentation/widgets/recurring_transactions/date_row.dart';
import 'package:pocket_guard/presentation/widgets/recurring_transactions/recurring_amount_field.dart';
import 'package:pocket_guard/presentation/widgets/recurring_transactions/transfer_account_fields.dart';
import 'package:pocket_guard/presentation/widgets/shared/delete_confirmation_modal.dart';
import 'package:pocket_guard/presentation/widgets/shared/forms/account_selector_field.dart';
import 'package:pocket_guard/presentation/widgets/shared/forms/category_selector_field.dart';
import 'package:pocket_guard/presentation/widgets/shared/forms/custom_form_field.dart';
import 'package:pocket_guard/utils/constants/global_constants.dart';
import 'package:pocket_guard/utils/shared/transaction_icons.dart';

class RecurringTransactionFormScreen extends ConsumerWidget {
  final String recurringTransactionId;

  const RecurringTransactionFormScreen({
    super.key,
    required this.recurringTransactionId,
  });

  bool get _isCreating => recurringTransactionId == GlobalConstants.createId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final formStateAsync = ref.watch(
      recurringTransactionFormProvider(recurringTransactionId),
    );
    final accountsAsync = ref.watch(accountsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return formStateAsync.when(
      data: (formState) => Scaffold(
        appBar: AppBar(
          title: Text(
            _isCreating
                ? l10n.newRecurringTransactionTitle
                : l10n.editRecurringTransactionTitle,
          ),
          actions: [
            if (!_isCreating)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _handleDelete(context, ref, formState, l10n),
              ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomFormField(
                  initialValue: formState.name.value,
                  label: l10n.recurringTransactionNameLabel,
                  hintText: l10n.recurringTransactionNameHint,
                  errorText: formState.isFormPure ? null : formState.nameError,
                  prefixIcon: const Icon(Icons.label_outline),
                  onChanged: (value) => ref
                      .read(
                        recurringTransactionFormProvider(
                          recurringTransactionId,
                        ).notifier,
                      )
                      .nameChanged(value),
                ),
                const SizedBox(height: 16),
                RecurringAmountField(
                  formState: formState,
                  accountsAsync: accountsAsync,
                  l10n: l10n,
                  recurringTransactionId: recurringTransactionId,
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return DropdownMenu<TransactionType>(
                      width: constraints.maxWidth,
                      initialSelection: formState.type,
                      label: Text(l10n.transactionTypeLabel),
                      selectOnly: true,
                      leadingIcon: Icon(
                        TransactionIcons.getIconByType(formState.type),
                      ),
                      dropdownMenuEntries: [
                        DropdownMenuEntry(
                          value: TransactionType.expense,
                          label: l10n.expenseType,
                          leadingIcon: Icon(
                            TransactionIcons.getIconByType(
                              TransactionType.expense,
                            ),
                          ),
                        ),
                        DropdownMenuEntry(
                          value: TransactionType.income,
                          label: l10n.incomeType,
                          leadingIcon: Icon(
                            TransactionIcons.getIconByType(
                              TransactionType.income,
                            ),
                          ),
                        ),
                        DropdownMenuEntry(
                          value: TransactionType.transfer,
                          label: l10n.transferType,
                          leadingIcon: Icon(
                            TransactionIcons.getIconByType(
                              TransactionType.transfer,
                            ),
                          ),
                        ),
                      ],
                      onSelected: (type) {
                        if (type == null) return;
                        ref
                            .read(
                              recurringTransactionFormProvider(
                                recurringTransactionId,
                              ).notifier,
                            )
                            .typeChanged(type);
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                if (formState.type == TransactionType.transfer)
                  TransferAccountFields(
                    formState: formState,
                    accountsAsync: accountsAsync,
                    l10n: l10n,
                    recurringTransactionId: recurringTransactionId,
                  )
                else
                  Column(
                    children: [
                      AccountSelectorField(
                        accountsAsync: accountsAsync,
                        l10n: l10n,
                        accountId: formState.accountId,
                        isFormPure: formState.isFormPure,
                        labelOverride: l10n.accountLabel(''),
                        onChanged: (value) => ref
                            .read(
                              recurringTransactionFormProvider(
                                recurringTransactionId,
                              ).notifier,
                            )
                            .accountChanged(value),
                      ),
                      const SizedBox(height: 16),
                      CategorySelectorField(
                        categoriesAsync: categoriesAsync,
                        l10n: l10n,
                        prefixIcon: TransactionIcons.getIconByType(
                          formState.type,
                        ),
                        type: formState.type,
                        categoryId: formState.categoryId,
                        isFormPure: formState.isFormPure,
                        onChanged: (value) => ref
                            .read(
                              recurringTransactionFormProvider(
                                recurringTransactionId,
                              ).notifier,
                            )
                            .categoryChanged(value),
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return DropdownMenu<RecurrenceFrequency>(
                      width: constraints.maxWidth,
                      initialSelection: formState.frequency,
                      label: Text(l10n.frequencyLabel),
                      selectOnly: true,
                      dropdownMenuEntries: [
                        DropdownMenuEntry(
                          value: RecurrenceFrequency.daily,
                          label: l10n.frequencyDaily,
                        ),
                        DropdownMenuEntry(
                          value: RecurrenceFrequency.weekly,
                          label: l10n.frequencyWeekly,
                        ),
                        DropdownMenuEntry(
                          value: RecurrenceFrequency.monthly,
                          label: l10n.frequencyMonthly,
                        ),
                        DropdownMenuEntry(
                          value: RecurrenceFrequency.yearly,
                          label: l10n.frequencyYearly,
                        ),
                      ],
                      onSelected: (frequency) {
                        if (frequency == null) return;
                        ref
                            .read(
                              recurringTransactionFormProvider(
                                recurringTransactionId,
                              ).notifier,
                            )
                            .frequencyChanged(frequency);
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
                DateRow(
                  label: l10n.startDateLabel,
                  date: formState.startDate,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: formState.startDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      ref
                          .read(
                            recurringTransactionFormProvider(
                              recurringTransactionId,
                            ).notifier,
                          )
                          .startDateChanged(picked);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DateRow(
                  label: l10n.endDateLabel,
                  date: formState.endDate,
                  noneLabel: l10n.noEndDateLabel,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: formState.endDate ?? formState.startDate,
                      firstDate: formState.startDate,
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      ref
                          .read(
                            recurringTransactionFormProvider(
                              recurringTransactionId,
                            ).notifier,
                          )
                          .endDateChanged(picked);
                    }
                  },
                  onClear: formState.endDate != null
                      ? () => ref
                            .read(
                              recurringTransactionFormProvider(
                                recurringTransactionId,
                              ).notifier,
                            )
                            .endDateChanged(null)
                      : null,
                ),
                if (!_isCreating) ...[
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.activeLabel),
                    value: formState.isActive,
                    onChanged: (value) => ref
                        .read(
                          recurringTransactionFormProvider(
                            recurringTransactionId,
                          ).notifier,
                        )
                        .isActiveChanged(value),
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: formState.isFormValid
                      ? () => _handleSubmit(context, ref, l10n)
                      : null,
                  icon: const Icon(Icons.save),
                  label: Text(
                    _isCreating
                        ? l10n.createRecurringTransactionButton
                        : l10n.updateRecurringTransactionButton,
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.recurringTransactions)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: Text(l10n.recurringTransactions)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(l10n.error_unknown_data),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: Text(l10n.goBackAction),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    RecurringTransactionFormState formState,
    AppLocalizations l10n,
  ) async {
    await DeleteConfirmationModal.show(
      context: context,
      title: l10n.deleteRecurringTransactionTitle,
      entity: formState.name.value.isEmpty
          ? l10n.thisRecurringTransaction
          : formState.name.value,
      description: l10n.deleteRecurringTransactionDescription,
      onConfirm: () async {
        try {
          await ref
              .read(recurringTransactionsProvider.notifier)
              .deleteRecurringTransaction(recurringTransactionId);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.recurringTransactionDeletedSuccess),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            context.pop();
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.error_db_operation_failed),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
    );
  }

  Future<void> _handleSubmit(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final success = await ref
        .read(recurringTransactionFormProvider(recurringTransactionId).notifier)
        .onFormSubmit();

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isCreating
                ? l10n.createRecurringTransactionButton
                : l10n.updateRecurringTransactionButton,
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.error_db_operation_failed),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
