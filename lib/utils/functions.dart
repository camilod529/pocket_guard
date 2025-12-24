DateTime getEndOfMonth(DateTime date) {
  return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999, 999);
}

DateTime getStartOfMonth(DateTime date) {
  return DateTime(date.year, date.month, 1);
}
