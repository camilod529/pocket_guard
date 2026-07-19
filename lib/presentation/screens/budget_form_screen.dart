import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_guard/domain/entities/budget.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/providers/budget/budget_form_provider.dart';
import 'package:pocket_guard/presentation/providers/budget/budget_provider.dart';
import 'package:pocket_guard/presentation/providers/budget/budgets_provider.dart';
import 'package:pocket_guard/presentation/providers/category/categories_provider.dart';
import 'package:pocket_guard/presentation/widgets/shared/delete_confirmation_modal.dart';
import 'package:pocket_guard/presentation/widgets/shared/forms/category_selector_field.dart';
import 'package:pocket_guard/presentation/widgets/shared/forms/custom_form_field.dart';
import 'package:pocket_guard/utils/constants/global_constants.dart';
import 'package:pocket_guard/utils/shared/number_formatting.dart';

class BudgetFormScreen extends ConsumerWidget {
  final String budgetId;

  const BudgetFormScreen({super.key, required this.budgetId});

  bool get _isCreating => budgetId == GlobalConstants.createId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final formStateAsync = ref.watch(budgetFormProvider(budgetId));
    final categoriesAsync = ref.watch(categoriesProvider);
    final budgetsAsync = ref.watch(budgetsProvider);
    final accountsAsync = ref.watch(accountsProvider);
    final availableCurrencies =
        accountsAsync.value?.map((a) => a.currency).toSet().toList() ??
        const <String>[];

    return formStateAsync.when(
      data: (formState) => Scaffold(
        appBar: AppBar(
          title: Text(_isCreating ? l10n.newBudgetTitle : l10n.editBudgetTitle),
          actions: [
            if (!_isCreating)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _handleDelete(
                  context,
                  ref,
                  formState,
                  categoriesAsync,
                  l10n,
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CategorySelectorField(
                  // Budgets only make sense against categories you actually
                  // spend from - restrict to expense categories, and
                  // exclude ones that already have a budget in the
                  // currently selected currency (a category can have
                  // separate budgets per currency, since budgets are
                  // currency-scoped - see budgetProgressProvider).
                  categoriesAsync: _availableCategories(
                    categoriesAsync,
                    budgetsAsync,
                    currentBudgetId: formState.id,
                    currentCurrency: formState.currency,
                  ),
                  l10n: l10n,
                  prefixIcon: Icons.category_outlined,
                  type: TransactionType.expense,
                  categoryId: formState.categoryId,
                  isFormPure: formState.isFormPure,
                  onChanged: (value) => ref
                      .read(budgetFormProvider(budgetId).notifier)
                      .categoryChanged(value),
                ),
                const SizedBox(height: 16),
                // A category can have transactions from accounts in
                // different currencies, so the budget needs its own
                // explicit currency - spending is only ever summed from
                // transactions in this currency (see budgetProgressProvider).
                LayoutBuilder(
                  builder: (context, constraints) {
                    return DropdownMenu<String>(
                      width: constraints.maxWidth,
                      initialSelection: formState.currency,
                      label: Text(l10n.currencyLabel),
                      selectOnly: true,
                      enabled: availableCurrencies.isNotEmpty,
                      helperText: availableCurrencies.isEmpty
                          ? l10n.budgetCurrencyNoAccountsHint
                          : null,
                      dropdownMenuEntries: [
                        for (final currency in availableCurrencies)
                          DropdownMenuEntry(value: currency, label: currency),
                      ],
                      onSelected: (currency) => ref
                          .read(budgetFormProvider(budgetId).notifier)
                          .currencyChanged(currency),
                    );
                  },
                ),
                const SizedBox(height: 16),
                CustomFormField(
                  initialValue: NumberFormatting.formatNumber(
                    formState.monthlyLimit.value,
                  ),
                  label: l10n.monthlyLimitLabel,
                  hintText: l10n.monthlyLimitHint,
                  errorText: formState.isFormPure
                      ? null
                      : formState.monthlyLimitError,
                  prefixIcon: const Icon(Icons.attach_money),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      widthFactor: 1,
                      child: Text(
                        formState.currency ?? '',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  selectAllOnFocus: true,
                  onChanged: (value) {
                    final parsed = NumberFormatting.parseUserInput(
                      value,
                      formState.currency ?? 'USD',
                    );
                    if (parsed != null || value.isEmpty) {
                      ref
                          .read(budgetFormProvider(budgetId).notifier)
                          .monthlyLimitChanged(
                            parsed ?? formState.monthlyLimit.value,
                          );
                    }
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: formState.isFormValid
                      ? () => _handleSubmit(context, ref, l10n)
                      : null,
                  icon: const Icon(Icons.save),
                  label: Text(
                    _isCreating
                        ? l10n.createBudgetButton
                        : l10n.updateBudgetButton,
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
        appBar: AppBar(title: Text(l10n.budgets)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: Text(l10n.budgets)),
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

  AsyncValue<List<CategoryEntity>> _availableCategories(
    AsyncValue<List<CategoryEntity>> categoriesAsync,
    AsyncValue<List<BudgetEntity>> budgetsAsync, {
    required String currentBudgetId,
    required String? currentCurrency,
  }) {
    // No currency chosen yet (e.g. multiple account currencies with no
    // default) - can't know which categories are already taken in
    // whichever currency ends up picked, so show them all. The unique
    // (category, currency) constraint is still enforced at submit time as
    // a fallback (see budget_form_provider_integration_test.dart).
    if (currentCurrency == null) return categoriesAsync;

    final budgetedCategoryIds =
        budgetsAsync.value
            ?.where(
              (b) => b.id != currentBudgetId && b.currency == currentCurrency,
            )
            .map((b) => b.categoryId)
            .toSet() ??
        <String>{};

    return categoriesAsync.whenData(
      (categories) =>
          categories.where((c) => !budgetedCategoryIds.contains(c.id)).toList(),
    );
  }

  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    BudgetFormState formState,
    AsyncValue<List<CategoryEntity>> categoriesAsync,
    AppLocalizations l10n,
  ) async {
    final categoryMatches =
        categoriesAsync.value?.where((c) => c.id == formState.categoryId) ??
        const Iterable<CategoryEntity>.empty();
    final categoryLabel = categoryMatches.isEmpty
        ? null
        : categoryMatches.first.label;

    await DeleteConfirmationModal.show(
      context: context,
      title: l10n.deleteBudgetTitle,
      entity: categoryLabel ?? l10n.thisBudget,
      description: l10n.deleteBudgetDescription,
      onConfirm: () async {
        try {
          await ref.read(budgetsProvider.notifier).deleteBudget(budgetId);
          // Same cache-split fix as onFormSubmit in budget_form_provider.dart
          // - budgetProvider(id) won't drop the deleted budget on its own.
          ref.invalidate(budgetProvider(budgetId));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.budgetDeletedSuccess),
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
        .read(budgetFormProvider(budgetId).notifier)
        .onFormSubmit();

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isCreating ? l10n.createBudgetButton : l10n.updateBudgetButton,
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      context.pop();
    } else {
      final submitError = ref
          .read(budgetFormProvider(budgetId))
          .value
          ?.submitError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            submitError == BudgetSubmitError.duplicateCategoryCurrency
                ? l10n.budgetDuplicateCategoryCurrencyError
                : l10n.error_db_operation_failed,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
