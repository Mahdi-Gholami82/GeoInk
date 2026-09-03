import 'package:geoink/data/models/flutter_map_entry.dart';

/// Max Number of charachters allowed in name
const int maxCharInName = 20;

/// Matches only part of the name (20 charachters max)
// We probably dont want the name to be too long
final String standardNamePartialPattern =
    r"^[ \t]*(?:(?<!=[ \t])((?:[^\n]|[ \t]){0," +
    maxCharInName.toString() +
    r"}(?!=[ \t])))";

/// Matches only part of the name (20 charachters max)
/// Group 1 gets the name without surrounding spaces and tabs
final RegExp standardNamePartialRegex = RegExp(
  standardNamePartialPattern,
  unicode: true,
);

/// Matches the name with any character but new line
/// Group 1 gets the name without surrounding spaces and tabs
final RegExp standardNameRegex = RegExp(
  standardNamePartialPattern + r"[ \t]*$",
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
    return "Invalid name";
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
    return "Invalid name";
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
    return "Invalid name";
  }
  if (mapEntries.any((e) => e.name == name)) {
    return "Duplicate name";
  }
  return null;
}
