import 'package:pocket_guard/domain/entities/budget.dart';
import 'package:pocket_guard/presentation/providers/budget/budgets_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'budget_provider.g.dart';

@Riverpod(keepAlive: true)
class BudgetNotifier extends _$BudgetNotifier {
  @override
  Future<BudgetEntity?> build(String id) async {
    if (id.isEmpty) return null;
    final repository = ref.read(budgetRepositoryProvider);
    return repository.getBudgetById(id);
  }

  Future<void> refreshBudget() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build(state.value?.id ?? ''));
  }
}
