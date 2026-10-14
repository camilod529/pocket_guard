import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_guard/config/router/routes.dart';
import 'package:pocket_guard/domain/entities/account.dart';
import 'package:pocket_guard/domain/entities/goal_contribution.dart';
import 'package:pocket_guard/domain/services/goal_progress_calculator.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/providers/savings_goal/goal_progress_provider.dart';
import 'package:pocket_guard/presentation/providers/savings_goal/savings_goals_provider.dart';
import 'package:pocket_guard/presentation/widgets/savings_goals/contribution_sheet.dart';
import 'package:pocket_guard/presentation/widgets/savings_goals/delete_goal_flow.dart';
import 'package:pocket_guard/presentation/widgets/savings_goals/goal_error_message.dart';
import 'package:pocket_guard/presentation/widgets/savings_goals/goal_progress_card.dart';
import 'package:pocket_guard/presentation/widgets/shared/delete_confirmation_modal.dart';
import 'package:pocket_guard/utils/shared/dates/calendar_date_formatter.dart';
import 'package:pocket_guard/utils/shared/number_formatting.dart';

class GoalDetailScreen extends ConsumerWidget {
  final String goalId;

  const GoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final progressAsync = ref.watch(goalProgressProvider);

    return progressAsync.when(
      data: (progressList) {
        final matches = progressList.where((p) => p.goal.id == goalId);
        // Gone after a delete, before the pop lands.
        if (matches.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.goals)),
            body: const SizedBox.shrink(),
          );
        }
        return _buildContent(context, ref, matches.first, l10n);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.goals)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: Text(l10n.goals)),
        body: Center(child: Text(l10n.error_unknown_data)),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    GoalProgress progress,
    AppLocalizations l10n,
  ) {
    final goal = progress.goal;
    final contributionsAsync = ref.watch(goalContributionsProvider(goalId));
    final accountsById = {
      for (final a in ref.watch(accountsProvider).value ?? <AccountEntity>[])
        a.id: a,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(goal.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: l10n.edit,
            onPressed: () => context.push(Routes.savingsGoalFormPage(goalId)),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.delete,
            onPressed: () async {
              if (await deleteGoalFlow(context, ref, progress) &&
                  context.mounted) {
                context.pop();
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GoalProgressCard(progress: progress),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _move(context, progress, false, l10n),
                    icon: const Icon(Icons.savings),
                    label: Text(l10n.depositToGoal),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: progress.saved > 0
                        ? () => _move(context, progress, true, l10n)
                        : null,
                    icon: const Icon(Icons.north_east),
                    label: Text(l10n.withdrawFromGoal),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              l10n.goalHistory,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            contributionsAsync.when(
              data: (contributions) => contributions.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        l10n.noContributionsMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : Column(
                      children: [
                        for (final c in contributions)
                          _buildContributionTile(
                            context,
                            ref,
                            c,
                            goal.currency,
                            accountsById,
                            l10n,
                          ),
                      ],
                    ),
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => Text(l10n.error_unknown_data),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContributionTile(
    BuildContext context,
    WidgetRef ref,
    GoalContributionEntity contribution,
    String currency,
    Map<String, AccountEntity> accountsById,
    AppLocalizations l10n,
  ) {
    final account = accountsById[contribution.accountId];
    final color = contribution.isWithdrawal ? Colors.orange : Colors.green;
    final date = CalendarDateFormatter(
      Localizations.localeOf(context),
    ).formatFullDate(contribution.date);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withAlpha(38),
        child: Icon(
          contribution.isWithdrawal ? Icons.north_east : Icons.south_west,
          color: color,
        ),
      ),
      title: Text(account?.name ?? l10n.deletedAccountLabel),
      subtitle: Text(
        contribution.note == null ? date : '$date · ${contribution.note}',
      ),
      trailing: Text(
        '${contribution.isWithdrawal ? '-' : '+'}'
        '${NumberFormatting.formatCurrencyWithSymbol(contribution.amount.abs(), currency)}',
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
      // Orphaned movements can't be reversed (their account is gone).
      onLongPress: contribution.accountId == null
          ? null
          : () => _deleteContribution(context, ref, contribution, l10n),
    );
  }

  Future<void> _deleteContribution(
    BuildContext context,
    WidgetRef ref,
    GoalContributionEntity contribution,
    AppLocalizations l10n,
  ) async {
    final confirmed = await DeleteConfirmationModal.show(
      context: context,
      title: l10n.deleteContributionTitle,
      entity: l10n.thisContribution,
      description: l10n.deleteContributionDescription,
      onConfirm: () {},
    );
    if (confirmed != true) return;

    try {
      await ref
          .read(savingsGoalsProvider.notifier)
          .deleteContribution(contribution);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(goalErrorMessage(l10n, e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _move(
    BuildContext context,
    GoalProgress progress,
    bool isWithdrawal,
    AppLocalizations l10n,
  ) async {
    final moved = await ContributionSheet.show(
      context,
      goal: progress.goal,
      isWithdrawal: isWithdrawal,
    );
    if (moved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isWithdrawal ? l10n.goalWithdrawSuccess : l10n.goalDepositSuccess,
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
