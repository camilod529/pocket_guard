import 'package:pocket_guard/domain/entities/transaction.dart';
import 'package:pocket_guard/domain/repositories/recurring_transaction_repository.dart';
import 'package:pocket_guard/domain/repositories/transaction_repository.dart';
import 'package:pocket_guard/domain/services/recurring_transaction_scheduler.dart';

class CatchUpSummary {
  final int generatedCount;
  final Set<String> touchedRuleIds;

  const CatchUpSummary({
    required this.generatedCount,
    required this.touchedRuleIds,
  });
}

/// Shared core called by both the foreground (app-open) trigger and the
/// background isolate trigger - takes repository interfaces, not concrete
/// Drift classes, so it's constructible identically from a Riverpod-wired
/// provider or a manually-wired background callback with no ProviderScope.
class RecurringTransactionCatchUpService {
  RecurringTransactionCatchUpService({
    required RecurringTransactionRepository recurringTransactionRepository,
    required TransactionRepository transactionRepository,
  }) : _recurringTransactionRepository = recurringTransactionRepository,
       _transactionRepository = transactionRepository;

  final RecurringTransactionRepository _recurringTransactionRepository;
  final TransactionRepository _transactionRepository;

  Future<CatchUpSummary> run({required DateTime now}) async {
    final rules = await _recurringTransactionRepository
        .getAllRecurringTransactions();

    var generatedCount = 0;
    final touchedRuleIds = <String>{};

    for (final rule in rules.where((r) => r.isActive)) {
      final result = RecurringTransactionScheduler.occurrencesDue(
        startDate: rule.startDate,
        nextDueDate: rule.nextDueDate,
        frequency: rule.frequency,
        now: now,
        endDate: rule.endDate,
      );

      if (result.occurrenceDates.isEmpty && !result.ruleShouldDeactivate) {
        continue;
      }

      for (final occurrenceDate in result.occurrenceDates) {
        await _transactionRepository.createTransaction(
          TransactionEntity(
            id: 'unused',
            accountId: rule.accountId,
            toAccountId: rule.toAccountId,
            categoryId: rule.categoryId,
            amount: rule.amount,
            description: rule.description,
            date: occurrenceDate,
          ),
        );
        generatedCount++;
      }

      await _recurringTransactionRepository.updateRecurringTransaction(
        rule.id,
        rule.copyWith(
          nextDueDate: result.newNextDueDate,
          lastGeneratedDate: result.occurrenceDates.isNotEmpty
              ? result.occurrenceDates.last
              : rule.lastGeneratedDate,
          isActive: !result.ruleShouldDeactivate,
        ),
      );
      touchedRuleIds.add(rule.id);
    }

    return CatchUpSummary(
      generatedCount: generatedCount,
      touchedRuleIds: touchedRuleIds,
    );
  }
}
