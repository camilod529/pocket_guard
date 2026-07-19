import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_guard/config/router/routes.dart';
import 'package:pocket_guard/domain/entities/account.dart';
import 'package:pocket_guard/domain/entities/recurring_transaction.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/providers/recurring_transaction/recurring_transactions_provider.dart';
import 'package:pocket_guard/presentation/widgets/shared/delete_confirmation_modal.dart';
import 'package:pocket_guard/utils/constants/global_constants.dart';
import 'package:pocket_guard/utils/shared/dates/calendar_date_formatter.dart';
import 'package:pocket_guard/utils/shared/find_account_by_id.dart';
import 'package:pocket_guard/utils/shared/number_formatting.dart';
import 'package:pocket_guard/utils/types/general_types.dart';

class RecurringTransactionView extends ConsumerWidget {
  const RecurringTransactionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rulesAsync = ref.watch(recurringTransactionsProvider);
    final accountsAsync = ref.watch(accountsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recurringTransactions),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.addRecurringTransaction,
            onPressed: () => context.push(
              Routes.recurringTransactionFormPage(GlobalConstants.createId),
            ),
          ),
        ],
      ),
      body: rulesAsync.when(
        data: (rules) => _buildList(context, ref, rules, accountsAsync, l10n),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, ref, l10n),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<RecurringTransactionEntity> rules,
    AsyncValue<List<AccountEntity>> accountsAsync,
    AppLocalizations l10n,
  ) {
    if (rules.isEmpty) {
      return _buildEmptyState(context, l10n);
    }

    final sorted = [...rules]
      ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
    final formatter = CalendarDateFormatter(Localizations.localeOf(context));

    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 80),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final rule = sorted[index];
        final currency =
            findAccountById(accountsAsync.value, rule.accountId)?.currency ??
            'USD';
        final frequencyLabel = switch (rule.frequency) {
          RecurrenceFrequency.daily => l10n.frequencyDaily,
          RecurrenceFrequency.weekly => l10n.frequencyWeekly,
          RecurrenceFrequency.monthly => l10n.frequencyMonthly,
          RecurrenceFrequency.yearly => l10n.frequencyYearly,
        };

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: rule.isActive
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Icon(
                rule.toAccountId != null
                    ? Icons.swap_horiz
                    : Icons.autorenew,
              ),
            ),
            title: Text(
              rule.description,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${NumberFormatting.formatCurrencyWithSymbol(rule.amount, currency)} '
              '· $frequencyLabel · '
              '${l10n.nextOccurrenceLabel}: ${formatter.formatShortDate(rule.nextDueDate)}',
            ),
            trailing: PopupMenuButton<DropdownActionType>(
              icon: const Icon(Icons.more_vert),
              onSelected: (action) => _onAction(context, ref, action, rule, l10n),
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
                      const Icon(Icons.delete, size: 20, color: Colors.red),
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
            onTap: () => context.push(
              Routes.recurringTransactionFormPage(rule.id),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.autorenew, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            l10n.noRecurringTransactionsMessage,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => context.push(
              Routes.recurringTransactionFormPage(GlobalConstants.createId),
            ),
            icon: const Icon(Icons.add),
            label: Text(l10n.addRecurringTransaction),
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
            onPressed: () => ref.invalidate(recurringTransactionsProvider),
            child: Text(l10n.error_db_operation_failed),
          ),
        ],
      ),
    );
  }

  void _onAction(
    BuildContext context,
    WidgetRef ref,
    DropdownActionType action,
    RecurringTransactionEntity rule,
    AppLocalizations l10n,
  ) {
    switch (action) {
      case DropdownActionType.edit:
        context.push(Routes.recurringTransactionFormPage(rule.id));
      case DropdownActionType.delete:
        _showDeleteConfirmation(context, ref, rule, l10n);
    }
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    RecurringTransactionEntity rule,
    AppLocalizations l10n,
  ) async {
    await DeleteConfirmationModal.show(
      context: context,
      title: l10n.deleteRecurringTransactionTitle,
      entity: rule.description.isEmpty
          ? l10n.thisRecurringTransaction
          : rule.description,
      description: l10n.deleteRecurringTransactionDescription,
      onConfirm: () async {
        try {
          await ref
              .read(recurringTransactionsProvider.notifier)
              .deleteRecurringTransaction(rule.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.recurringTransactionDeletedSuccess),
              ),
            );
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
