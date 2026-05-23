import 'package:flutter/material.dart';
import 'package:GeoInk/core/theme/theme.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeData build() {
    return lightMode;
  }

  void toggleMode() {
    state = state == lightMode ? darkMode : lightMode;
  }
}
