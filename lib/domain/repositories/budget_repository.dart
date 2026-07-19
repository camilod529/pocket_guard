import 'package:pocket_guard/domain/entities/budget.dart';

abstract class BudgetRepository {
  Future<void> createBudget(BudgetEntity budget);
  Future<void> deleteBudget(String id);
  Future<BudgetEntity?> getBudgetById(String id);
  Future<List<BudgetEntity>> getAllBudgets();
  Future<void> updateBudget(String id, BudgetEntity budget);
}
