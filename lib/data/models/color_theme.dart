import 'package:flex_color_scheme/flex_color_scheme.dart';

enum ColorTheme {
  orange("Orange", FlexScheme.shadOrange),
  blue("Blue", FlexScheme.shadBlue),
  green("Green", FlexScheme.shadGreen),
  red("Red", FlexScheme.shadRed),
  rose("Rose", FlexScheme.shadRose),
  violet("Violet", FlexScheme.shadViolet),
  yellow("Yellow", FlexScheme.shadYellow);

  const ColorTheme(this.name, this.scheme);
  final String name;
  final FlexScheme scheme;

  static ColorTheme fromString(String themeName) {
    return ColorTheme.values.firstWhere(
      (theme) => theme.name.toLowerCase() == themeName.toLowerCase(),
      orElse: () => ColorTheme.orange,
    );
  }
}
