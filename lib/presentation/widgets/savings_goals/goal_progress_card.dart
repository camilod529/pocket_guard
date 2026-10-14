import 'package:flutter/material.dart';
import 'package:pocket_guard/domain/services/goal_progress_calculator.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/utils/shared/dates/calendar_date_formatter.dart';
import 'package:pocket_guard/utils/shared/number_formatting.dart';

/// Name, progress bar, saved-of-target and a status line for one goal.
/// Used both as a list row (with [onTap]) and as the detail screen header.
class GoalProgressCard extends StatelessWidget {
  final GoalProgress progress;
  final VoidCallback? onTap;

  const GoalProgressCard({super.key, required this.progress, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final goal = progress.goal;
    String money(double value) =>
        NumberFormatting.formatCurrencyWithSymbol(value, goal.currency);

    final statusColor = switch (progress.status) {
      GoalStatus.completed => Colors.green,
      GoalStatus.overdue => Colors.orange,
      GoalStatus.inProgress => colors.primary,
    };

    final String? statusText = switch (progress.status) {
      GoalStatus.completed => l10n.goalCompleted,
      GoalStatus.overdue => l10n.goalOverdue,
      GoalStatus.inProgress when progress.monthlyAmountNeeded != null =>
        l10n.goalMonthlyNeeded(
          money(progress.monthlyAmountNeeded!),
          CalendarDateFormatter(
            Localizations.localeOf(context),
          ).formatFullDate(goal.targetDate!),
        ),
      GoalStatus.inProgress => null,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      goal.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    '${(progress.percentSaved * 100).clamp(0, 999).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress.percentSaved.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: colors.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(statusColor),
                ),
              ),
              const SizedBox(height: 8),
              // Stacked rather than one Row - same overflow reasoning as
              // the budget cards (wide formatted currency amounts).
              Text(
                l10n.goalSavedOf(
                  money(progress.saved),
                  money(goal.targetAmount),
                ),
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
              ),
              if (statusText != null) ...[
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: TextStyle(color: statusColor, fontSize: 13),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
