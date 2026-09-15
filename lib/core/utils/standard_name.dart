import 'dart:io';

import 'package:geoink/data/models/flutter_map_entry.dart';

/// Max Number of charachters allowed in name
const int maxCharInName = 20;

String standardNamePatternWithLength(int? length, {bool onlyChar = true}) {
  String firstPart =
      r"^[ \t]*(?:(?<![ \t])((?:" +
      (onlyChar ? r"[\p{L}\p{Nd}_&()-]" : r"[^\n]") +
      r"|[ \t])";
  String secondPart = r"(?![ \t])))[ \t]*$";
  if (length == null) {
    return "$firstPart+$secondPart";
  }
  return firstPart + r"{0," + length.toString() + r"}" + secondPart;
}

const String invalidMessage =
    "Invalid name, only letters, numbers and _&()- are allowed";

/// Matches the name with any character but new line
/// Group 1 gets the name without surrounding spaces and tabs
final RegExp standardNameRegex = RegExp(
  standardNamePatternWithLength(maxCharInName),
  unicode: true,
);

String? processToStandardName(String value) {
  RegExpMatch? match = standardNameRegex.firstMatch(value);
  return match?.group(1);
}

String? standarNameValidatorForLayersDuplicateAllowed(String? value) {
  if (value == null) {
    return "Please enter a name";
  }
  var name = processToStandardName(value);
  if (name == null) {
    return invalidMessage;
  }
  return null;
}

String? standarNameValidatorForLayers(
  String? value,
  List<MapLayer> mapLayers, {
  bool duplicateAllowed = false,
}) {
  if (value == null) {
    return "Please enter a name";
  }
  var name = processToStandardName(value);
  if (name == null) {
    return invalidMessage;
  }
  if (!duplicateAllowed && mapLayers.any((e) => e.name == name)) {
    return "Duplicate name";
  }
  return null;
}

String? standarNameValidatorForEntries(
  String? value,
  List<FlutterMapEntry> mapEntries,
) {
  if (value == null) {
    return "Please enter a name";
  }
  var name = processToStandardName(value);
  if (name == null) {
    return invalidMessage;
  }
  if (mapEntries.any((e) => e.name == name)) {
    return "Duplicate name";
  }
  return null;
}

String? titleValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return "Please enter a name";
  }

  const Set<String> windowsReserved = {
    "CON",
    "PRN",
    "AUX",
    "NUL",
    "COM1",
    "COM2",
    "COM3",
    "COM4",
    "COM5",
    "COM6",
    "COM7",
    "COM8",
    "COM9",
    "LPT1",
    "LPT2",
    "LPT3",
    "LPT4",
    "LPT5",
    "LPT6",
    "LPT7",
    "LPT8",
    "LPT9",
  };

  if (Platform.isWindows && windowsReserved.contains(value)) {
    return "Windows reserved name";
  }

  const int maxFileNameLength = 255;
  var match = RegExp(
    standardNamePatternWithLength(maxFileNameLength),
    unicode: true,
  ).firstMatch(value);
  if (match?.group(1) == null) {
    return invalidMessage;
  }
  return null;
}
