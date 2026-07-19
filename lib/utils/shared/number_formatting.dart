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

  /// Formats double to a compact version (e.g., $1.2M) without ISO codes
  static String formatCompactCurrency(double value, String currency) {
    final locale =
        _currencyLocales[currency.toUpperCase()] ?? const Locale('en', 'US');

    // 1. Get the symbol separately (e.g., "$")
    final symbol = NumberFormat.simpleCurrency(
      locale: locale.toString(),
      name: currency.toUpperCase(),
    ).currencySymbol;

    // 2. Use compactCurrency but pass the symbol and an empty name
    final compactFormat = NumberFormat.compactCurrency(
      locale: locale.toString(),
      symbol: symbol,
      decimalDigits: value.abs() < 1000 ? 0 : 1,
    );

    return compactFormat.format(value).trim();
  }

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

  /// Formats double to currency string with symbol ONLY (no account name)
  static String formatCurrencyWithSymbol(
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
      symbol: NumberFormat.currency(
        locale: locale.toString(),
        name: currency,
      ).currencySymbol,
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
  static double? parseUserInput(
    String input,
    String currency, {
    bool removeNegative = true,
  }) {
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
    if (removeNegative) {
      bool isNegative = cleaned.startsWith('-');
      if (isNegative) cleaned = cleaned.substring(1);
    }

    return double.tryParse(cleaned);
  }
}
