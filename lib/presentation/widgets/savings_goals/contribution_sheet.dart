import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_guard/domain/entities/goal_contribution.dart';
import 'package:pocket_guard/domain/entities/savings_goal.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/providers/savings_goal/savings_goals_provider.dart';
import 'package:pocket_guard/presentation/widgets/savings_goals/goal_error_message.dart';
import 'package:pocket_guard/presentation/widgets/shared/forms/account_selector_field.dart';
import 'package:pocket_guard/presentation/widgets/shared/forms/custom_form_field.dart';
import 'package:pocket_guard/utils/constants/global_constants.dart';
import 'package:pocket_guard/utils/shared/number_formatting.dart';

/// Bottom sheet for moving money into ([isWithdrawal] false) or out of a
/// jar. The user always enters a positive amount; the sign is applied here.
/// Rule checks (balance, jar total, currency) live in the data source -
/// a rejection is shown inline using its specific reason.
class ContributionSheet extends ConsumerStatefulWidget {
  final SavingsGoalEntity goal;
  final bool isWithdrawal;

  const ContributionSheet({
    super.key,
    required this.goal,
    required this.isWithdrawal,
  });

  /// Resolves to true when money was moved.
  static Future<bool?> show(
    BuildContext context, {
    required SavingsGoalEntity goal,
    required bool isWithdrawal,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ContributionSheet(goal: goal, isWithdrawal: isWithdrawal),
    );
  }

  @override
  ConsumerState<ContributionSheet> createState() => _ContributionSheetState();
}

class _ContributionSheetState extends ConsumerState<ContributionSheet> {
  double _amount = 0;
  String? _accountId;
  String _note = '';
  String? _error;
  bool _isSubmitting = false;
  bool _isPure = true;

  bool get _isValid => _amount > 0 && _accountId != null;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accountsAsync = ref.watch(accountsProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.isWithdrawal ? l10n.withdrawFromGoal : l10n.depositToGoal,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(widget.goal.name),
          const SizedBox(height: 24),
          AccountSelectorField(
            accountsAsync: accountsAsync,
            l10n: l10n,
            accountId: _accountId,
            isFormPure: _isPure,
            targetCurrency: widget.goal.currency,
            labelOverride: widget.isWithdrawal
                ? l10n.contributionToAccountLabel
                : l10n.contributionFromAccountLabel,
            onChanged: (id) => setState(() {
              _accountId = id;
              _error = null;
            }),
          ),
          const SizedBox(height: 16),
          CustomFormField(
            label: l10n.contributionAmountLabel,
            hintText: l10n.amountHint,
            errorText: !_isPure && _amount <= 0 ? l10n.goalAmountError : null,
            prefixIcon: const Icon(Icons.attach_money),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(widthFactor: 1, child: Text(widget.goal.currency)),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            onChanged: (value) => setState(() {
              _amount =
                  NumberFormatting.parseUserInput(
                    value,
                    widget.goal.currency,
                  ) ??
                  0;
              _error = null;
            }),
          ),
          const SizedBox(height: 16),
          CustomFormField(
            label: l10n.contributionNoteLabel,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (value) => _note = value.trim(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isSubmitting ? null : () => _submit(l10n),
            icon: Icon(widget.isWithdrawal ? Icons.north_east : Icons.savings),
            label: Text(
              widget.isWithdrawal ? l10n.withdrawFromGoal : l10n.depositToGoal,
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(AppLocalizations l10n) async {
    setState(() => _isPure = false);
    if (!_isValid) return;

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(savingsGoalsProvider.notifier)
          .addContribution(
            GoalContributionEntity(
              id: GlobalConstants.createId,
              goalId: widget.goal.id,
              accountId: _accountId,
              amount: widget.isWithdrawal ? -_amount : _amount,
              date: DateTime.now(),
              note: _note.isEmpty ? null : _note,
            ),
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = goalErrorMessage(l10n, e);
          _isSubmitting = false;
        });
      }
    }
  }
}
