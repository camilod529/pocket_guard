import 'package:pocket_guard/domain/entities/savings_goal.dart';
import 'package:pocket_guard/presentation/providers/savings_goal/savings_goals_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'savings_goal_provider.g.dart';

@Riverpod(keepAlive: true)
class SavingsGoalNotifier extends _$SavingsGoalNotifier {
  @override
  Future<SavingsGoalEntity?> build(String id) async {
    if (id.isEmpty) return null;
    final repository = ref.read(savingsGoalRepositoryProvider);
    return repository.getGoalById(id);
  }

  Future<void> refreshGoal() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build(id));
  }
}
