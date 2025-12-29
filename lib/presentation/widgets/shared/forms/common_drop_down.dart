import 'package:flutter/material.dart';

class DropdownDecorationHelper {
  static InputDecoration getDecoration({
    required String hintText,
    required Icon prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    );
  }
}
