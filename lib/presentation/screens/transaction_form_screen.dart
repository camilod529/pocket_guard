import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_manager_flutter/domain/entities/account.dart';
import 'package:money_manager_flutter/domain/entities/category.dart';
import 'package:money_manager_flutter/l10n/app_localizations.dart';
import 'package:money_manager_flutter/presentation/providers/account/accounts_provider.dart';
import 'package:money_manager_flutter/presentation/providers/category/categories_provider.dart';
import 'package:money_manager_flutter/presentation/providers/transaction/transaction_form_provider.dart';
import 'package:money_manager_flutter/presentation/providers/transaction/transactions_provider.dart';
import 'package:money_manager_flutter/presentation/widgets/shared/delete_confirmation_modal.dart';
import 'package:money_manager_flutter/presentation/widgets/shared/forms/custom_form_field.dart';
import 'package:money_manager_flutter/utils/constants/global_constants.dart';
import 'package:money_manager_flutter/utils/shared/dates/calendar_date_formatter.dart';
import 'package:money_manager_flutter/utils/shared/number_formatting.dart';

class TransactionFormScreen extends ConsumerStatefulWidget {
  final String transactionId;
  final DateTime? selectedDate;

  const TransactionFormScreen({
    super.key,
    required this.transactionId,
    this.selectedDate,
  });

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _AccountSelector extends ConsumerWidget {
  final TransactionFormState formState;
  final AsyncValue<List<AccountEntity>> accountsAsync;
  final AppLocalizations l10n;
  final String transactionId;
  final DateTime? selectedDate;

  const _AccountSelector({
    required this.formState,
    required this.accountsAsync,
    required this.l10n,
    required this.transactionId,
    this.selectedDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return accountsAsync.when(
      data: (accounts) => IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.accountLabel(''),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 72,
              child: DropdownButtonFormField<String>(
                initialValue: formState.accountId,
                decoration: InputDecoration(
                  hintText: l10n.selectAccountHint,
                  prefixIcon: const Icon(Icons.account_balance_wallet),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                ),
                isExpanded: true,
                items: accounts
                    .map(
                      (account) => DropdownMenuItem(
                        value: account.id,
                        child: Text('${account.name} (${account.currency})'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => value != null
                    ? ref
                          .read(
                            transactionFormProvider(
                              transactionId,
                              selectedDate: selectedDate,
                            ).notifier,
                          )
                          .accountChanged(value)
                    : null,
              ),
            ),
            if (formState.accountId == null && !formState.isFormPure)
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
      ),
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.accountLabel(''), style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          const LinearProgressIndicator(),
        ],
      ),
      error: (error, stack) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.accountLabel(''), style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text(l10n.errorLoadingAccounts(error.toString())),
        ],
      ),
    );
  }
}

class _AmountField extends ConsumerWidget {
  final TransactionFormState formState;
  final AsyncValue<List<AccountEntity>> accountsAsync;
  final AppLocalizations l10n;
  final String transactionId;
  final DateTime? selectedDate;

