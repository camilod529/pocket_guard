import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/domain/entities/goal_contribution.dart';
import 'package:pocket_guard/domain/entities/transaction.dart';
import 'package:pocket_guard/domain/services/balance_trend_calculator.dart';

void main() {
  final march = DateTime(2026, 3);

  group('dailyBalances', () {
    test('no changes is a flat line at the current balance', () {
      final balances = BalanceTrendCalculator.dailyBalances(
        month: march,
        currentBalance: 500,
        changes: const [],
      );

      expect(balances, hasLength(31));
      expect(balances.toSet(), {500});
    });

    test('works back from the current balance, counting a change on the '
        'day it happened', () {
      // Started March at 1000: -100 on the 5th, +50 on the 10th -> 950 now.
      final balances = BalanceTrendCalculator.dailyBalances(
        month: march,
        currentBalance: 950,
        changes: [
          BalanceChange(DateTime(2026, 3, 5, 14), -100),
          BalanceChange(DateTime(2026, 3, 10, 9), 50),
        ],
      );

      expect(balances[0], 1000); // 1st
      expect(balances[3], 1000); // 4th
      expect(balances[4], 900); // 5th - end of day includes that change
      expect(balances[8], 900); // 9th
      expect(balances[9], 950); // 10th
      expect(balances[30], 950); // 31st
    });

    test('changes after the month (even future-dated ones) are backed out '
        'of every day in it', () {
      final balances = BalanceTrendCalculator.dailyBalances(
        month: march,
        currentBalance: 700,
        changes: [BalanceChange(DateTime(2026, 4, 2), -300)],
      );

      expect(balances.toSet(), {1000});
    });

    test('a change at midnight on the 1st of next month belongs to next '
        'month', () {
      final balances = BalanceTrendCalculator.dailyBalances(
        month: march,
        currentBalance: 0,
        changes: [BalanceChange(DateTime(2026, 4), -10)],
      );

      expect(balances.last, 10);
    });
  });

  group('transactionDelta', () {
    TransactionEntity tx({String from = 'a', String? to}) => TransactionEntity(
      id: 'tx',
      amount: 40,
      description: null,
      categoryId: 'c',
      date: march,
      accountId: from,
      toAccountId: to,
    );

    test('income adds, expense subtracts, only for charted accounts', () {
      final charted = {'a'};
      expect(
        BalanceTrendCalculator.transactionDelta(
          tx(),
          TransactionType.income,
          charted,
        ),
        40,
      );
      expect(
        BalanceTrendCalculator.transactionDelta(
          tx(),
          TransactionType.expense,
          charted,
        ),
        -40,
      );
      expect(
        BalanceTrendCalculator.transactionDelta(
          tx(from: 'other'),
          TransactionType.expense,
          charted,
        ),
        0,
      );
    });

    test('a transfer leaves the source and arrives at the destination', () {
      expect(
        BalanceTrendCalculator.transactionDelta(
          tx(to: 'b'),
          TransactionType.transfer,
          {'a'},
        ),
        -40,
      );
      expect(
        BalanceTrendCalculator.transactionDelta(
          tx(to: 'b'),
          TransactionType.transfer,
          {'b'},
        ),
        40,
      );
      // Both charted (e.g. "all accounts"): money just moved within.
      expect(
        BalanceTrendCalculator.transactionDelta(
          tx(to: 'b'),
          TransactionType.transfer,
          {'a', 'b'},
        ),
        0,
      );
    });
  });

  test('a goal deposit leaves the account, a withdrawal returns', () {
    GoalContributionEntity c(double amount) => GoalContributionEntity(
      id: 'c',
      goalId: 'g',
      accountId: 'a',
      amount: amount,
      date: march,
    );

    expect(BalanceTrendCalculator.contributionDelta(c(300), {'a'}), -300);
    expect(BalanceTrendCalculator.contributionDelta(c(-100), {'a'}), 100);
    expect(BalanceTrendCalculator.contributionDelta(c(300), {'other'}), 0);
  });
}
