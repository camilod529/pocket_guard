import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_guard/config/router/routes.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/domain/services/budget_progress_calculator.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/providers/budget/budget_progress_provider.dart';
import 'package:pocket_guard/presentation/providers/budget/budget_provider.dart';
import 'package:pocket_guard/presentation/providers/budget/budgets_provider.dart';
import 'package:pocket_guard/presentation/providers/category/categories_provider.dart';
import 'package:pocket_guard/presentation/widgets/shared/delete_confirmation_modal.dart';
import 'package:pocket_guard/utils/constants/global_constants.dart';
import 'package:pocket_guard/utils/shared/number_formatting.dart';
import 'package:pocket_guard/utils/types/general_types.dart';

class BudgetView extends ConsumerWidget {
  const BudgetView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(budgetProgressProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.budgets),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.addBudget,
            onPressed: () =>
                context.push(Routes.budgetFormPage(GlobalConstants.createId)),
          ),
        ],
      ),
      body: progressAsync.when(
        data: (progressList) =>
            _buildList(context, ref, progressList, categoriesAsync, l10n),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, ref, l10n),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pie_chart_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            l10n.noBudgetsMessage,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () =>
                context.push(Routes.budgetFormPage(GlobalConstants.createId)),
            icon: const Icon(Icons.add),
            label: Text(l10n.addBudget),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            l10n.error_unknown_data,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.invalidate(budgetProgressProvider),
            child: Text(l10n.error_db_operation_failed),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<BudgetProgress> progressList,
    AsyncValue<List<CategoryEntity>> categoriesAsync,
    AppLocalizations l10n,
  ) {
    if (progressList.isEmpty) {
      return _buildEmptyState(context, l10n);
    }

    final categoryMap = {for (var c in categoriesAsync.value ?? []) c.id: c};

    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 80),
      itemCount: progressList.length,
      itemBuilder: (context, index) {
        final progress = progressList[index];
        final category = categoryMap[progress.budget.categoryId];
        final statusColor = switch (progress.status) {
          BudgetStatus.onTrack => Colors.green,
          BudgetStatus.warning => Colors.orange,
          BudgetStatus.exceeded => Colors.red,
        };

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () =>
                context.push(Routes.budgetFormPage(progress.budget.id)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          category?.label ?? l10n.unknownCategory,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      PopupMenuButton<DropdownActionType>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (action) =>
                            _onAction(context, ref, action, progress, l10n),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: DropdownActionType.edit,
                            child: Row(
                              children: [
                                const Icon(Icons.edit, size: 20),
                                const SizedBox(width: 8),
                                Text(l10n.edit),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: DropdownActionType.delete,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.delete,
                                  size: 20,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.delete,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress.percentUsed.isFinite
                          ? progress.percentUsed.clamp(0.0, 1.0)
                          : 1.0,
                      minHeight: 8,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(statusColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Column, not a Row - formatted currency amounts (e.g.
                  // "USD1,000.00") are wide enough with an ISO code prefix
                  // that a single-line spaceBetween Row overflows on
                  // narrower screens/larger amounts. Stacking lets each
                  // line wrap independently instead.
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l10n.spentLabel}: '
                        '${NumberFormatting.formatCurrencyWithSymbol(progress.spent, progress.budget.currency)} '
                        '/ ${NumberFormatting.formatCurrencyWithSymbol(progress.budget.monthlyLimit, progress.budget.currency)}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.remainingLabel}: '
                        '${NumberFormatting.formatCurrencyWithSymbol(progress.remaining, progress.budget.currency)}',
                        style: TextStyle(color: statusColor, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onAction(
    BuildContext context,
    WidgetRef ref,
    DropdownActionType action,
    BudgetProgress progress,
    AppLocalizations l10n,
  ) {
    switch (action) {
      case DropdownActionType.edit:
        context.push(Routes.budgetFormPage(progress.budget.id));
      case DropdownActionType.delete:
        _showDeleteConfirmation(context, ref, progress, l10n);
    }
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    BudgetProgress progress,
    AppLocalizations l10n,
  ) async {
    await DeleteConfirmationModal.show(
      context: context,
      title: l10n.deleteBudgetTitle,
      entity: l10n.thisBudget,
      description: l10n.deleteBudgetDescription,
      onConfirm: () async {
        try {
          await ref
              .read(budgetsProvider.notifier)
              .deleteBudget(progress.budget.id);
          // Same cache-split fix as onFormSubmit in budget_form_provider.dart
          // - budgetProvider(id) won't drop the deleted budget on its own.
          ref.invalidate(budgetProvider(progress.budget.id));
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.budgetDeletedSuccess)));
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.error_db_operation_failed)),
            );
          }
        }
      },
    );
  }
}
