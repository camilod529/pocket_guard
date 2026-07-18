// config/theme/app_theme.dart (updated with localized names)
import 'package:flutter/material.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';

const List<String> appColorKeys = [
  'indigo',
  'deepPurple',
  'blue',
  'purple',
  'yellow',
  'cyan',
  'teal',
  'lime',
];

const List<Color> appColors = [
  Colors.indigo,
  Colors.deepPurple,
  Colors.blue,
  Colors.purple,
  Colors.yellow,
  Colors.cyan,
  Colors.teal,
  Colors.lime,
];

class AppTheme {
  final int selectedColorIndex;

  const AppTheme({this.selectedColorIndex = 0})
    : assert(
        selectedColorIndex >= 0 && selectedColorIndex < appColors.length,
        'selectedColorIndex must be between 0 and ${appColors.length - 1}',
      );

  ThemeData get darkTheme => _commonTheme(brightness: Brightness.dark);
  ThemeData get lightTheme => _commonTheme(brightness: Brightness.light);

  ThemeData _commonTheme({Brightness brightness = Brightness.light}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: appColors[selectedColorIndex],
      brightness: brightness,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      brightness: brightness,
      appBarTheme: const AppBarTheme(centerTitle: true),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: _formFieldDecorationTheme(colorScheme),
      ),
    );
  }

  // Mirrors CustomFormField's per-instance InputDecoration recipe so every
  // form field - text or dropdown - looks and themes identically. Needed
  // because DropdownMenu resolves its decoration from
  // DropdownMenuThemeData.inputDecorationTheme, not the standard
  // ThemeData.inputDecorationTheme slot TextFormField uses.
  InputDecorationThemeData _formFieldDecorationTheme(ColorScheme colors) {
    final borderRadius = const BorderRadius.all(Radius.circular(12));

    return InputDecorationThemeData(
      filled: true,
      fillColor: colors.surfaceContainerHighest.withAlpha(77),
      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: colors.outline.withAlpha(128)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: colors.outline.withAlpha(128)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: colors.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: colors.error, width: 2),
      ),
      labelStyle: TextStyle(color: colors.onSurfaceVariant),
      hintStyle: TextStyle(color: colors.onSurfaceVariant.withAlpha(150)),
      errorStyle: TextStyle(
        color: colors.error,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  static String getColorName(BuildContext context, int index) {
    final localizations = AppLocalizations.of(context)!;
    switch (appColorKeys[index]) {
      case 'indigo':
        return localizations.indigo;
      case 'deepPurple':
        return localizations.deepPurple;
      case 'blue':
        return localizations.blue;
      case 'purple':
        return localizations.purple;
      case 'yellow':
        return localizations.yellow;
      case 'cyan':
        return localizations.cyan;
      case 'teal':
        return localizations.teal;
      case 'lime':
        return localizations.lime;
      default:
        return 'Color';
    }
  }
}
