import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarDateFormatter {
  final Locale locale;

  const CalendarDateFormatter(this.locale);

  /// Full date for accessibility/debugging
  String formatFullDate(DateTime date) {
    return DateFormat.yMMMd(locale.toString()).format(date);
  }

  /// Month and year for AppBar title (e.g. "January 2025" / "enero 2025")
  String formatMonthYear(DateTime date) {
    return DateFormat.yMMMM(locale.toString()).format(date);
  }

  /// Short date for empty state (e.g. "Jan 5" / "5 ene")
  String formatShortDate(DateTime date) {
    return DateFormat.MMMd(locale.toString()).format(date);
  }

  /// Time for transaction list (e.g. "2:30 PM" / "14:30")
  String formatTime(DateTime date) {
    return DateFormat.jm(locale.toString()).format(date);
  }
}
