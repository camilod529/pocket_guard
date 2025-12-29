import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_manager_flutter/domain/entities/account.dart';
import 'package:money_manager_flutter/domain/entities/category.dart';
import 'package:money_manager_flutter/l10n/app_localizations.dart';
import 'package:money_manager_flutter/presentation/mixins/date_time_selection_mixin.dart';
import 'package:money_manager_flutter/presentation/providers/account/accounts_provider.dart';
import 'package:money_manager_flutter/presentation/providers/category/categories_provider.dart';
import 'package:money_manager_flutter/presentation/providers/transaction/transaction_form_provider.dart';
import 'package:money_manager_flutter/presentation/providers/transaction/transactions_provider.dart';
import 'package:money_manager_flutter/presentation/widgets/shared/delete_confirmation_modal.dart';
import 'package:money_manager_flutter/presentation/widgets/shared/forms/common_drop_down.dart';
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

// ============================================================================
// REUSABLE WIDGETS
// ============================================================================

class _AccountSelector extends ConsumerWidget {
  final TransactionFormState formState;
  final AsyncValue<List<AccountEntity>> accountsAsync;
  final AppLocalizations l10n;
  final String transactionId;
  final DateTime? selectedDate;
  final String? labelOverride;
  final void Function(String)? onChangedOverride;

  const _AccountSelector({
    required this.formState,
    required this.accountsAsync,
    required this.l10n,
    required this.transactionId,
    this.selectedDate,
    this.labelOverride,
    this.onChangedOverride,
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
    final accountId = onChangedOverride != null
        ? formState.toAccountId
        : formState.accountId;
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
              key: ValueKey(accounts.map((a) => a.id).join(',')),
              initialValue: accountId,
              decoration: DropdownDecorationHelper.getDecoration(
                hintText: l10n.selectAccountHint,
                prefixIcon: const Icon(Icons.account_balance_wallet),
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
              onChanged: (value) {
                if (value != null) {
                  if (onChangedOverride != null) {
                    onChangedOverride!(value);
                  } else {
                    ref
                        .read(
                          transactionFormProvider(
                            transactionId,
                            selectedDate: selectedDate,
                          ).notifier,
                        )
                        .accountChanged(value);
                  }
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
    final currency = formState.accountId == null
        ? 'USD'
        : accounts.firstWhere((acc) => acc.id == formState.accountId).currency;

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
            errorText: formState.isFormPure ? null : formState.amountError,
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

// ============================================================================
// FORM SECTIONS
// ============================================================================

class _IncomeExpenseForm extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AccountSelector(
          formState: formState,
          accountsAsync: accountsAsync,
          l10n: l10n,
          transactionId: transactionId,
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
                    transactionId: transactionId,
                    selectedDate: selectedDate,
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

  const _TransferForm({this.selectedDate, required this.transactionId});

  @override
  ConsumerState<_TransferForm> createState() => _TransferFormState();
}

class _TransferFormState extends ConsumerState<_TransferForm>
    with DateTimeSelectionMixin {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  @override
  DateTime? get selectedDate => widget.selectedDate;

  @override
  String get transactionId => widget.transactionId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final formStateAsync = ref.watch(
      transactionFormProvider(transactionId, selectedDate: selectedDate),
    );
    final accountsAsync = ref.watch(accountsProvider);

    return formStateAsync.when(
      data: (formState) {
        _updateControllers(formState);
        return _buildTransferFormContent(
          formState: formState,
          accountsAsync: accountsAsync,
          l10n: l10n,
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text(e.toString()),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Widget _buildTransferFormContent({
    required TransactionFormState formState,
    required AsyncValue<List<AccountEntity>> accountsAsync,
    required AppLocalizations l10n,
  }) {
    return Column(
      children: [
        _AccountSelector(
          formState: formState,
          accountsAsync: accountsAsync,
          l10n: l10n,
          transactionId: transactionId,
          selectedDate: selectedDate,
          labelOverride: l10n.fromAccountLabel,
        ),
        const SizedBox(height: 16),
        _AccountSelector(
          formState: formState,
          accountsAsync: accountsAsync,
          l10n: l10n,
          transactionId: transactionId,
          selectedDate: selectedDate,
          labelOverride: l10n.toAccountLabel,
          onChangedOverride: (value) => ref
              .read(transactionFormProvider(transactionId).notifier)
              .toAccountChanged(value),
        ),
        const SizedBox(height: 16),
        _AmountField(
          formState: formState,
          accountsAsync: accountsAsync,
          l10n: l10n,
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
        _DateTimeFields(
          l10n: l10n,
          dateController: _dateController,
          selectDate: () => selectDate(context, formState.date),
          timeController: _timeController,
          selectTime: () => selectTime(context, formState.date),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  void _updateControllers(TransactionFormState formState) {
    final formatter = CalendarDateFormatter(Localizations.localeOf(context));
    _dateController.text = formatter.formatFullDate(formState.date);
    _timeController.text = formatter.formatTime(formState.date);
  }
}
