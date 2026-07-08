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
