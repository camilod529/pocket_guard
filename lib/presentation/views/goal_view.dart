import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_guard/config/router/routes.dart';
import 'package:pocket_guard/domain/services/goal_progress_calculator.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/providers/savings_goal/goal_progress_provider.dart';
import 'package:pocket_guard/presentation/providers/savings_goal/savings_goals_provider.dart';
import 'package:pocket_guard/presentation/widgets/savings_goals/goal_progress_card.dart';
import 'package:pocket_guard/presentation/widgets/shared/refreshable_placeholder.dart';
import 'package:pocket_guard/utils/constants/global_constants.dart';

class GoalView extends ConsumerWidget {
  const GoalView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(goalProgressProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.goals),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.addGoal,
            onPressed: () => context.push(
              Routes.savingsGoalFormPage(GlobalConstants.createId),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(savingsGoalsProvider.notifier).refresh(),
        child: progressAsync.when(
          data: (progressList) => _buildList(context, progressList, l10n),
          loading: () =>
              const RefreshablePlaceholder(child: CircularProgressIndicator()),
          error: (error, stack) => RefreshablePlaceholder(
            child: Text(l10n.error_unknown_data, textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<GoalProgress> progressList,
    AppLocalizations l10n,
  ) {
    if (progressList.isEmpty) {
      return RefreshablePlaceholder(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.savings_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              l10n.noGoalsMessage,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => context.push(
                Routes.savingsGoalFormPage(GlobalConstants.createId),
              ),
              icon: const Icon(Icons.add),
              label: Text(l10n.addGoal),
            ),
          ],
        ),
      );
    }

    final active = progressList.where((p) => !p.goal.isArchived).toList();
    final archived = progressList.where((p) => p.goal.isArchived).toList();

    Widget card(GoalProgress progress) => GoalProgressCard(
      progress: progress,
      onTap: () => context.push(Routes.goalDetailPage(progress.goal.id)),
    );

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 80),
      children: [
        ...active.map(card),
        if (archived.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
            child: Text(
              l10n.archivedGoalsSection,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ...archived.map(
            (progress) => Opacity(opacity: 0.6, child: card(progress)),
          ),
        ],
      ],
    );
  }
}
