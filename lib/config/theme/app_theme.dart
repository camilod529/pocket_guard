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
    return ThemeData(
      colorSchemeSeed: appColors[selectedColorIndex],
      useMaterial3: true,
      brightness: brightness,
      appBarTheme: const AppBarTheme(centerTitle: true),
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
