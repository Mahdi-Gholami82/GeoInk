import 'package:flutter/material.dart';
import 'package:geoink/core/utils/theme_tools.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsState {
  static late final SharedPreferences instance;

  static Future<void> init() async {
    instance = await SharedPreferences.getInstance();
  }

  static ThemeMode? get themeMode =>
      themeModeFromString(instance.getString("themeMode"));

  static set themeMode(ThemeMode value) {
    instance.setString("themeMode", value.name);
  }
}
