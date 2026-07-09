import 'package:flutter/material.dart';
import 'package:geoink/data/models/prefs_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme.g.dart';

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeMode build() {
    return PrefsState.themeMode ?? ThemeMode.system;
  }

  void toggleMode(BuildContext context) {
    if (state == ThemeMode.system) {
      state = Theme.of(context).brightness == Brightness.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    } else {
      state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    }
    PrefsState.themeMode = state;
  }

  bool isDark(BuildContext context) {
    return state == ThemeMode.system
        ? Theme.of(context).brightness == Brightness.dark
        : state == ThemeMode.dark;
  }
}
