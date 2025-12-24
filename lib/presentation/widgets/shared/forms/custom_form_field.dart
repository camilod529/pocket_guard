import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomFormField extends ConsumerWidget {
  final String label;
  final String? hintText;
  final String? helperText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? initialValue;
  final TextEditingController? controller;
  final String? errorText;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final bool enableSuggestions;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final int? minLines;
  final bool readOnly;
  const CustomFormField({
    super.key,
    required this.label,
    this.readOnly = false,
    this.inputFormatters,
    this.hintText,
    this.controller,
    this.errorText,
    this.initialValue,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.validator,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = false,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Determine error state

    return TextFormField(
      initialValue: initialValue,
      onChanged: (value) {
        onChanged?.call(value);
      },
      controller: controller,
      readOnly: readOnly,
      inputFormatters: inputFormatters,
      validator: validator,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      maxLines: maxLines,
      minLines: minLines ?? maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        helperText: helperText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        errorText: errorText,
        errorStyle: TextStyle(
          color: colors.error,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelStyle: TextStyle(
          color: errorText != null ? colors.error : colors.onSurfaceVariant,
        ),
        hintStyle: TextStyle(color: colors.onSurfaceVariant.withAlpha(150)),
        filled: true,
        fillColor: colors.surfaceContainerHighest.withAlpha(77),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.outline.withAlpha(128)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.outline.withAlpha(128)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
