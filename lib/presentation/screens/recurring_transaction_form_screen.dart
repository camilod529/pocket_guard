import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_guard/domain/entities/account.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/domain/entities/recurring_transaction.dart';
import 'package:pocket_guard/infrastructure/inputs/formatters/currency_input_formatter.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/providers/category/categories_provider.dart';
import 'package:pocket_guard/presentation/providers/recurring_transaction/recurring_transaction_form_provider.dart';
import 'package:pocket_guard/presentation/providers/recurring_transaction/recurring_transactions_provider.dart';
import 'package:pocket_guard/presentation/screens/transaction_form_screen.dart' show TransactionIcons;
import 'package:pocket_guard/presentation/widgets/shared/delete_confirmation_modal.dart';
import 'package:pocket_guard/presentation/widgets/shared/forms/common_drop_down.dart';
import 'package:pocket_guard/presentation/widgets/shared/forms/custom_form_field.dart';
import 'package:pocket_guard/utils/constants/global_constants.dart';
import 'package:pocket_guard/utils/shared/dates/calendar_date_formatter.dart';
import 'package:pocket_guard/utils/shared/find_account_by_id.dart';
import 'package:pocket_guard/utils/shared/number_formatting.dart';

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
                _AmountField(
                  formState: formState,
                  accountsAsync: accountsAsync,
                  l10n: l10n,
                  recurringTransactionId: recurringTransactionId,
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.transactionTypeLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                SegmentedButton<TransactionType>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text(l10n.expenseType),
                      icon: Icon(
                        TransactionIcons.getIconByType(
                          TransactionType.expense,
                        ),
                      ),
                    ),
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text(l10n.incomeType),
                      icon: Icon(
                        TransactionIcons.getIconByType(TransactionType.income),
                      ),
                    ),
                    ButtonSegment(
                      value: TransactionType.transfer,
                      label: Text(l10n.transferType),
                      icon: Icon(
                        TransactionIcons.getIconByType(
                          TransactionType.transfer,
                        ),
                      ),
                    ),
                  ],
                  selected: {formState.type},
                  onSelectionChanged: (selection) => ref
                      .read(
                        recurringTransactionFormProvider(
                          recurringTransactionId,
                        ).notifier,
                      )
                      .typeChanged(selection.first),
                ),
                const SizedBox(height: 16),
                if (formState.type == TransactionType.transfer)
                  _TransferAccountFields(
                    formState: formState,
                    accountsAsync: accountsAsync,
                    l10n: l10n,
                    recurringTransactionId: recurringTransactionId,
                  )
                else
                  Column(
                    children: [
                      _AccountSelector(
                        formState: formState,
                        accountsAsync: accountsAsync,
                        l10n: l10n,
                        accountId: formState.accountId,
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
                      _CategorySelector(
                        formState: formState,
                        categoriesAsync: categoriesAsync,
                        l10n: l10n,
                        recurringTransactionId: recurringTransactionId,
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
                Text(
                  l10n.frequencyLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                SegmentedButton<RecurrenceFrequency>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: RecurrenceFrequency.daily,
                      label: Text(l10n.frequencyDaily),
                    ),
                    ButtonSegment(
                      value: RecurrenceFrequency.weekly,
                      label: Text(l10n.frequencyWeekly),
                    ),
                    ButtonSegment(
                      value: RecurrenceFrequency.monthly,
                      label: Text(l10n.frequencyMonthly),
                    ),
                    ButtonSegment(
                      value: RecurrenceFrequency.yearly,
                      label: Text(l10n.frequencyYearly),
                    ),
                  ],
                  selected: {formState.frequency},
                  onSelectionChanged: (selection) => ref
                      .read(
                        recurringTransactionFormProvider(
                          recurringTransactionId,
                        ).notifier,
                      )
                      .frequencyChanged(selection.first),
                ),
                const SizedBox(height: 24),
                _DateRow(
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
                _DateRow(
                  label: l10n.endDateLabel,
                  date: formState.endDate,
                  noneLabel: l10n.noEndDateLabel,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate:
                          formState.endDate ?? formState.startDate,
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
        .read(
          recurringTransactionFormProvider(recurringTransactionId).notifier,
        )
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

class _AccountSelector extends StatelessWidget {
  final RecurringTransactionFormState formState;
  final AsyncValue<List<AccountEntity>> accountsAsync;
  final AppLocalizations l10n;
  final String? accountId;
  final String? labelOverride;
  final String? targetCurrency;
  final void Function(String) onChanged;

  const _AccountSelector({
    required this.formState,
    required this.accountsAsync,
    required this.l10n,
    required this.accountId,
    required this.onChanged,
    this.labelOverride,
    this.targetCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return accountsAsync.when(
      data: (accounts) => _buildDropdown(context, accounts),
      loading: () => const LinearProgressIndicator(),
      error: (error, stack) => Text(l10n.errorLoadingAccounts(error.toString())),
    );
  }

  Widget _buildDropdown(BuildContext context, List<AccountEntity> accounts) {
    final filtered = accounts
        .where(
          (account) =>
              targetCurrency == null || account.currency == targetCurrency,
        )
        .toList();
    final showError = accountId == null && !formState.isFormPure;

    return IntrinsicHeight(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            labelOverride ?? l10n.accountLabel(''),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 72,
            child: DropdownButtonFormField<String>(
              key: ValueKey(filtered.map((a) => a.id).join(',')),
              initialValue: filtered.any((a) => a.id == accountId)
                  ? accountId
                  : null,
              decoration: DropdownDecorationHelper.getDecoration(
                hintText: l10n.selectAccountHint,
                prefixIcon: const Icon(Icons.account_balance_wallet),
              ),
              isExpanded: true,
              items: filtered
                  .map(
                    (account) => DropdownMenuItem(
                      value: account.id,
                      child: Text('${account.name} (${account.currency})'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) onChanged(value);
              },
            ),
          ),
          if (showError)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 8),
              child: Text(
                l10n.selectAccountError,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TransferAccountFields extends ConsumerWidget {
  final RecurringTransactionFormState formState;
  final AsyncValue<List<AccountEntity>> accountsAsync;
  final AppLocalizations l10n;
  final String recurringTransactionId;

  const _TransferAccountFields({
    required this.formState,
    required this.accountsAsync,
    required this.l10n,
    required this.recurringTransactionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fromAccount = findAccountById(accountsAsync.value, formState.accountId);
    final toAccount = findAccountById(accountsAsync.value, formState.toAccountId);

    final notifier = ref.read(
      recurringTransactionFormProvider(recurringTransactionId).notifier,
    );

    return Column(
      children: [
        _AccountSelector(
          formState: formState,
          accountsAsync: accountsAsync,
          l10n: l10n,
          accountId: formState.accountId,
          labelOverride: l10n.fromAccountLabel,
          targetCurrency: toAccount?.currency,
          onChanged: notifier.accountChanged,
        ),
        const SizedBox(height: 16),
        _AccountSelector(
          formState: formState,
          accountsAsync: accountsAsync,
          l10n: l10n,
          accountId: formState.toAccountId,
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

class _CategorySelector extends StatelessWidget {
  final RecurringTransactionFormState formState;
  final AsyncValue<List<CategoryEntity>> categoriesAsync;
  final AppLocalizations l10n;
  final String recurringTransactionId;

  const _CategorySelector({
    required this.formState,
    required this.categoriesAsync,
    required this.l10n,
    required this.recurringTransactionId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return categoriesAsync.when(
          data: (categories) => _buildDropdown(context, ref, categories),
          loading: () => const LinearProgressIndicator(),
          error: (error, stack) =>
              Text(l10n.errorLoadingCategories(error.toString())),
        );
      },
    );
  }

  Widget _buildDropdown(
    BuildContext context,
    WidgetRef ref,
    List<CategoryEntity> categories,
  ) {
    final filtered = categories
        .where((category) => category.type == formState.type)
        .toList();
    final validCategoryId = filtered.any((c) => c.id == formState.categoryId)
        ? formState.categoryId
        : null;
    final showError = formState.categoryId == null && !formState.isFormPure;

    return IntrinsicHeight(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.categoryLabel,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 72,
            child: DropdownButtonFormField<String>(
              key: ValueKey(filtered.map((c) => c.id).join(',')),
              initialValue: validCategoryId,
              decoration: DropdownDecorationHelper.getDecoration(
                hintText: l10n.selectCategoryHint,
                prefixIcon: Icon(TransactionIcons.getIconByType(formState.type)),
              ),
              isExpanded: true,
              items: filtered
                  .map(
                    (category) => DropdownMenuItem(
                      value: category.id,
                      child: Text(category.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(
                        recurringTransactionFormProvider(
                          recurringTransactionId,
                        ).notifier,
                      )
                      .categoryChanged(value);
                }
              },
            ),
          ),
          if (showError)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 8),
              child: Text(
                l10n.selectCategoryError,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  final RecurringTransactionFormState formState;
  final AsyncValue<List<AccountEntity>> accountsAsync;
  final AppLocalizations l10n;
  final String recurringTransactionId;

  const _AmountField({
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

class _DateRow extends StatelessWidget {
  final String label;
  final DateTime? date;
  final String? noneLabel;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _DateRow({
    required this.label,
    required this.date,
    required this.onTap,
    this.noneLabel,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = CalendarDateFormatter(Localizations.localeOf(context));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    date != null
                        ? formatter.formatFullDate(date!)
                        : (noneLabel ?? ''),
                  ),
                ),
                if (onClear != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: onClear,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
