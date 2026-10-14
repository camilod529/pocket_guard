import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_guard/domain/entities/account.dart';
import 'package:pocket_guard/domain/services/goal_progress_calculator.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/providers/savings_goal/savings_goals_provider.dart';
import 'package:pocket_guard/presentation/widgets/savings_goals/goal_error_message.dart';
import 'package:pocket_guard/presentation/widgets/shared/delete_confirmation_modal.dart';
import 'package:pocket_guard/utils/shared/number_formatting.dart';

/// Deletes a goal, asking where its money should go first when the jar
/// isn't empty - saved money must never just disappear. Resolves to true
/// once the goal is gone.
Future<bool> deleteGoalFlow(
  BuildContext context,
  WidgetRef ref,
  GoalProgress progress,
) async {
  final l10n = AppLocalizations.of(context)!;
  final goal = progress.goal;

  if (progress.saved <= 0) {
    // Awaiting the modal's result rather than doing the work in onConfirm
    // (which the modal fires without awaiting) so callers learn whether the
    // delete actually succeeded.
    final confirmed = await DeleteConfirmationModal.show(
      context: context,
      title: l10n.deleteGoalTitle,
      entity: goal.name,
      description: l10n.deleteGoalDescription,
      onConfirm: () {},
    );
    if (confirmed != true || !context.mounted) return false;
    return _delete(context, ref, goal.id, null, l10n);
  }

  final refundAccountId = await showDialog<String>(
    context: context,
    builder: (_) => _RefundAccountDialog(progress: progress),
  );
  if (refundAccountId == null || !context.mounted) return false;
  return _delete(context, ref, goal.id, refundAccountId, l10n);
}

Future<bool> _delete(
  BuildContext context,
  WidgetRef ref,
  String goalId,
  String? refundAccountId,
  AppLocalizations l10n,
) async {
  try {
    await ref
        .read(savingsGoalsProvider.notifier)
        .deleteGoal(goalId, refundAccountId: refundAccountId);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.goalDeletedSuccess),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
    return true;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(goalErrorMessage(l10n, e)),
          backgroundColor: Colors.red,
        ),
      );
    }
    return false;
  }
}

class _RefundAccountDialog extends ConsumerStatefulWidget {
  final GoalProgress progress;

  const _RefundAccountDialog({required this.progress});

  @override
  ConsumerState<_RefundAccountDialog> createState() =>
      _RefundAccountDialogState();
}

class _RefundAccountDialogState extends ConsumerState<_RefundAccountDialog> {
  String? _accountId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final goal = widget.progress.goal;

    return AlertDialog(
      title: Text(l10n.deleteGoalTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.deleteGoalRefundPrompt(
              NumberFormatting.formatCurrencyWithSymbol(
                widget.progress.saved,
                goal.currency,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(l10n.deleteGoalDescription),
          const SizedBox(height: 16),
          // A plain radio list, not AccountSelectorField: that one's
          // LayoutBuilder throws when AlertDialog measures its content's
          // intrinsic size (caught by goal_detail_screen_test.dart).
          RadioGroup<String>(
            groupValue: _accountId,
            onChanged: (id) => setState(() => _accountId = id),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final account
                    in ref.watch(accountsProvider).value ??
                        const <AccountEntity>[])
                  if (account.currency == goal.currency)
                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      value: account.id,
                      title: Text(account.name),
                    ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: _accountId == null
              ? null
              : () => Navigator.of(context).pop(_accountId),
          child: Text(l10n.delete),
        ),
      ],
    );
  }
}
