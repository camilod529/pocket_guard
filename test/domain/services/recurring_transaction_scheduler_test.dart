import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_guard/domain/entities/recurring_transaction.dart';
import 'package:pocket_guard/domain/services/recurring_transaction_scheduler.dart';

void main() {
  group('occurrencesDue', () {
    test('not yet due returns no occurrences and keeps nextDueDate', () {
      final result = RecurringTransactionScheduler.occurrencesDue(
        startDate: DateTime(2026, 1, 1),
        nextDueDate: DateTime(2026, 2, 1),
        frequency: RecurrenceFrequency.monthly,
        now: DateTime(2026, 1, 15),
      );

      expect(result.occurrenceDates, isEmpty);
      expect(result.newNextDueDate, DateTime(2026, 2, 1));
      expect(result.ruleShouldDeactivate, isFalse);
    });

    test('due exactly today generates one occurrence and advances by one period', () {
      final result = RecurringTransactionScheduler.occurrencesDue(
        startDate: DateTime(2026, 1, 1),
        nextDueDate: DateTime(2026, 2, 1),
        frequency: RecurrenceFrequency.monthly,
        now: DateTime(2026, 2, 1),
      );

      expect(result.occurrenceDates, [DateTime(2026, 2, 1)]);
      expect(result.newNextDueDate, DateTime(2026, 3, 1));
    });

    test('3 months overdue monthly rule backfills exactly 3 occurrences at correct dates', () {
      final result = RecurringTransactionScheduler.occurrencesDue(
        startDate: DateTime(2026, 1, 15),
        nextDueDate: DateTime(2026, 1, 15),
        frequency: RecurrenceFrequency.monthly,
        // One day short of the 4th occurrence so exactly 3 are due.
        now: DateTime(2026, 4, 14),
      );

      expect(result.occurrenceDates, [
        DateTime(2026, 1, 15),
        DateTime(2026, 2, 15),
        DateTime(2026, 3, 15),
      ]);
      expect(result.newNextDueDate, DateTime(2026, 4, 15));
      expect(result.ruleShouldDeactivate, isFalse);
    });

    test('weekly frequency steps by exactly 7 days', () {
      final result = RecurringTransactionScheduler.occurrencesDue(
        startDate: DateTime(2026, 1, 1),
        nextDueDate: DateTime(2026, 1, 1),
        frequency: RecurrenceFrequency.weekly,
        now: DateTime(2026, 1, 22),
      );

      expect(result.occurrenceDates, [
        DateTime(2026, 1, 1),
        DateTime(2026, 1, 8),
        DateTime(2026, 1, 15),
        DateTime(2026, 1, 22),
      ]);
      expect(result.newNextDueDate, DateTime(2026, 1, 29));
    });

    test('yearly frequency steps by exactly 12 months, preserving month and day', () {
      final result = RecurringTransactionScheduler.occurrencesDue(
        startDate: DateTime(2024, 3, 10),
        nextDueDate: DateTime(2026, 3, 10),
        frequency: RecurrenceFrequency.yearly,
        now: DateTime(2026, 3, 10),
      );

      expect(result.occurrenceDates, [DateTime(2026, 3, 10)]);
      expect(result.newNextDueDate, DateTime(2027, 3, 10));
    });

    test('month-end clamping: Jan 31 monthly lands on Feb 28 (non-leap year), then back on Mar 31', () {
      // 2026 is not a leap year.
      final first = RecurringTransactionScheduler.occurrencesDue(
        startDate: DateTime(2026, 1, 31),
        nextDueDate: DateTime(2026, 1, 31),
        frequency: RecurrenceFrequency.monthly,
        now: DateTime(2026, 1, 31),
      );
      expect(first.newNextDueDate, DateTime(2026, 2, 28));

      final second = RecurringTransactionScheduler.occurrencesDue(
        startDate: DateTime(2026, 1, 31),
        nextDueDate: first.newNextDueDate,
        frequency: RecurrenceFrequency.monthly,
        now: DateTime(2026, 2, 28),
      );
      expect(second.occurrenceDates, [DateTime(2026, 2, 28)]);
      // Must go back to the original anchor day (31), not stay clamped at 28.
      expect(second.newNextDueDate, DateTime(2026, 3, 31));
    });

    test('month-end clamping handles a leap year February correctly', () {
      // 2028 is a leap year.
      final result = RecurringTransactionScheduler.occurrencesDue(
        startDate: DateTime(2028, 1, 31),
        nextDueDate: DateTime(2028, 1, 31),
        frequency: RecurrenceFrequency.monthly,
        now: DateTime(2028, 1, 31),
      );

      expect(result.newNextDueDate, DateTime(2028, 2, 29));
    });

    test('backfill cap stops recording at maxBackfill but still fast-forwards nextDueDate past now', () {
      final result = RecurringTransactionScheduler.occurrencesDue(
        startDate: DateTime(2020, 1, 1),
        nextDueDate: DateTime(2020, 1, 1),
        frequency: RecurrenceFrequency.monthly,
        now: DateTime(2026, 1, 1), // 72 months overdue
        maxBackfill: 24,
      );

      expect(result.occurrenceDates, hasLength(24));
      expect(result.occurrenceDates.first, DateTime(2020, 1, 1));
      expect(result.occurrenceDates.last, DateTime(2021, 12, 1));
      // nextDueDate must be fast-forwarded to the first still-future
      // occurrence after `now`, not stuck replaying the whole backlog.
      expect(result.newNextDueDate.isAfter(DateTime(2026, 1, 1)), isTrue);
      expect(result.ruleShouldDeactivate, isFalse);
    });

    test('endDate already passed stops occurrences at endDate and deactivates the rule', () {
      final result = RecurringTransactionScheduler.occurrencesDue(
        startDate: DateTime(2026, 1, 1),
        nextDueDate: DateTime(2026, 1, 1),
        frequency: RecurrenceFrequency.monthly,
        now: DateTime(2026, 6, 1),
        endDate: DateTime(2026, 3, 1),
      );

      expect(result.occurrenceDates, [
        DateTime(2026, 1, 1),
        DateTime(2026, 2, 1),
        DateTime(2026, 3, 1),
      ]);
      expect(result.ruleShouldDeactivate, isTrue);
    });

    test('endDate in the future does not deactivate and does not truncate occurrences', () {
      final result = RecurringTransactionScheduler.occurrencesDue(
        startDate: DateTime(2026, 1, 1),
        nextDueDate: DateTime(2026, 1, 1),
        frequency: RecurrenceFrequency.monthly,
        now: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 12, 1),
      );

      expect(result.occurrenceDates, [
        DateTime(2026, 1, 1),
        DateTime(2026, 2, 1),
      ]);
      expect(result.ruleShouldDeactivate, isFalse);
    });
  });
}
