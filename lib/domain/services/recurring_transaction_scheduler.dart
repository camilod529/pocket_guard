import 'package:pocket_guard/domain/entities/recurring_transaction.dart';

class RecurringOccurrenceResult {
  final List<DateTime> occurrenceDates;
  final DateTime newNextDueDate;
  final bool ruleShouldDeactivate;

  const RecurringOccurrenceResult({
    required this.occurrenceDates,
    required this.newNextDueDate,
    required this.ruleShouldDeactivate,
  });
}

/// Pure date math for recurring-transaction generation - no DB/Riverpod
/// dependency, so it's usable identically from the foreground (app-open)
/// trigger and the background isolate trigger.
class RecurringTransactionScheduler {
  static RecurringOccurrenceResult occurrencesDue({
    required DateTime startDate,
    required DateTime nextDueDate,
    required RecurrenceFrequency frequency,
    required DateTime now,
    DateTime? endDate,
    int maxBackfill = 24,
  }) {
    // Bound generation at endDate if it has already passed - occurrences
    // after it should never be created, whether or not now is much later.
    final effectiveNow = (endDate != null && endDate.isBefore(now))
        ? endDate
        : now;

    final occurrences = <DateTime>[];
    var cursor = nextDueDate;

    while (!cursor.isAfter(effectiveNow)) {
      // Keep advancing cursor past every due date regardless of the cap, so
      // newNextDueDate always ends up in the future - only recording stops
      // at maxBackfill, so a rule that's been overdue for years doesn't get
      // stuck replaying its entire backlog on every future run.
      if (occurrences.length < maxBackfill) {
        occurrences.add(cursor);
      }
      cursor = _advance(cursor, frequency, startDate);
    }

    return RecurringOccurrenceResult(
      occurrenceDates: occurrences,
      newNextDueDate: cursor,
      ruleShouldDeactivate: endDate != null && !endDate.isAfter(now),
    );
  }

  static DateTime _advance(
    DateTime date,
    RecurrenceFrequency frequency,
    DateTime anchor,
  ) {
    switch (frequency) {
      case RecurrenceFrequency.daily:
        return date.add(const Duration(days: 1));
      case RecurrenceFrequency.weekly:
        return date.add(const Duration(days: 7));
      case RecurrenceFrequency.monthly:
        return _addMonths(date, 1, anchorDay: anchor.day);
      case RecurrenceFrequency.yearly:
        return _addMonths(date, 12, anchorDay: anchor.day);
    }
  }

  /// Adds [months] to [date], keeping the day-of-month anchored to
  /// [anchorDay] (the rule's original startDate.day) rather than [date]'s
  /// own day - clamped to whatever the target month actually has, and never
  /// compounding a previous clamp forward. This is what makes a Jan 31
  /// monthly rule land on Feb 28/29, then correctly back on Mar 31 rather
  /// than staying stuck at 28 - Dart's plain DateTime(year, month, day)
  /// silently rolls an invalid day into the next month instead of clamping,
  /// which is the bug this exists to avoid.
  static DateTime _addMonths(DateTime date, int months, {required int anchorDay}) {
    final totalMonths = date.year * 12 + (date.month - 1) + months;
    final year = totalMonths ~/ 12;
    final month = totalMonths % 12 + 1;
    final day = anchorDay > _daysInMonth(year, month)
        ? _daysInMonth(year, month)
        : anchorDay;

    return DateTime(
      year,
      month,
      day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }

  static int _daysInMonth(int year, int month) {
    final firstOfNextMonth = month == 12
        ? DateTime(year + 1, 1, 1)
        : DateTime(year, month + 1, 1);
    return firstOfNextMonth.subtract(const Duration(days: 1)).day;
  }
}
