import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

ThemeMode? themeModeFromString(String? value) {
  return value == null
      ? null
      : ThemeMode.values.firstWhereOrNull((e) => e.name == value);
}

ThemeMode themeModeFromBrightness(Brightness brightness) {
  return brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
}
