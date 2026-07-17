import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_guard/domain/entities/account.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/mixins/date_time_selection_mixin.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/providers/category/categories_provider.dart';
import 'package:pocket_guard/presentation/providers/transaction/transaction_form_provider.dart';
import 'package:pocket_guard/presentation/providers/transaction/transactions_provider.dart';
import 'package:pocket_guard/presentation/widgets/shared/delete_confirmation_modal.dart';
import 'package:pocket_guard/presentation/widgets/shared/forms/common_drop_down.dart';
import 'package:pocket_guard/presentation/widgets/shared/forms/custom_form_field.dart';
import 'package:pocket_guard/utils/constants/global_constants.dart';
import 'package:pocket_guard/utils/shared/dates/calendar_date_formatter.dart';
import 'package:pocket_guard/utils/shared/find_account_by_id.dart';
import 'package:pocket_guard/utils/shared/number_formatting.dart';

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

/// Helper class for common icons
class TransactionIcons {
  static IconData getIconByType(TransactionType type) {
    switch (type) {
      case TransactionType.expense:
        return Icons.arrow_upward;
      case TransactionType.income:
        return Icons.arrow_downward;
      case TransactionType.transfer:
        return Icons.swap_horiz;
    }
  }
}

class _AccountSelector extends ConsumerWidget {
  final TransactionFormState formState;
  final AsyncValue<List<AccountEntity>> accountsAsync;
  final String? accountId;
  final AppLocalizations l10n;
  final String transactionId;
  final DateTime? selectedDate;
  final String? targetCurrency;
  final String? excludeAccountId;
  final String? labelOverride;
  final void Function(String)? onChanged;

