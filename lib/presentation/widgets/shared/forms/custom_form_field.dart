import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomFormField extends StatefulWidget {
  final String label;
  final String? hintText;
  final String? helperText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? initialValue;
  final TextEditingController? controller;
  final String? errorText;
  final void Function(String value)? onChanged;
  final String? Function(String? value)? validator;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final bool enableSuggestions;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final int? minLines;
  final bool readOnly;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;

  /// When true, tapping into the field selects its entire current value so
  /// the first keystroke replaces it instead of appending to it. Meant for
  /// money fields, which are pre-filled with a formatted value (e.g.
  /// "0.00", or the real amount on edit) - appending past an already-full
  /// value (2 decimal digits) gets silently rejected by currency input
  /// formatters, which otherwise makes typing look inert until the user
  /// manually deletes characters first.
  final bool selectAllOnFocus;

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
    this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.selectAllOnFocus = false,
  });

  @override
  State<CustomFormField> createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends State<CustomFormField> {
  TextEditingController? _controller;
  FocusNode? _focusNode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return TextFormField(
      initialValue: widget.selectAllOnFocus ? null : widget.initialValue,
      onChanged: (value) {
        widget.onChanged?.call(value);
      },
      onTap: widget.onTap,
      controller: widget.selectAllOnFocus ? _controller : widget.controller,
      focusNode: widget.selectAllOnFocus ? _focusNode : null,
      readOnly: widget.readOnly,
      inputFormatters: widget.inputFormatters,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      maxLines: widget.maxLines,
      minLines: widget.minLines ?? widget.maxLines,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        helperText: widget.helperText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        errorText: widget.errorText,
        errorStyle: TextStyle(
          color: colors.error,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelStyle: TextStyle(
          color: widget.errorText != null
              ? colors.error
              : colors.onSurfaceVariant,
        ),
        hintStyle: TextStyle(color: colors.onSurfaceVariant.withAlpha(150)),
        filled: true,
        fillColor: colors.surfaceContainerHighest.withAlpha(77),
        border: OutlineInputBorder(
          borderRadius: widget.borderRadius,
          borderSide: BorderSide(color: colors.outline.withAlpha(128)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: widget.borderRadius,
          borderSide: BorderSide(color: colors.outline.withAlpha(128)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: widget.borderRadius,
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: widget.borderRadius,
          borderSide: BorderSide(color: colors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: widget.borderRadius,
          borderSide: BorderSide(color: colors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    if (widget.controller == null) {
      _controller?.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.selectAllOnFocus) {
      _controller =
          widget.controller ?? TextEditingController(text: widget.initialValue);
      _focusNode = FocusNode()
        ..addListener(() {
          if (_focusNode!.hasFocus) {
            _controller!.selection = TextSelection(
              baseOffset: 0,
              extentOffset: _controller!.text.length,
            );
          }
        });
    }
  }
}
