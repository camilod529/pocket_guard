import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_date_range_provider.g.dart';

class DateRangeSelection {
  final DateTime start;
  final DateTime end;
  final DateRangeType type;

  const DateRangeSelection({
    required this.start,
    required this.end,
    required this.type,
  });

  DateRangeSelection copyWith({
    DateTime? start,
    DateTime? end,
    DateRangeType? type,
  }) {
    return DateRangeSelection(
      start: start ?? this.start,
      end: end ?? this.end,
      type: type ?? this.type,
    );
  }
}

enum DateRangeType { day, month, year, custom }

@riverpod
class SelectedDateRange extends _$SelectedDateRange {
  @override
  DateRangeSelection build() {
    // Default to current month
    final now = DateTime.now();
    return DateRangeSelection(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
      type: DateRangeType.month,
    );
  }

  void selectCustomRange(DateTime start, DateTime end) {
    state = DateRangeSelection(
      start: start,
      end: end,
      type: DateRangeType.custom,
    );
  }

  void selectDay(DateTime day) {
    state = DateRangeSelection(
      start: DateTime(day.year, day.month, day.day),
      end: DateTime(day.year, day.month, day.day, 23, 59, 59),
      type: DateRangeType.day,
    );
  }

  void selectMonth(int year, int month) {
    state = DateRangeSelection(
      start: DateTime(year, month, 1),
      end: DateTime(year, month + 1, 0, 23, 59, 59),
      type: DateRangeType.month,
    );
  }

  void selectYear(int year) {
    state = DateRangeSelection(
      start: DateTime(year, 1, 1),
      end: DateTime(year, 12, 31, 23, 59, 59),
      type: DateRangeType.year,
    );
  }
}
