import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/providers/category/categories_provider.dart';
import 'package:pocket_guard/presentation/providers/savings_goal/savings_goals_provider.dart';
import 'package:pocket_guard/presentation/providers/wishlist/wishlist_form_provider.dart';
import 'package:pocket_guard/presentation/providers/wishlist/wishlist_provider.dart';
import 'package:pocket_guard/presentation/widgets/shared/delete_confirmation_modal.dart';
import 'package:pocket_guard/presentation/widgets/shared/forms/custom_form_field.dart';
import 'package:pocket_guard/utils/constants/global_constants.dart';
import 'package:pocket_guard/utils/shared/number_formatting.dart';

/// Value for "no selection" in the optional dropdowns - DropdownMenu can't
/// select a null entry.
const _none = '';

class WishlistFormScreen extends ConsumerWidget {
  final String itemId;

  const WishlistFormScreen({super.key, required this.itemId});

  bool get _isCreating => itemId == GlobalConstants.createId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final formStateAsync = ref.watch(wishlistFormProvider(itemId));
    final notifier = ref.read(wishlistFormProvider(itemId).notifier);
    final availableCurrencies =
        ref
            .watch(accountsProvider)
            .value
            ?.map((a) => a.currency)
            .toSet()
            .toList() ??
        const <String>[];
    final expenseCategories =
        ref
            .watch(categoriesProvider)
            .value
            ?.where((c) => c.type == TransactionType.expense)
            .toList() ??
        const <CategoryEntity>[];
    final goals = ref.watch(savingsGoalsProvider).value ?? const [];

    return formStateAsync.when(
      data: (formState) {
        final goalsInCurrency = goals
            .where((g) => !g.isArchived && g.currency == formState.currency)
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(
              _isCreating
                  ? l10n.newWishlistItemTitle
                  : l10n.editWishlistItemTitle,
            ),
            actions: [
              if (!_isCreating)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: l10n.delete,
                  onPressed: () => _handleDelete(context, ref, l10n),
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
                    label: l10n.wishlistItemNameLabel,
                    hintText: l10n.wishlistItemNameHint,
                    errorText:
                        !formState.isFormPure && formState.name.isNotValid
                        ? l10n.goalNameRequired
                        : null,
                    prefixIcon: const Icon(Icons.shopping_bag_outlined),
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: notifier.nameChanged,
                  ),
                  const SizedBox(height: 16),
                  _dropdown(
                    label: l10n.currencyLabel,
                    selection: formState.currency,
                    enabled: availableCurrencies.isNotEmpty,
                    helperText: availableCurrencies.isEmpty
                        ? l10n.wishlistCurrencyNoAccountsHint
                        : null,
                    entries: {for (final c in availableCurrencies) c: c},
                    onSelected: notifier.currencyChanged,
                  ),
                  const SizedBox(height: 16),
                  CustomFormField(
                    initialValue: NumberFormatting.formatNumber(
                      formState.price.value,
                    ),
                    label: l10n.wishlistPriceLabel,
                    hintText: l10n.amountHint,
                    errorText:
                        !formState.isFormPure && formState.price.isNotValid
                        ? l10n.goalAmountError
                        : null,
                    prefixIcon: const Icon(Icons.attach_money),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Center(
                        widthFactor: 1,
                        child: Text(formState.currency ?? ''),
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
                        notifier.priceChanged(parsed ?? 0);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // Optional: lets affordability check this category's
                  // budget, and pre-fills the purchase transaction.
                  _dropdown(
                    label: l10n.wishlistCategoryLabel,
                    selection: formState.categoryId,
                    entries: {
                      _none: l10n.wishlistNone,
                      for (final c in expenseCategories) c.id: c.label,
                    },
                    onSelected: (id) =>
                        notifier.categoryChanged(id == _none ? null : id),
                  ),
                  const SizedBox(height: 16),
                  // Optional: a jar whose savings count toward the price.
                  _dropdown(
                    // Rebuild when the currency changes - the goal list
                    // (and a now-invalid selection) depends on it.
                    key: ValueKey('goal-${formState.currency}'),
                    label: l10n.wishlistGoalLabel,
                    selection: formState.goalId,
                    entries: {
                      _none: l10n.wishlistNone,
                      for (final g in goalsInCurrency) g.id: g.name,
                    },
                    onSelected: (id) =>
                        notifier.goalChanged(id == _none ? null : id),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => _handleSubmit(context, ref, l10n),
                    icon: const Icon(Icons.save),
                    label: Text(
                      _isCreating
                          ? l10n.createWishlistItemButton
                          : l10n.updateWishlistItemButton,
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.wishlist)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: Text(l10n.wishlist)),
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

  Widget _dropdown({
    Key? key,
    required String label,
    required String? selection,
    required Map<String, String> entries,
    required void Function(String?) onSelected,
    bool enabled = true,
    String? helperText,
  }) {
    return LayoutBuilder(
      key: key,
      builder: (context, constraints) => DropdownMenu<String>(
        width: constraints.maxWidth,
        initialSelection: entries.containsKey(selection ?? _none)
            ? (selection ?? _none)
            : null,
        label: Text(label),
        selectOnly: true,
        enabled: enabled,
        helperText: helperText,
        dropdownMenuEntries: [
          for (final MapEntry(:key, :value) in entries.entries)
            DropdownMenuEntry(value: key, label: value),
        ],
        onSelected: onSelected,
      ),
    );
  }

  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirmed = await DeleteConfirmationModal.show(
      context: context,
      title: l10n.deleteWishlistItemTitle,
      entity: l10n.thisWishlistItem,
      onConfirm: () {},
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(wishlistProvider.notifier).deleteItem(itemId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.wishlistDeletedSuccess),
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
  }

  Future<void> _handleSubmit(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final success = await ref
        .read(wishlistFormProvider(itemId).notifier)
        .onFormSubmit();
    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isCreating
                ? l10n.createWishlistItemButton
                : l10n.updateWishlistItemButton,
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      context.pop();
    } else if (ref.read(wishlistFormProvider(itemId)).value?.hasSubmitError ??
        false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.error_db_operation_failed),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
