import 'package:flutter/material.dart';

Color? themeColor = Colors.blue;

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorSchemeSeed: themeColor,
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorSchemeSeed: themeColor,
);

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightMode;

  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleMode() {
    themeData = themeData == lightMode ? darkMode : lightMode;
  }
}