  const _AmountField({
    required this.formState,
    required this.accountsAsync,
    required this.l10n,
    required this.transactionId,
    this.selectedDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return accountsAsync.when(
      data: (accounts) {
        final currency = formState.accountId == null
            ? 'USD'
            : accounts
                  .firstWhere((acc) => acc.id == formState.accountId)
                  .currency;
        return Row(
          children: [
            Expanded(
              child: CustomFormField(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                initialValue: NumberFormatting.formatNumber(
                  formState.amount.value,
                ),
                label: l10n.amountLabel,
                hintText: l10n.amountHint,
                errorText: formState.isFormPure ? null : formState.amountError,
                prefixIcon: const Icon(Icons.attach_money),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                onChanged: (value) {
                  final parsedValue = NumberFormatting.parseUserInput(
                    value,
                    currency,
                  );

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
                },
              ),
            ),
            Container(
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => CustomFormField(
        label: l10n.amountLabel,
        hintText: l10n.amountHint,
        prefixIcon: const Icon(Icons.attach_money),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        readOnly: true,
      ),
      error: (error, stack) => CustomFormField(
        label: l10n.amountLabel,
        hintText: l10n.amountHint,
        prefixIcon: const Icon(Icons.attach_money),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        readOnly: true,
        errorText: l10n.errorLoadingAccounts(error.toString()),
      ),
    );
  }
}

class _CategorySelector extends ConsumerWidget {
  final TransactionFormState formState;
  final AsyncValue<List<CategoryEntity>> categoriesAsync;
  final AppLocalizations l10n;
  final IconData prefixIcon;
  final String transactionId;
  final DateTime? selectedDate;

  const _CategorySelector({
    required this.formState,
    required this.categoriesAsync,
    required this.l10n,
    required this.prefixIcon,
    required this.transactionId,
    this.selectedDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return categoriesAsync.when(
      data: (categories) {
        final filteredCategories = categories
            .where((cat) => cat.type == formState.type)
            .toList();
        final validCategoryId =
            filteredCategories.any((cat) => cat.id == formState.categoryId)
            ? formState.categoryId
            : null;

        return IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.categoryLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 72,
                child: DropdownButtonFormField<String>(
                  key: ValueKey(filteredCategories.map((c) => c.id).join(',')),
                  initialValue: validCategoryId,
                  decoration: InputDecoration(
                    hintText: l10n.selectCategoryHint,
                    prefixIcon: Icon(prefixIcon),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                  ),
                  isExpanded: true,
                  items: filteredCategories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category.id,
                          child: Text(category.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => value != null
                      ? ref
                            .read(
                              transactionFormProvider(
                                transactionId,
                                selectedDate: selectedDate,
                              ).notifier,
                            )
                            .categoryChanged(value)
                      : null,
                ),
              ),
              if (formState.categoryId == null && !formState.isFormPure)
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
      },
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.categoryLabel, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          const LinearProgressIndicator(),
        ],
      ),
      error: (error, stack) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.categoryLabel, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text(l10n.errorLoadingCategories(error.toString())),
        ],
      ),
    );
  }
}

class _DateTimeFields extends StatelessWidget {
  final AppLocalizations l10n;
  final TextEditingController dateController;
  final VoidCallback selectDate;
  final TextEditingController timeController;
  final VoidCallback selectTime;

  const _DateTimeFields({
    required this.l10n,
    required this.dateController,
    required this.selectDate,
    required this.timeController,
    required this.selectTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: selectDate,
          child: AbsorbPointer(
            child: SizedBox(
              height: 72,
              child: CustomFormField(
                controller: dateController,
                label: l10n.dateLabel,
                hintText: l10n.selectDateHint,
                prefixIcon: const Icon(Icons.calendar_today),
                readOnly: true,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: selectTime,
          child: AbsorbPointer(
            child: SizedBox(
              height: 72,
              child: CustomFormField(
                controller: timeController,
                label: l10n.timeLabel,
                hintText: l10n.selectTimeHint,
                prefixIcon: const Icon(Icons.access_time),
                readOnly: true,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DescriptionField extends ConsumerWidget {
  final TransactionFormState formState;
  final AppLocalizations l10n;
  final String transactionId;
  final DateTime? selectedDate;

  const _DescriptionField({
    required this.formState,
    required this.l10n,
    required this.transactionId,
    this.selectedDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomFormField(
      initialValue: formState.description.value,
      label: l10n.descriptionLabel,
      hintText: l10n.descriptionHint,
      errorText: formState.isFormPure ? null : formState.descriptionError,
      prefixIcon: const Icon(Icons.notes_outlined),
      keyboardType: TextInputType.text,
      maxLines: 2,
      onChanged: (value) => ref
          .read(
            transactionFormProvider(
              transactionId,
              selectedDate: selectedDate,
            ).notifier,
          )
          .descriptionChanged(value),
    );
  }
}

class _IncomeExpenseForm extends ConsumerWidget {
  final TransactionFormState formState;
  final AsyncValue<List<AccountEntity>> accountsAsync;
  final AppLocalizations l10n;
  final AsyncValue<List<CategoryEntity>> categoriesAsync;
  final CalendarDateFormatter formatter;
  final String transactionId;
  final DateTime? selectedDate;
  final TextEditingController dateController;
  final VoidCallback selectDate;
  final TextEditingController timeController;
  final VoidCallback selectTime;
  final IconData categorySelectorPrefixIcon;

  const _IncomeExpenseForm({
    required this.formState,
    required this.accountsAsync,
    required this.l10n,
    required this.categoriesAsync,
    required this.formatter,
    required this.transactionId,
    required this.dateController,
    this.selectedDate,
    required this.selectDate,
    required this.timeController,
    required this.selectTime,
    required this.categorySelectorPrefixIcon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _AccountSelector(
          formState: formState,
          accountsAsync: accountsAsync,
          l10n: l10n,
          transactionId: formState.id,
          selectedDate: selectedDate,
        ),
        const SizedBox(height: 16),
        _AmountField(
          formState: formState,
          l10n: l10n,
          accountsAsync: accountsAsync,
          transactionId: transactionId,
          selectedDate: selectedDate,
        ),
        const SizedBox(height: 16),
        _DescriptionField(
          formState: formState,
          l10n: l10n,
          transactionId: transactionId,
          selectedDate: selectedDate,
        ),
        const SizedBox(height: 24),
        _CategorySelector(
          formState: formState,
          categoriesAsync: categoriesAsync,
          l10n: l10n,
          prefixIcon: categorySelectorPrefixIcon,
          transactionId: transactionId,
          selectedDate: selectedDate,
        ),
        const SizedBox(height: 16),
        _DateTimeFields(
          l10n: l10n,
          dateController: dateController,
          selectDate: selectDate,
          timeController: timeController,
          selectTime: selectTime,
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isCreating = widget.transactionId == GlobalConstants.createId;

    final formStateAsync = ref.watch(
      transactionFormProvider(
        widget.transactionId,
        selectedDate: widget.selectedDate,
      ),
    );
    final categoriesAsync = ref.watch(categoriesProvider);
    final accountsAsync = ref.watch(accountsProvider);

    return formStateAsync.when(
      data: (formState) {
        final formatter = _getDateFormatter();

        _dateController.text = formatter.formatFullDate(formState.date);
        _timeController.text = formatter.formatTime(formState.date);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              isCreating ? l10n.newTransactionTitle : l10n.editTransactionTitle,
            ),
            actions: [
              if (!isCreating)
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: l10n.deleteAction,
                  onPressed: () => _handleDelete(context, formState, l10n),
                ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: MediaQuery.of(
                context,
              ).padding.copyWith(top: 0, bottom: 20),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTransactionTypeSelector(formState, l10n),
                    const SizedBox(height: 16),
                    if (formState.type != TransactionType.transfer)
                      _IncomeExpenseForm(
                        formState: formState,
                        accountsAsync: accountsAsync,
                        l10n: l10n,
                        categoriesAsync: categoriesAsync,
                        formatter: formatter,
                        transactionId: formState.id,
                        selectedDate: widget.selectedDate,
                        dateController: _dateController,
                        selectDate: () => _selectDate(context, formState.date),
                        timeController: _timeController,
                        selectTime: () => _selectTime(context, formState.date),
                        categorySelectorPrefixIcon: _getCategoryIconByType(
                          formState.type,
                        ),
                      ),
                    if (formState.type == TransactionType.transfer)
                      _TransferForm(),
                    // Submit Button
                    ElevatedButton.icon(
                      onPressed:
                          (isCreating
                              ? (formState.isFormPure || formState.isFormValid)
                              : (formState.hasFormBeenModified &&
                                    formState.isFormValid))
                          ? () => _handleSubmit(context, ref)
                          : null,
                      icon: const Icon(Icons.save),
                      label: Text(
                        isCreating
                            ? l10n.createTransactionButton
                            : l10n.updateTransactionButton,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: Text(l10n.transactionTitle)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(l10n.errorLoadingTransaction(error.toString())),
              ),
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

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Widget _buildTransactionTypeSelector(
    TransactionFormState formState,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.transactionTypeLabel,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),

        SegmentedButton<TransactionType>(
          showSelectedIcon: false,
          style: ButtonStyle(
            textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 13)),
          ),
          segments: [
            ButtonSegment(
              value: TransactionType.expense,
              label: SizedBox(
                width: 70,
                child: Text(
                  l10n.expenseType,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              icon: Icon(_getCategoryIconByType(TransactionType.expense)),
            ),
            ButtonSegment(
              value: TransactionType.income,
              label: SizedBox(
                width: 70,
                child: Text(
                  l10n.incomeType,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              icon: Icon(_getCategoryIconByType(TransactionType.income)),
            ),
            ButtonSegment(
              value: TransactionType.transfer,
              label: SizedBox(
                width: 70,
                child: Text(
                  l10n.transferType,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              icon: Icon(_getCategoryIconByType(TransactionType.transfer)),
            ),
          ],
          selected: {formState.type},
          onSelectionChanged: (Set<TransactionType> newSelection) {
            ref
                .read(
                  transactionFormProvider(
                    widget.transactionId,
                    selectedDate: widget.selectedDate,
                  ).notifier,
                )
                .typeChanged(newSelection.first);
          },
        ),
      ],
    );
  }

  IconData _getCategoryIconByType(TransactionType type) {
    switch (type) {
      case TransactionType.expense:
        return Icons.arrow_upward;
      case TransactionType.income:
        return Icons.arrow_downward;
      case TransactionType.transfer:
        return Icons.swap_horiz;
    }
  }

  CalendarDateFormatter _getDateFormatter() {
    return CalendarDateFormatter(Localizations.localeOf(context));
  }

  Future<void> _handleDelete(
    BuildContext context,
    TransactionFormState formState,
    AppLocalizations l10n,
  ) async {
    await DeleteConfirmationModal.show(
      context: context,
      title: l10n.deleteTransactionTitle,
      entity: formState.description.value.isEmpty
          ? l10n.thisTransaction
          : formState.description.value,
      description: l10n.deleteTransactionDescription,
      onConfirm: () async {
        try {
          await ref
              .read(transactionsProvider.notifier)
              .deleteTransaction(widget.transactionId);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.transactionDeletedSuccess),
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
                content: Text(l10n.transactionDeleteError(e.toString())),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
    );
  }

  Future<void> _handleSubmit(BuildContext context, WidgetRef ref) async {
    final success = await ref
        .read(
          transactionFormProvider(
            widget.transactionId,
            selectedDate: widget.selectedDate,
          ).notifier,
        )
        .onFormSubmit();

    if (success && context.mounted) {
      final l10n = AppLocalizations.of(context)!;
      final message = widget.transactionId == GlobalConstants.createId
          ? l10n.transactionCreatedSuccess
          : l10n.transactionUpdatedSuccess;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      context.pop();
    } else if (context.mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.transactionSaveError),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, DateTime currentDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && mounted) {
      final newDateTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        currentDate.hour,
        currentDate.minute,
      );
      ref
          .read(
            transactionFormProvider(
              widget.transactionId,
              selectedDate: widget.selectedDate,
            ).notifier,
          )
          .dateChanged(newDateTime);
    }
  }

  Future<void> _selectTime(BuildContext context, DateTime currentDate) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentDate),
    );
    if (picked != null && mounted) {
      final newDateTime = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        picked.hour,
        picked.minute,
      );
      ref
          .read(
            transactionFormProvider(
              widget.transactionId,
              selectedDate: widget.selectedDate,
            ).notifier,
          )
          .dateChanged(newDateTime);
    }
  }
}

class _TransferForm extends StatelessWidget {
  const _TransferForm();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
