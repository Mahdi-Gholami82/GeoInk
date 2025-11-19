import 'package:flutter/material.dart';
import 'package:mapify/core/theme/theme.dart';

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
