import 'package:flutter/material.dart';

extension ColorExtension on Color {
  Color invert() => Color.from(alpha: a, red: 1 - r, green: 1 - g, blue: 1 - b);

  Color toGrayscale() {
    final double luminance = computeLuminance();
    return Color.from(
      alpha: a,
      red: luminance,
      green: luminance,
      blue: luminance,
    );
  }

  Color withLightness(double brightness) {
    return HSLColor.fromColor(Colors.black).withLightness(brightness).toColor();
  }

  Color onColorWithColors(Color colorBlack, Color colorWhite) {
    return computeLuminance() > 0.5 ? colorBlack : colorWhite;
  }

  Color onColor() => onColorWithColors(Colors.black, Colors.white);
}
