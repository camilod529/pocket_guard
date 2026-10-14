import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_guard/config/router/routes.dart';
import 'package:pocket_guard/domain/entities/account.dart';
import 'package:pocket_guard/domain/entities/goal_contribution.dart';
import 'package:pocket_guard/domain/entities/wishlist_item.dart';
import 'package:pocket_guard/domain/services/goal_progress_calculator.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/providers/savings_goal/goal_progress_provider.dart';
import 'package:pocket_guard/presentation/providers/savings_goal/savings_goals_provider.dart';
import 'package:pocket_guard/presentation/providers/transaction/transaction_prefill.dart';
import 'package:pocket_guard/presentation/providers/wishlist/wishlist_provider.dart';
import 'package:pocket_guard/presentation/widgets/savings_goals/goal_error_message.dart';
import 'package:pocket_guard/utils/constants/global_constants.dart';
import 'package:pocket_guard/utils/shared/number_formatting.dart';

/// Buying goes through the normal transaction form, so balances, budgets
/// and insights all see it like any other expense:
///   1. If the item has a linked savings jar with money in it, offer to
///      move (up to) the price from the jar into an account first - the
///      transaction form's overdraft check needs the money to be there.
///   2. Open the transaction form pre-filled with the item.
///   3. Mark the item bought only if that transaction was actually saved.
/// Backing out of the form after step 1 leaves the moved money in the
/// account (not lost, just no longer in the jar).
Future<void> purchaseWishlistItem(
  BuildContext context,
  WidgetRef ref,
  WishlistItemEntity item,
) async {
  final l10n = AppLocalizations.of(context)!;

  final goal = (ref.read(goalProgressProvider).value ?? const <GoalProgress>[])
      .where(
        (g) =>
            g.goal.id == item.goalId &&
            g.goal.currency == item.currency &&
            g.saved > 0,
      )
      .firstOrNull;

  String? accountId;
  if (goal != null) {
    final withdrawal = min(goal.saved, item.price);
    final choice = await showDialog<_SavingsChoice>(
      context: context,
      builder: (_) => _UseSavingsDialog(goal: goal, amount: withdrawal),
    );
    if (choice == null || !context.mounted) return; // cancelled

    if (choice.accountId != null) {
      try {
        await ref
            .read(savingsGoalsProvider.notifier)
            .addContribution(
              GoalContributionEntity(
                id: GlobalConstants.createId,
                goalId: goal.goal.id,
                accountId: choice.accountId,
                amount: -withdrawal,
                date: DateTime.now(),
                note: item.name,
              ),
            );
        accountId = choice.accountId;
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(goalErrorMessage(l10n, e)),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }
  }

  if (!context.mounted) return;
  final saved = await context.push<bool>(
    Routes.transactionFormPage(GlobalConstants.createId),
    extra: TransactionPrefill(
      amount: item.price,
      categoryId: item.categoryId,
      accountId: accountId,
      description: item.name,
    ),
  );
  if (saved != true) return;

  try {
    await ref.read(wishlistProvider.notifier).markPurchased(item);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.wishlistPurchasedSuccess),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
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

/// accountId null = buy without touching the jar.
class _SavingsChoice {
  final String? accountId;

  const _SavingsChoice(this.accountId);
}

class _UseSavingsDialog extends ConsumerStatefulWidget {
  final GoalProgress goal;
  final double amount;

  const _UseSavingsDialog({required this.goal, required this.amount});

  @override
  ConsumerState<_UseSavingsDialog> createState() => _UseSavingsDialogState();
}

class _UseSavingsDialogState extends ConsumerState<_UseSavingsDialog> {
  String? _accountId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currency = widget.goal.goal.currency;

    return AlertDialog(
      title: Text(l10n.wishlistUseGoalTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.wishlistUseGoalPrompt(
              NumberFormatting.formatCurrencyWithSymbol(
                widget.amount,
                currency,
              ),
              widget.goal.goal.name,
            ),
          ),
          const SizedBox(height: 8),
          // Radio list rather than AccountSelectorField - its LayoutBuilder
          // throws under AlertDialog's intrinsic sizing (see
          // delete_goal_flow.dart).
          RadioGroup<String>(
            groupValue: _accountId,
            onChanged: (id) => setState(() => _accountId = id),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final account
                    in ref.watch(accountsProvider).value ??
                        const <AccountEntity>[])
                  if (account.currency == currency)
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
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(const _SavingsChoice(null)),
          child: Text(l10n.wishlistUseGoalSkip),
        ),
        FilledButton(
          onPressed: _accountId == null
              ? null
              : () => Navigator.of(context).pop(_SavingsChoice(_accountId)),
          child: Text(l10n.wishlistUseGoalConfirm),
        ),
      ],
    );
  }
}
