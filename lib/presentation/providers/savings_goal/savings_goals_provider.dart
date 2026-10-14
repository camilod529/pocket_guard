import 'package:pocket_guard/domain/data_sources/savings_goal_data_source.dart';
import 'package:pocket_guard/domain/entities/goal_contribution.dart';
import 'package:pocket_guard/domain/entities/savings_goal.dart';
import 'package:pocket_guard/domain/repositories/savings_goal_repository.dart';
import 'package:pocket_guard/infrastructure/data_sources/savings_goal_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/repositories/savings_goal_repository_impl.dart';
import 'package:pocket_guard/presentation/providers/account/account_provider.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/providers/savings_goal/savings_goal_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'savings_goals_provider.g.dart';

@Riverpod(keepAlive: true)
SavingsGoalDataSource savingsGoalDataSource(Ref ref) {
  return SavingsGoalDriftDataSourceImpl();
}

@Riverpod(keepAlive: true)
SavingsGoalRepository savingsGoalRepository(Ref ref) {
  final dataSource = ref.watch(savingsGoalDataSourceProvider);
  return SavingsGoalRepositoryImpl(dataSource: dataSource);
}

/// The goal list. Contribution writes go through here too (not a separate
/// notifier) so every money movement re-emits this list - that's what
/// goalProgressProvider and goalContributionsProvider watch to recompute.
///
/// Same error contract as BudgetsNotifier: mutating methods revert to the
/// prior state and rethrow instead of setting `AsyncValue.error`, so callers
/// can catch [SavingsGoalValidationException] and show its reason.
@riverpod
class SavingsGoalsNotifier extends _$SavingsGoalsNotifier {
  @override
  Future<List<SavingsGoalEntity>> build() async {
    final repository = ref.read(savingsGoalRepositoryProvider);
    return repository.getAllGoals();
  }

  Future<void> addContribution(GoalContributionEntity contribution) async {
    await _mutate((repository) => repository.addContribution(contribution));
    _refreshAccounts({contribution.accountId});
  }

  Future<void> createGoal(SavingsGoalEntity goal) =>
      _mutate((repository) => repository.createGoal(goal));

  Future<void> deleteContribution(GoalContributionEntity contribution) async {
    await _mutate(
      (repository) => repository.deleteContribution(contribution.id),
    );
    _refreshAccounts({contribution.accountId});
  }

  Future<void> deleteGoal(String id, {String? refundAccountId}) async {
    await _mutate(
      (repository) =>
          repository.deleteGoal(id, refundAccountId: refundAccountId),
    );
    // savingsGoalProvider(id) is a separate keepAlive cache - drop it so a
    // stale copy of the deleted goal can't be shown again.
    ref.invalidate(savingsGoalProvider(id));
    _refreshAccounts({refundAccountId});
  }

  Future<void> refresh() => _mutate((_) async {});

  Future<void> updateGoal(String id, SavingsGoalEntity goal) async {
    await _mutate((repository) => repository.updateGoal(id, goal));
    // Same cache-split fix as budgetProvider(id)/accountProvider(id).
    await ref.read(savingsGoalProvider(id).notifier).refreshGoal();
  }

  Future<void> _mutate(
    Future<void> Function(SavingsGoalRepository repository) action,
  ) async {
    if (!ref.mounted) return;
    final previousState = state;
    state = const AsyncLoading();
    try {
      final repository = ref.read(savingsGoalRepositoryProvider);
      await action(repository);
      if (!ref.mounted) return;
      state = AsyncValue.data(await repository.getAllGoals());
    } catch (e) {
      if (ref.mounted) state = previousState;
      rethrow;
    }
  }

  /// Moving money in/out of a jar changes account balances, so both account
  /// caches need refreshing - the per-account one and the list the Accounts
  /// screen renders from (same pair the transaction save flow refreshes).
  void _refreshAccounts(Set<String?> accountIds) {
    for (final accountId in accountIds.nonNulls) {
      ref.read(accountProvider(accountId).notifier).refreshAccount();
    }
    ref.invalidate(accountsProvider);
  }
}
