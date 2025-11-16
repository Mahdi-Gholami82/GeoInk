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
