import 'package:pocket_guard/domain/entities/transaction.dart';
import 'package:pocket_guard/domain/repositories/recurring_transaction_repository.dart';
import 'package:pocket_guard/domain/repositories/transaction_repository.dart';
import 'package:pocket_guard/domain/services/recurring_transaction_scheduler.dart';

class CatchUpSummary {
  final int generatedCount;
  final Set<String> touchedRuleIds;

  /// Rules where writing an occurrence failed. Each was advanced only past
  /// the occurrences that were actually written, so the next run retries
  /// from the one that failed.
  final Set<String> failedRuleIds;

  const CatchUpSummary({
    required this.generatedCount,
    required this.touchedRuleIds,
    this.failedRuleIds = const {},
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
    final failedRuleIds = <String>{};

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

      // The rule is advanced only past occurrences that were actually
      // written. If one fails, it stays due: advancing past it would lose
      // it for good, and not advancing at all would re-create the ones
      // before it (duplicates) on the next run.
      var written = 0;
      Object? failure;
      for (final occurrenceDate in result.occurrenceDates) {
        try {
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
        } catch (e) {
          failure = e;
          break;
        }
        written++;
      }
      generatedCount += written;

      final lastWritten = written > 0
          ? result.occurrenceDates[written - 1]
          : rule.lastGeneratedDate;
      await _recurringTransactionRepository.updateRecurringTransaction(
        rule.id,
        failure == null
            ? rule.copyWith(
                nextDueDate: result.newNextDueDate,
                lastGeneratedDate: lastWritten,
                isActive: !result.ruleShouldDeactivate,
              )
            : rule.copyWith(
                nextDueDate: result.occurrenceDates[written],
                lastGeneratedDate: lastWritten,
              ),
      );
      touchedRuleIds.add(rule.id);
      // Keep going: one rule's failure (e.g. a deleted category) shouldn't
      // stop every other rule from catching up.
      if (failure != null) failedRuleIds.add(rule.id);
    }

    return CatchUpSummary(
      generatedCount: generatedCount,
      touchedRuleIds: touchedRuleIds,
      failedRuleIds: failedRuleIds,
    );
  }
}
