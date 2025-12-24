import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:money_manager_flutter/domain/entities/account.dart';
import 'package:money_manager_flutter/domain/entities/category.dart';
import 'package:money_manager_flutter/presentation/providers/account/accounts_provider.dart';
import 'package:money_manager_flutter/presentation/providers/category/categories_provider.dart';
import 'package:money_manager_flutter/presentation/providers/transaction/transaction_form_provider.dart';
import 'package:money_manager_flutter/presentation/widgets/shared/forms/custom_form_field.dart';
import 'package:money_manager_flutter/utils/constants/global_constants.dart';

class TransactionFormScreen extends ConsumerStatefulWidget {
  final String transactionId; // "create" or real UUID

  const TransactionFormScreen({super.key, required this.transactionId});

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isCreating = widget.transactionId == GlobalConstants.createId;

    final formStateAsync = ref.watch(
      transactionFormProvider(widget.transactionId),
    );
    final categoriesAsync = ref.watch(categoriesProvider);
    final accountsAsync = ref.watch(accountsProvider);

    return formStateAsync.when(
      data: (formState) {
        // Update date and time controllers
        _dateController.text = DateFormat.yMMMd().format(formState.date);
        _timeController.text = DateFormat.jm().format(formState.date);

        return Scaffold(
          appBar: AppBar(
            title: Text(isCreating ? 'New Transaction' : 'Edit Transaction'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: MediaQuery.of(
                context,
              ).padding.copyWith(top: 0, bottom: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // account Selector
                        _buildAccountSelector(formState, accountsAsync),
                        const SizedBox(height: 16),

                        // Amount Field
                        SizedBox(
                          child: CustomFormField(
                            initialValue: formState.amount.value,
                            label: 'Amount',
                            hintText: '0.00',
                            errorText: formState.isFormPure
                                ? null
                                : formState.amountError,
                            prefixIcon: const Icon(Icons.attach_money),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}'),
                              ),
                            ],
                            onChanged: (value) {
                              ref
                                  .read(
                                    transactionFormProvider(
                                      widget.transactionId,
                                    ).notifier,
                                  )
                                  .amountChanged(value);
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Description Field
                        SizedBox(
                          height: 100, // Fixed height for multi-line field
                          child: CustomFormField(
                            initialValue: formState.description.value,
                            label: 'Description',
                            hintText: 'Enter transaction description',
                            errorText: formState.isFormPure
                                ? null
                                : formState.descriptionError,
                            prefixIcon: const Icon(Icons.notes_outlined),
                            keyboardType: TextInputType.text,
                            maxLines: 2,
                            onChanged: (value) {
                              ref
                                  .read(
                                    transactionFormProvider(
                                      widget.transactionId,
                                    ).notifier,
                                  )
                                  .descriptionChanged(value);
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Category Selector
                        _buildCategorySelector(formState, categoriesAsync),
                        const SizedBox(height: 16),

                        // Date and Time Row
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    _selectDate(context, formState.date),
                                child: AbsorbPointer(
                                  child: SizedBox(
                                    height: 72,
                                    child: CustomFormField(
                                      controller: _dateController,
                                      label: 'Date',
                                      hintText: 'Select date',
                                      prefixIcon: const Icon(
                                        Icons.calendar_today,
                                      ),
                                      readOnly: true,
                                      onChanged: (_) {},
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    _selectTime(context, formState.date),
                                child: AbsorbPointer(
                                  child: SizedBox(
                                    height: 72,
                                    child: CustomFormField(
                                      controller: _timeController,
                                      label: 'Time',
                                      hintText: 'Select time',
                                      prefixIcon: const Icon(Icons.access_time),
                                      readOnly: true,
                                      onChanged: (_) {},
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Transaction Type Selector
                        _buildTransactionTypeSelector(formState),
                        const Spacer(), // Pushes button to bottom
                        const SizedBox(height: 32),

                        // Submit Button
                        ElevatedButton.icon(
                          onPressed:
                              formState.isFormPure || formState.isFormValid
                              ? () => _handleSubmit(context, ref)
                              : null,
                          icon: const Icon(Icons.save),
                          label: Text(
                            isCreating
                                ? 'Create Transaction'
                                : 'Update Transaction',
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Transaction')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('Error loading transaction: $error'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
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

  Widget _buildAccountSelector(
    TransactionFormState formState,
    AsyncValue<List<AccountEntity>> accountsAsync,
  ) {
    return accountsAsync.when(
      data: (accounts) {
        return IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Account',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 72,
                child: DropdownButtonFormField<String>(
                  initialValue: formState.accountId,
                  decoration: InputDecoration(
                    hintText: 'Select an account',
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
                  items: accounts.map((account) {
                    return DropdownMenuItem(
                      value: account.id,
                      child: Text('${account.name} (${account.currency})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(
                            transactionFormProvider(
                              widget.transactionId,
                            ).notifier,
                          )
                          .accountChanged(value);
                    }
                  },
                ),
              ),
              if (formState.accountId == null && !formState.isFormPure)
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 8),
                  child: Text(
                    'Please select an account',
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
      loading: () => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Account', style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          LinearProgressIndicator(),
        ],
      ),
      error: (error, stack) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Account', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text('Error loading accounts: $error'),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(
    TransactionFormState formState,
    AsyncValue<List<CategoryEntity>> categoriesAsync,
  ) {
    return categoriesAsync.when(
      data: (categories) {
        // Filter categories based on transaction type
        final filteredCategories = categories.where((cat) {
          return cat.type == formState.type;
        }).toList();

        return IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 72,
                child: DropdownButtonFormField<String>(
                  initialValue: formState.categoryId,
                  decoration: InputDecoration(
                    hintText: 'Select a category',
                    prefixIcon: Icon(_getCategoryIconByType(formState.type)),
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
                  items: filteredCategories.map((category) {
                    return DropdownMenuItem(
                      value: category.id,
                      child: Row(
                        children: [
                          Icon(_getCategoryIconByType(category.type)),
                          const SizedBox(width: 8),
                          Expanded(child: Text(category.label)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(
                            transactionFormProvider(
                              widget.transactionId,
                            ).notifier,
                          )
                          .categoryChanged(value);
                    }
                  },
                ),
              ),
              if (formState.categoryId == null && !formState.isFormPure)
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 8),
                  child: Text(
                    'Please select a category',
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
      loading: () => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Category', style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          LinearProgressIndicator(),
        ],
      ),
      error: (error, stack) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Category', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text('Error loading categories: $error'),
        ],
      ),
    );
  }

  Widget _buildTransactionTypeSelector(TransactionFormState formState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Transaction Type',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 56,
          child: SegmentedButton<TransactionType>(
            segments: const [
              ButtonSegment(
                value: TransactionType.expense,
                label: Text('Expense'),
                icon: Icon(Icons.arrow_upward),
              ),
              ButtonSegment(
                value: TransactionType.income,
                label: Text('Income'),
                icon: Icon(Icons.arrow_downward),
              ),
              ButtonSegment(
                value: TransactionType.transfer,
                label: Text('Transfer'),
                icon: Icon(Icons.swap_horiz),
              ),
            ],
            selected: {formState.type},
            onSelectionChanged: (Set<TransactionType> newSelection) {
              ref
                  .read(transactionFormProvider(widget.transactionId).notifier)
                  .typeChanged(newSelection.first);
            },
          ),
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

  Future<void> _handleSubmit(BuildContext context, WidgetRef ref) async {
    final success = await ref
        .read(transactionFormProvider(widget.transactionId).notifier)
        .onFormSubmit();

    if (success && context.mounted) {
      final message = widget.transactionId == GlobalConstants.createId
          ? 'Transaction created successfully!'
          : 'Transaction updated successfully!';

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      if (context.mounted) {
        context.pop();
      }
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save transaction'),
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
      // Combine picked date with current time
      final newDateTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        currentDate.hour,
        currentDate.minute,
      );

      ref
          .read(transactionFormProvider(widget.transactionId).notifier)
          .dateChanged(newDateTime);
    }
  }

  Future<void> _selectTime(BuildContext context, DateTime currentDate) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentDate),
    );

    if (picked != null && mounted) {
      // Combine current date with picked time
      final newDateTime = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        picked.hour,
        picked.minute,
      );

      ref
          .read(transactionFormProvider(widget.transactionId).notifier)
          .dateChanged(newDateTime);
    }
  }
}
