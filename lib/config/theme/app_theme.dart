import 'package:flutter/material.dart';

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
      appBarTheme: AppBarTheme(centerTitle: true),
    );
  }
}
