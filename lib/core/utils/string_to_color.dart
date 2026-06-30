import 'dart:ui';

Color? stringToColor(String? text) {
  if (text == null) return null;
  text = text.trim();
  if (RegExp(
    r"^#?(?:[0-9A-F]{8}|[0-9A-F]{6})$",
    caseSensitive: false,
  ).hasMatch(text)) {
    text = text.replaceFirst("#", "").toUpperCase();
    return Color(int.parse("0x${text.length == 6 ? "88$text" : text}"));
  }
  return null;
}