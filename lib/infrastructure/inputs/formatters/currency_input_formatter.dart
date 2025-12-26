import 'package:flutter/services.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;

    // Block if more than 2 decimals or invalid pattern
    if (!_isValidInput(newText)) {
      return oldValue;
    }

    return newValue;
  }

  bool _isValidInput(String text) {
    if (text.isEmpty) return true;

    final regex = RegExp(r'^-?\d*\.?\d{0,2}$');
    return regex.hasMatch(text);
  }
}
