import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_guard/domain/entities/budget.dart';
import 'package:pocket_guard/domain/entities/transaction.dart';
import 'package:pocket_guard/domain/services/budget_progress_calculator.dart';

TransactionEntity _tx(double amount) {
  return TransactionEntity(
    id: 'tx',
    accountId: 'account',
    amount: amount,
    date: DateTime(2026, 7, 15),
    categoryId: 'category',
  );
}

BudgetEntity _budget(double limit) {
  return BudgetEntity(
    id: 'budget',
    categoryId: 'category',
    monthlyLimit: limit,
    currency: 'USD',
    isActive: true,
  );
}

void main() {
  group('calculate', () {
    test('no spending yet is onTrack with full amount remaining', () {
      final progress = BudgetProgressCalculator.calculate(
        budget: _budget(500),
        categoryTransactionsThisMonth: [],
      );

      expect(progress.spent, 0);
      expect(progress.remaining, 500);
      expect(progress.percentUsed, 0);
      expect(progress.status, BudgetStatus.onTrack);
    });

    test('spending under the warning threshold is onTrack', () {
      final progress = BudgetProgressCalculator.calculate(
        budget: _budget(500),
        categoryTransactionsThisMonth: [_tx(100), _tx(249)],
      );

      expect(progress.spent, 349);
      expect(progress.remaining, 151);
      expect(progress.percentUsed, closeTo(0.698, 0.001));
      expect(progress.status, BudgetStatus.onTrack);
    });

    test('spending right at the warning threshold (75%) is warning', () {
      final progress = BudgetProgressCalculator.calculate(
        budget: _budget(400),
        categoryTransactionsThisMonth: [_tx(300)],
      );

      expect(progress.percentUsed, 0.75);
      expect(progress.status, BudgetStatus.warning);
    });

    test('spending between 75% and 100% is warning', () {
      final progress = BudgetProgressCalculator.calculate(
        budget: _budget(400),
        categoryTransactionsThisMonth: [_tx(350)],
      );

      expect(progress.status, BudgetStatus.warning);
    });

    test('spending exactly at the limit (100%) is warning, not exceeded', () {
      final progress = BudgetProgressCalculator.calculate(
        budget: _budget(400),
        categoryTransactionsThisMonth: [_tx(400)],
      );

      expect(progress.percentUsed, 1.0);
      expect(progress.remaining, 0);
      expect(progress.status, BudgetStatus.warning);
    });

    test('spending past the limit is exceeded, with negative remaining', () {
      final progress = BudgetProgressCalculator.calculate(
        budget: _budget(400),
        categoryTransactionsThisMonth: [_tx(450)],
      );

      expect(progress.remaining, -50);
      expect(progress.status, BudgetStatus.exceeded);
    });

    test('zero limit with no spending is onTrack at 0%', () {
      final progress = BudgetProgressCalculator.calculate(
        budget: _budget(0),
        categoryTransactionsThisMonth: [],
      );

      expect(progress.percentUsed, 0);
      expect(progress.status, BudgetStatus.onTrack);
    });

    test('zero limit with any spending is exceeded, not a division error', () {
      final progress = BudgetProgressCalculator.calculate(
        budget: _budget(0),
        categoryTransactionsThisMonth: [_tx(1)],
      );

      expect(progress.percentUsed, double.infinity);
      expect(progress.status, BudgetStatus.exceeded);
    });

    test('sums multiple transactions in the category', () {
      final progress = BudgetProgressCalculator.calculate(
        budget: _budget(1000),
        categoryTransactionsThisMonth: [_tx(100), _tx(200), _tx(300)],
      );

      expect(progress.spent, 600);
      expect(progress.remaining, 400);
    });
  });
}
