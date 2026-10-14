import 'package:pocket_guard/domain/data_sources/budget_data_source.dart';
import 'package:pocket_guard/domain/entities/budget.dart';
import 'package:pocket_guard/domain/repositories/budget_repository.dart';
import 'package:pocket_guard/infrastructure/data_sources/budget_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/repositories/budget_repository_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'budgets_provider.g.dart';

@Riverpod(keepAlive: true)
BudgetDataSource budgetDataSource(Ref ref) {
  return BudgetDriftDataSourceImpl();
}

@Riverpod(keepAlive: true)
BudgetRepository budgetRepository(Ref ref) {
  final dataSource = ref.watch(budgetDataSourceProvider);
  return BudgetRepositoryImpl(dataSource: dataSource);
}

// Every mutating method reverts to the previous state and rethrows on
// failure, rather than committing `state = AsyncValue.error(...)` - callers
// (budget_form_provider's onFormSubmit, the delete confirmation flows in
// budget_form_screen.dart/budget_view.dart) catch the exception normally to
// know an operation failed. Deliberately NOT using AsyncValue.error here:
// setting it on an AsyncNotifier while nothing is actively awaiting
// `.future` at that exact moment surfaces as an uncaught error via
// Riverpod's internal Future/Completer plumbing, escaping the caller's own
// try/catch entirely instead of being caught by it.
@riverpod
class BudgetsNotifier extends _$BudgetsNotifier {
  @override
  Future<List<BudgetEntity>> build() async {
    final repository = ref.read(budgetRepositoryProvider);
    return repository.getAllBudgets();
  }

  Future<void> createBudget(BudgetEntity budget) async {
    if (!ref.mounted) return;
    final previousState = state;
    state = const AsyncLoading();
    try {
      final repository = ref.read(budgetRepositoryProvider);
      await repository.createBudget(budget);
      if (!ref.mounted) return;
      state = AsyncValue.data(await repository.getAllBudgets());
    } catch (e) {
      if (ref.mounted) state = previousState;
      rethrow;
    }
  }

  Future<void> deleteBudget(String id) async {
    if (!ref.mounted) return;
    final previousState = state;
    state = const AsyncLoading();
    try {
      final repository = ref.read(budgetRepositoryProvider);
      await repository.deleteBudget(id);
      if (!ref.mounted) return;
      state = AsyncValue.data(await repository.getAllBudgets());
    } catch (e) {
      if (ref.mounted) state = previousState;
      rethrow;
    }
  }

  Future<void> refresh() async {
    if (!ref.mounted) return;
    final previousState = state;
    state = const AsyncLoading();
    try {
      final repository = ref.read(budgetRepositoryProvider);
      final budgets = await repository.getAllBudgets();
      if (!ref.mounted) return;
      state = AsyncValue.data(budgets);
    } catch (e) {
      if (ref.mounted) state = previousState;
      rethrow;
    }
  }

  Future<void> updateBudget(String id, BudgetEntity budget) async {
    if (!ref.mounted) return;
    final previousState = state;
    state = const AsyncLoading();
    try {
      final repository = ref.read(budgetRepositoryProvider);
      await repository.updateBudget(id, budget);
      if (!ref.mounted) return;
      state = AsyncValue.data(await repository.getAllBudgets());
    } catch (e) {
      if (ref.mounted) state = previousState;
      rethrow;
    }
  }
}