  const _AccountSelector({
    required this.formState,
    required this.accountsAsync,
    required this.l10n,
    required this.transactionId,
    required this.accountId,
    required this.onChanged,
    this.selectedDate,
    this.labelOverride,
    this.excludeAccountId,
    this.targetCurrency,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return accountsAsync.when(
      data: (accounts) => _buildAccountDropdown(context, ref, accounts),
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildAccountDropdown(
    BuildContext context,
    WidgetRef ref,
    List<AccountEntity> accounts,
  ) {
    final showError = accountId == null && !formState.isFormPure;

    final filteredAccounts = accounts.where((account) {
      final excludeMatch = account.id != excludeAccountId;
      final currencyMatch =
          targetCurrency == null || account.currency == targetCurrency;
      return excludeMatch && currencyMatch;
    }).toList();

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
              key: ValueKey(filteredAccounts.map((a) => a.id).join(',')),
              initialValue: filteredAccounts.any((a) => a.id == accountId)
                  ? accountId
                  : null,
              decoration: DropdownDecorationHelper.getDecoration(
                hintText: l10n.selectAccountHint,
                prefixIcon: const Icon(Icons.account_balance_wallet),
              ),
              isExpanded: true,
              items: filteredAccounts
                  .map(
                    (account) => DropdownMenuItem(
                      value: account.id,
                      child: Text('${account.name} (${account.currency})'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  onChanged?.call(value);
                }
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

  Widget _buildErrorState(Object error) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelOverride ?? l10n.accountLabel(''),
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(l10n.errorLoadingAccounts(error.toString())),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelOverride ?? l10n.accountLabel(''),
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        const LinearProgressIndicator(),
      ],
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
      data: (categories) => _buildCategoryDropdown(context, ref, categories),
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildCategoryDropdown(
    BuildContext context,
    WidgetRef ref,
    List<CategoryEntity> categories,
  ) {
    final filteredCategories = categories
        .where((cat) => cat.type == formState.type)
        .toList();
    final validCategoryId =
        filteredCategories.any((cat) => cat.id == formState.categoryId)
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
              key: ValueKey(filteredCategories.map((c) => c.id).join(',')),
              initialValue: validCategoryId,
              decoration: DropdownDecorationHelper.getDecoration(
                hintText: l10n.selectCategoryHint,
                prefixIcon: Icon(prefixIcon),
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
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(
                        transactionFormProvider(
                          transactionId,
                          selectedDate: selectedDate,
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

  Widget _buildErrorState(Object error) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.categoryLabel, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Text(l10n.errorLoadingCategories(error.toString())),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.categoryLabel, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        const LinearProgressIndicator(),
      ],
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
        _buildDateField(),
        const SizedBox(height: 12),
        _buildTimeField(),
      ],
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
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
    );
  }

  Widget _buildTimeField() {
    return GestureDetector(
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
  final String transactionId;
  final DateTime? selectedDate;
  final TextEditingController dateController;
  final VoidCallback selectDate;
  final TextEditingController timeController;
  final VoidCallback selectTime;

  const _IncomeExpenseForm({
    required this.formState,
    required this.accountsAsync,
    required this.l10n,
    required this.categoriesAsync,
    required this.transactionId,
    required this.dateController,
    this.selectedDate,
    required this.selectDate,
    required this.timeController,
    required this.selectTime,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _AccountSelector(
          formState: formState,
          accountsAsync: accountsAsync,
          l10n: l10n,
          transactionId: transactionId,
          selectedDate: selectedDate,
          accountId: formState.accountId,
          onChanged: (value) {
            ref
                .read(
                  transactionFormProvider(
                    transactionId,
                    selectedDate: selectedDate,
                  ).notifier,
                )
                .accountChanged(value);
          },
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
          prefixIcon: TransactionIcons.getIconByType(formState.type),
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

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen>
    with DateTimeSelectionMixin {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  @override
  DateTime? get selectedDate => widget.selectedDate;

  @override
  String get transactionId => widget.transactionId;

  bool get _isCreating => transactionId == GlobalConstants.createId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final formStateAsync = ref.watch(
      transactionFormProvider(transactionId, selectedDate: selectedDate),
    );
    final categoriesAsync = ref.watch(categoriesProvider);
    final accountsAsync = ref.watch(accountsProvider);

    return formStateAsync.when(
      data: (formState) => _buildFormScaffold(
        context,
        formState,
        l10n,
        categoriesAsync,
        accountsAsync,
      ),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => _buildErrorScaffold(context, l10n, error),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  PreferredSizeWidget _buildAppBar(
    AppLocalizations l10n,
    TransactionFormState formState,
  ) {
    return AppBar(
      title: Text(
        _isCreating ? l10n.newTransactionTitle : l10n.editTransactionTitle,
      ),
      actions: [
        if (!_isCreating)
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: l10n.deleteAction,
            onPressed: () => _handleDelete(context, formState, l10n),
          ),
      ],
    );
  }

  Widget _buildErrorScaffold(
    BuildContext context,
    AppLocalizations l10n,
    Object error,
  ) {
    return Scaffold(
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
    );
  }

  Widget _buildFormScaffold(
    BuildContext context,
    TransactionFormState formState,
    AppLocalizations l10n,
    AsyncValue<List<CategoryEntity>> categoriesAsync,
    AsyncValue<List<AccountEntity>> accountsAsync,
  ) {
    _updateControllers(formState);

    return Scaffold(
      appBar: _buildAppBar(l10n, formState),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: MediaQuery.of(context).padding.copyWith(top: 0, bottom: 20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
                    transactionId: transactionId,
                    selectedDate: selectedDate,
                    dateController: _dateController,
                    selectDate: () => selectDate(context, formState.date),
                    timeController: _timeController,
                    selectTime: () => selectTime(context, formState.date),
                  ),
                if (formState.type == TransactionType.transfer)
                  _TransferForm(
                    formState: formState,
                    accountsAsync: accountsAsync,
                    transactionId: transactionId,
                    selectedDate: selectedDate,
                    dateController: _dateController,
                    selectDate: () => selectDate(context, formState.date),
                    timeController: _timeController,
                    selectTime: () => selectTime(context, formState.date),
                  ),
                _buildSubmitButton(formState, l10n),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(
    TransactionFormState formState,
    AppLocalizations l10n,
  ) {
    final isEnabled = _isCreating
        ? (formState.isFormPure || formState.isFormValid)
        : (formState.hasFormBeenModified && formState.isFormValid);

    return ElevatedButton.icon(
      onPressed: isEnabled ? () => _handleSubmit(context, ref) : null,
      icon: const Icon(Icons.save),
      label: Text(
        _isCreating
            ? l10n.createTransactionButton
            : l10n.updateTransactionButton,
      ),
    );
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
          segments: _buildTypeSegments(l10n),
          selected: {formState.type},
          onSelectionChanged: (Set<TransactionType> newSelection) {
            ref
                .read(
                  transactionFormProvider(
                    transactionId,
                    selectedDate: selectedDate,
                  ).notifier,
                )
                .typeChanged(newSelection.first);
          },
        ),
      ],
    );
  }

  ButtonSegment<TransactionType> _buildTypeSegment(
    TransactionType type,
    String label,
  ) {
    return ButtonSegment(
      value: type,
      label: SizedBox(
        width: 70,
        child: Text(label, overflow: TextOverflow.ellipsis, maxLines: 1),
      ),
      icon: Icon(TransactionIcons.getIconByType(type)),
    );
  }

  List<ButtonSegment<TransactionType>> _buildTypeSegments(
    AppLocalizations l10n,
  ) {
    return [
      _buildTypeSegment(TransactionType.expense, l10n.expenseType),
      _buildTypeSegment(TransactionType.income, l10n.incomeType),
      _buildTypeSegment(TransactionType.transfer, l10n.transferType),
    ];
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
              .deleteTransaction(transactionId);
          if (context.mounted) {
            _showSuccessSnackbar(context, l10n.transactionDeletedSuccess);
            context.pop();
          }
        } catch (e) {
          if (context.mounted) {
            _showErrorSnackbar(
              context,
              l10n.transactionDeleteError(e.toString()),
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
            transactionId,
            selectedDate: selectedDate,
          ).notifier,
        )
        .onFormSubmit();

    if (!context.mounted) return;

    final l10n = AppLocalizations.of(context)!;
    if (success) {
      final message = _isCreating
          ? l10n.transactionCreatedSuccess
          : l10n.transactionUpdatedSuccess;
      _showSuccessSnackbar(context, message);
      context.pop();
    } else {
      _showErrorSnackbar(context, l10n.transactionSaveError);
    }
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _updateControllers(TransactionFormState formState) {
    final formatter = CalendarDateFormatter(Localizations.localeOf(context));
    _dateController.text = formatter.formatFullDate(formState.date);
    _timeController.text = formatter.formatTime(formState.date);
  }
}

class _TransferForm extends ConsumerStatefulWidget {
  final String transactionId;
  final DateTime? selectedDate;
  final TransactionFormState formState;
  final AsyncValue<List<AccountEntity>> accountsAsync;
  final TextEditingController dateController;
  final TextEditingController timeController;
  final VoidCallback selectDate;
  final VoidCallback selectTime;

  const _TransferForm({
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
  ConsumerState<_TransferForm> createState() => _TransferFormState();
}

class _TransferFormState extends ConsumerState<_TransferForm> {
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
    final fromAccount = findAccountById(accountsAsync.value, formState.accountId);
    final toAccount = findAccountById(accountsAsync.value, formState.toAccountId);

    final fromCurrency = fromAccount?.currency;
    final toCurrency = toAccount?.currency;
    final fromAccountName = fromAccount?.name ?? '';
    final toAccountName = toAccount?.name ?? '';

    return Column(
      children: [
        _AccountSelector(
          formState: formState,
          accountsAsync: accountsAsync,
          l10n: l10n,
          transactionId: widget.transactionId,
          selectedDate: widget.selectedDate,
          labelOverride: l10n.fromAccountLabel,
          excludeAccountId: formState.toAccountId,
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
        _AccountSelector(
          formState: formState,
          accountsAsync: accountsAsync,
          l10n: l10n,
          transactionId: widget.transactionId,
          selectedDate: widget.selectedDate,
          targetCurrency: fromCurrency,
          labelOverride: l10n.toAccountLabel,
          excludeAccountId: formState.accountId,
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
        const SizedBox(height: 16),
        _AmountField(
          formState: formState,
          accountsAsync: accountsAsync,
          l10n: l10n,
          transactionId: widget.transactionId,
          selectedDate: widget.selectedDate,
        ),
        const SizedBox(height: 16),
        _DescriptionField(
          formState: formState,
          l10n: l10n,
          transactionId: widget.transactionId,
          selectedDate: widget.selectedDate,
        ),
        const SizedBox(height: 24),
        _DateTimeFields(
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
                    "This will move ${formState.amount.value} from $fromAccountName to $toAccountName.",
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
