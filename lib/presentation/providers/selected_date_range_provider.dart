import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_date_range_provider.g.dart';

class DateRangeSelection {
  final DateTime start; // For fetching DB data (Month start)
  final DateTime end; // For fetching DB data (Month end)
  final DateTime selectedDay; // For the FAB and filtering the list
  final DateRangeType type;

  const DateRangeSelection({
    required this.start,
    required this.end,
    required this.selectedDay, // Add this
    required this.type,
  });

  DateRangeSelection copyWith({
    DateTime? start,
    DateTime? end,
    DateTime? selectedDay,
    DateRangeType? type,
  }) {
    return DateRangeSelection(
      start: start ?? this.start,
      end: end ?? this.end,
      selectedDay: selectedDay ?? this.selectedDay,
      type: type ?? this.type,
    );
  }
}

enum DateRangeType { day, month, year, custom }

@riverpod
class SelectedDateRange extends _$SelectedDateRange {
  @override
  DateRangeSelection build() {
    final now = DateTime.now();
    return DateRangeSelection(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
      selectedDay: now, // Initialize to today
      type: DateRangeType.month,
    );
  }

  void selectCustomRange(DateTime start, DateTime end) {
    state = state.copyWith(start: start, end: end, type: DateRangeType.custom);
  }

  // Only updates the pointer, doesn't change the fetch range
  void selectDay(DateTime day) {
    state = state.copyWith(selectedDay: day);
  }

  // Updates the range but keeps the day (unless the day is out of range)
  void selectMonth(int year, int month) {
    state = state.copyWith(
      start: DateTime(year, month, 1),
      end: DateTime(year, month + 1, 0, 23, 59, 59),
      type: DateRangeType.month,
    );
  }

  void selectYear(int year) {
    state = state.copyWith(
      start: DateTime(year, 1, 1),
      end: DateTime(year, 12, 31, 23, 59, 59),
      type: DateRangeType.year,
    );
  }
}
