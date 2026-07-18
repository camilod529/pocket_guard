import 'package:flutter/material.dart';
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
import 'package:pocket_guard/presentation/widgets/transactions/income_expense_form.dart';
import 'package:pocket_guard/presentation/widgets/transactions/transfer_form.dart';
import 'package:pocket_guard/utils/constants/global_constants.dart';
import 'package:pocket_guard/utils/shared/dates/calendar_date_formatter.dart';
import 'package:pocket_guard/utils/shared/transaction_icons.dart';

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
                  IncomeExpenseForm(
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
                  TransferForm(
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
