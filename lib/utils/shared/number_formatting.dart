import 'dart:ui';

import 'package:intl/intl.dart';

class NumberFormatting {
  static final Map<String, Locale> _currencyLocales = {
    'USD': const Locale('en', 'US'),
    'EUR': const Locale('de', 'DE'),
    'GBP': const Locale('en', 'GB'),
    'JPY': const Locale('ja', 'JP'),
    'CAD': const Locale('en', 'CA'),
    'AUD': const Locale('en', 'AU'),
    'CHF': const Locale('de', 'CH'),
    'MXN': const Locale('es', 'MX'),
    'BRL': const Locale('pt', 'BR'),
    'COP': const Locale('es', 'CO'),
  };

  /// Formats double to currency string with proper locale
  static String formatCurrency(
    double value,
    String currency, {
    int decimalDigits = 2,
  }) {
    final locale =
        _currencyLocales[currency.toUpperCase()] ?? const Locale('en', 'US');
    final numberFormat = NumberFormat.currency(
      locale: locale.toString(),
      name: currency,
      decimalDigits: decimalDigits,
    );
    return numberFormat.format(value);
  }

  /// Formats double to simple number string (no currency symbol)
  static String formatNumber(double value, {int decimalDigits = 2}) {
    final locale = const Locale('en', 'US');
    final numberFormat = NumberFormat.decimalPattern(locale.toString())
      ..maximumFractionDigits = decimalDigits
      ..minimumFractionDigits = decimalDigits;
    return numberFormat.format(value);
  }

  /// Parses user input string to double, handling locale-specific formats
  static double? parseUserInput(String input, String currency) {
    if (input.isEmpty) return null;

    // Clean input: remove currency symbols, spaces, thousands separators
    String cleaned = input
        .replaceAll(
          RegExp(r'[^\d.,\-]'),
          '',
        ) // Remove everything except digits, dot, comma, minus
        .replaceAll(',', '') // Remove commas (thousands separators)
        .trim();

    // Handle negative numbers
    bool isNegative = cleaned.startsWith('-');
    if (isNegative) cleaned = cleaned.substring(1);

    return double.tryParse(cleaned);
  }
}
