import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_guard/domain/entities/wishlist_item.dart';
import 'package:pocket_guard/domain/services/affordability_calculator.dart';

void main() {
  WishlistItemEntity item({double price = 500, DateTime? purchasedAt}) {
    return WishlistItemEntity(
      id: 'item',
      name: 'Bike',
      price: price,
      currency: 'USD',
      categoryId: null,
      goalId: null,
      purchasedAt: purchasedAt,
      createdAt: DateTime(2026),
    );
  }

  Affordability calc({
    double price = 500,
    double funds = 1000,
    double? budgetRemaining,
    double? goalSaved,
    DateTime? purchasedAt,
  }) => AffordabilityCalculator.calculate(
    item: item(price: price, purchasedAt: purchasedAt),
    availableFunds: funds,
    budgetRemaining: budgetRemaining,
    goalSaved: goalSaved,
  );

  test('affordable with enough funds and no budget', () {
    final result = calc();
    expect(result.status, AffordabilityStatus.affordable);
    expect(result.shortfall, 0);
  });

  test('exactly enough funds is affordable', () {
    expect(calc(funds: 500).status, AffordabilityStatus.affordable);
  });

  test('not enough funds reports the shortfall', () {
    final result = calc(funds: 320);
    expect(result.status, AffordabilityStatus.insufficientFunds);
    expect(result.shortfall, 180);
  });

  test('a linked jar adds to the available funds', () {
    final result = calc(funds: 300, goalSaved: 200);
    expect(result.status, AffordabilityStatus.affordable);
    expect(result.coveredByGoal, isFalse);
  });

  test('a jar holding the full price is flagged as covering it', () {
    final result = calc(funds: 0, goalSaved: 600);
    expect(result.status, AffordabilityStatus.affordable);
    expect(result.coveredByGoal, isTrue);
  });

  test('enough money but over the category budget', () {
    final result = calc(budgetRemaining: 350);
    expect(result.status, AffordabilityStatus.overBudget);
    expect(result.shortfall, 150);
  });

  test('an already-exceeded budget counts the whole price as over', () {
    final result = calc(budgetRemaining: -40);
    expect(result.status, AffordabilityStatus.overBudget);
    expect(result.shortfall, 500);
  });

  test('missing funds wins over the budget check', () {
    expect(
      calc(funds: 100, budgetRemaining: 0).status,
      AffordabilityStatus.insufficientFunds,
    );
  });

  test('purchased items are just purchased', () {
    expect(
      calc(funds: 0, purchasedAt: DateTime(2026, 3)).status,
      AffordabilityStatus.purchased,
    );
  });
}
