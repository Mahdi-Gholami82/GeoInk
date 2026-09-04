import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geoink/data/models/color_theme.dart';
import 'package:geoink/data/models/prefs_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme.g.dart';

ThemeData getDarkTheme(ColorTheme color) {
  return FlexThemeData.dark(
    scheme: color.scheme,
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      blendOnColors: true,
      useM2StyleDividerInM3: true,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      alignedDropdown: true,
      navigationRailUseIndicator: true,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );
}

ThemeData getLightTheme(ColorTheme color) {
  return FlexThemeData.light(
    scheme: color.scheme,
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      useM2StyleDividerInM3: true,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      alignedDropdown: true,
      navigationRailUseIndicator: true,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );
}

class ThemeState {
  ThemeState({
    required this.mode,
    required this.color,
    required this.dark,
    required this.light,
  });

  ThemeState.fromColorTheme({required this.mode, required this.color})
    : dark = getDarkTheme(color),
      light = getLightTheme(color);

  ThemeMode mode;
  ColorTheme color;
  ThemeData light;
  ThemeData dark;

  void setByColorTheme(ColorTheme newColor) {
    color = newColor;
    dark = getDarkTheme(newColor);
    light = getLightTheme(newColor);
  }

  ThemeState copy() {
    return ThemeState(mode: mode, color: color, dark: dark, light: light);
  }

  bool isDark(BuildContext context) {
    return mode == ThemeMode.system
        ? Theme.of(context).brightness == Brightness.dark
        : mode == ThemeMode.dark;
  }
}

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  void forceRebuild() {
    state = state.copy();
  }

  @override
  ThemeState build() {
    var colorTheme = PrefsState.colorTheme;
    return ThemeState.fromColorTheme(
      mode: PrefsState.themeMode,
      color: colorTheme,
    );
  }

  void changeColor(ColorTheme newColor) {
    state.setByColorTheme(newColor);
    PrefsState.colorTheme = newColor;
    forceRebuild();
  }

  void toggleMode(BuildContext context) {
    if (state.mode == ThemeMode.system) {
      state.mode = Theme.of(context).brightness == Brightness.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    } else {
      state.mode = state.mode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    }
    PrefsState.themeMode = state.mode;
    forceRebuild();
  }
}
