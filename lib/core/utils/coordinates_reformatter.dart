// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:latlong2/latlong.dart';

enum CoordinatesFormatTypes {
  /// Decimal degrees
  /// Example: 51.5074, -0.1278
  decimalDegrees,

  /// Decimal degrees with hemisphere
  /// Example: 51.5074N 0.1278W
  decimalDegreesHemisphere,

  /// Degrees + decimal minutes (symbolic)
  /// Example: 51°23.45'N 004°12.34'E
  degreesDecimalMinutesSymbolic,

  /// Degrees + decimal minutes (compact aviation)
  /// Example: 5123.45N 00412.34E
  degreesDecimalMinutesCompact,

  /// Degrees + minutes + seconds (symbolic)
  /// Example: 51°30'26"N 004°12'10"E
  degreesMinutesSeconds,

  /// Degrees + minutes + seconds (compact)
  /// Example: 513026N 0041210E
  degreesMinutesSecondsCompact,

  /// NOTAM DDMM (compact)
  /// Example: 5123N00412E
  notamCompactDDMM,

  /// NOTAM DDMMSS (compact)
  /// Example: 512345N0041234E
  notamCompactDDMMSS,
}

enum LatOrLong { lat, long }

enum LeadingOrTrailing { leading, trailing }

const String leadingLat = r"(?:(?<northOrSouth_leading_LAT>[NS])\s*)";
const String trailingLat = r"(?:\s*(?<northOrSouth_trailing_LAT>[NS]))";
const String leadingLong = r"(?:(?<eastOrWest_leading_LONG>[EW])\s*)";
const String trailingLong = r"(?:\s*(?<eastOrWest_trailing_LONG>[EW]))";
const String defaultSeperatorPattern =
    r"(?:(?:\s{0,3},\s{0,3}|\s)|(?<=[NWES])|(?=[NWES]))";
const String defaultSeperatorPatternNonEmpty = r"(?:(?:\s{0,3},\s{0,3}|\s))";

const String _coordinateMainGroupNamePostFix =
    r"_(?<LatOrLong>(?:LAT|LONG))(?:_(?<LeadingOrTrailing>TD|LD))?";
final RegExp coordinateMainGroupNameParser = RegExp(
  "^<?(?<type>${CoordinatesFormatTypes.values.asNameMap().keys.join("|")})" +
      _coordinateMainGroupNamePostFix +
      r">?$",
);

/// Predefined matchers for various coordinate formats.
Map<CoordinatesFormatTypes, CoordinatesMatcher> matchers = {
  CoordinatesFormatTypes.notamCompactDDMMSS: CoordinatesMatcher(
    latPattern: r"(?<degrees>\d{2})(?<minutes>\d{2})(?<seconds>\d{2})",
    longPattern: r"(?<degrees>\d{3})(?<minutes>\d{2})(?<seconds>\d{2})",
    isDirectional: true,
    formatType: CoordinatesFormatTypes.notamCompactDDMMSS,
  ),
  CoordinatesFormatTypes.notamCompactDDMM: CoordinatesMatcher(
    latPattern: r"(?<degrees>\d{2})(?<minutes>\d{2})",
    longPattern: r"(?<degrees>\d{3})(?<minutes>\d{2})",
    isDirectional: true,
    formatType: CoordinatesFormatTypes.notamCompactDDMM,
  ),
  CoordinatesFormatTypes.degreesMinutesSecondsCompact: CoordinatesMatcher(
    latPattern: r"(?<degrees>\d{2})(?<minutes>\d{2})(?<seconds>\d{2})",
    longPattern: r"(?<degrees>\d{3})(?<minutes>\d{2})(?<seconds>\d{2})",
    isDirectional: true,
    formatType: CoordinatesFormatTypes.degreesMinutesSecondsCompact,
  ),
  CoordinatesFormatTypes.degreesMinutesSeconds: CoordinatesMatcher(
    latPattern:
        r"""(?<degrees>\d{1,3})[°∘\s](?<minutes>\d{1,2})[′'\s](?<seconds>\d{1,2}(\.\d+)?)"?""",
    longPattern:
        r"""(?<degrees>\d{1,3})[°∘\s](?<minutes>\d{1,2})[′'\s](?<seconds>\d{1,2}(\.\d+)?)"?""",
    isDirectional: true,
    formatType: CoordinatesFormatTypes.degreesMinutesSeconds,
  ),
  CoordinatesFormatTypes.degreesDecimalMinutesCompact: CoordinatesMatcher(
    latPattern: r"(?<degrees>\d{2})(?<minutes>\d{2}\.\d+)",
    longPattern: r"(?<degrees>\d{3})(?<minutes>\d{2}\.\d+)",
    isDirectional: true,
    formatType: CoordinatesFormatTypes.degreesDecimalMinutesCompact,
  ),
  CoordinatesFormatTypes.degreesDecimalMinutesSymbolic: CoordinatesMatcher(
    latPattern: r"(?<degrees>\d{1,3})[°∘]\s*(?<minutes>\d{1,2}\.\d+)[′']",
    longPattern: r"(?<degrees>\d{1,3})[°∘]\s*(?<minutes>\d{1,2}\.\d+)[′']",
    isDirectional: true,
    formatType: CoordinatesFormatTypes.degreesDecimalMinutesSymbolic,
  ),
  CoordinatesFormatTypes.decimalDegreesHemisphere: CoordinatesMatcher(
    latPattern: r"(?<number>\d{1,3}(?:\.\d+)?)",
    longPattern: r"(?<number>\d{1,3}(?:\.\d+)?)",
    isDirectional: true,
    formatType: CoordinatesFormatTypes.decimalDegreesHemisphere,
  ),
  CoordinatesFormatTypes.decimalDegrees: CoordinatesMatcher(
    latPattern: r"(?<number>[+\-−]?\d{1,3}(?:\.\d+)?)",
    longPattern: r"(?<number>[+\-−]?\d{1,3}(?:\.\d+)?)",
    formatType: CoordinatesFormatTypes.decimalDegrees,
  ),
};

/// Keeps the parsed coordinates data.
class CoordinatesParseResult {
  const CoordinatesParseResult._({
    required this.type,
    required this.leadingOrTrailing,
    required this.latValue,
    required this.longValue,
    required this.latMatch,
    required this.longMatch,
    required this.matcher,
  });
  final CoordinatesFormatTypes type;
  final LeadingOrTrailing? leadingOrTrailing;
  final String latValue;
  final String longValue;
  final RegExpMatch latMatch;
  final RegExpMatch longMatch;
  final CoordinatesMatcher matcher;

  factory CoordinatesParseResult({
    required CoordinatesFormatTypes type,
    LeadingOrTrailing? leadingOrTrailing,
    required String latValue,
    required String longValue,
  }) {
    final CoordinatesMatcher matcher = matchers[type]!;

    final String latPattern;
    if (matcher.isDirectional) {
      latPattern = leadingOrTrailing == LeadingOrTrailing.leading
          ? matcher.leadingDiectionalLat
          : matcher.trailingDiectionalLat;
    } else {
      latPattern = matcher.latPattern;
    }

    final String longPattern;
    if (matcher.isDirectional) {
      longPattern = leadingOrTrailing == LeadingOrTrailing.leading
          ? matcher.leadingDiectionalLong
          : matcher.trailingDiectionalLong;
    } else {
      longPattern = matcher.longPattern;
    }

    final latMatch = RegExp(latPattern).firstMatch(latValue);
    final longMatch = RegExp(longPattern).firstMatch(longValue);

    if (latMatch == null || longMatch == null) {
      throw FormatException('Invalid coordinate format for $type');
    }

    return CoordinatesParseResult._(
      type: type,
      leadingOrTrailing: leadingOrTrailing,
      latValue: latValue,
      longValue: longValue,
      latMatch: latMatch,
      longMatch: longMatch,
      matcher: matcher,
    );
  }

  factory CoordinatesParseResult.fromMatch(RegExpMatch match) {
    List<CoordinatesFormatTypes> types = [];
    List<LeadingOrTrailing?> leadingOrTrailingCoordinates = [];
    Map<LatOrLong, String> result = {};
    for (String groupName in match.groupNames) {
      String? value = match.namedGroup(groupName);
      if (value != null) {
        types.add(_getTypeFromKey(groupName));
        leadingOrTrailingCoordinates.add(
          _getLeadingOrTrailingFromKey(groupName),
        );
        result[_latOrLong(groupName)] = value;
        if (types.length >= 2) break;
      }
    }
    CoordinatesMatcher matcher = matchers[types.first]!;
    assert(
      types.every((e) => types.first == e),
      "Lat and Long coordinate types dont match.",
    );
    var coordinatesFromResult = result.keys.whereType<LatOrLong>();
    assert(
      coordinatesFromResult.first != coordinatesFromResult.last,
      "Lat or long missing.",
    );
    assert(
      matcher.isDirectional &&
          leadingOrTrailingCoordinates.every((e) => e != null),
      "Every coordinate must have a direction when Directional == true.",
    );
    return CoordinatesParseResult(
      type: types.first,
      leadingOrTrailing: leadingOrTrailingCoordinates.first,
      latValue: result[LatOrLong.lat]!,
      longValue: result[LatOrLong.long]!,
    );
  }

  LatLng? toLatLng() {
    List<String> filterGroupNames(Iterable<String> groupNames) {
      return groupNames
          .where(
            (e) =>
                !(e.contains(RegExp(r"northOrSouth|eastOrWest")) ||
                    coordinateMainGroupNameParser.hasMatch(e)),
          )
          .toList();
    }

    Map dividers = {"number": 1, "degrees": 1, "minutes": 60, "seconds": 3600};
    final String? northOrSouth = matcher.isDirectional
        ? latMatch.namedGroup(
            latMatch.groupNames.firstWhere((e) => e.startsWith("northOrSouth")),
          )
        : null;
    final String? eastOrWest = matcher.isDirectional
        ? longMatch.namedGroup(
            longMatch.groupNames.firstWhere((e) => e.startsWith("eastOrWest")),
          )
        : null;
    List<String> filteredLatGroupNames = filterGroupNames(latMatch.groupNames);
    List<String> filteredLongGroupNames = filterGroupNames(
      longMatch.groupNames,
    );
    if ((filteredLatGroupNames.every((e) => latMatch.namedGroup(e) != null)) &&
        filteredLongGroupNames.every((e) => longMatch.namedGroup(e) != null)) {
      final double latResult =
          filteredLatGroupNames
              .map((e) {
                return double.parse(latMatch.namedGroup(e) ?? "0") /
                    dividers[e];
              })
              .fold(0.0, (previousValue, element) => previousValue + element) *
          (northOrSouth != null ? _getMultiplierNS(northOrSouth) : 1);
      final double longResult =
          filteredLongGroupNames
              .map(
                (e) =>
                    double.parse(longMatch.namedGroup(e) ?? "0") / dividers[e],
              )
              .fold(0.0, (previousValue, element) => previousValue + element) *
          (eastOrWest != null ? _getMultiplierEW(eastOrWest) : 1);
      return LatLng(latResult, longResult);
    }
    return null;
  }
}

String _removeGroupNamesExceptMain(String patternInput) {
  return patternInput.replaceAllMapped(RegExp(r"(?<=\(\?)(\<\w+\>)"), (match) {
    String origin = match.group(1)!;
    return coordinateMainGroupNameParser.hasMatch(origin) ? origin : ":";
  });
}

/// Holds regex patterns and format type for coordinate matching.
class CoordinatesMatcher {
  CoordinatesMatcher({
    required this.latPattern,
    required this.longPattern,
    required this.formatType,
    this.isDirectional = false,
  });

  /// Regex pattern for latitude.
  final String latPattern;

  /// Regex pattern for longitude.
  final String longPattern;

  /// Indicates if the format uses directional indicators (N, S, E, W).
  bool isDirectional;

  /// The text format type of the matcher.
  CoordinatesFormatTypes formatType;
  get leadingDiectionalLat =>
      "(?<${formatType.name}_LAT_LD>$leadingLat$latPattern)";
  get leadingDiectionalLong =>
      "(?<${formatType.name}_LONG_LD>$leadingLong$longPattern)";
  get trailingDiectionalLat =>
      "(?<${formatType.name}_LAT_TD>$latPattern$trailingLat)";
  get trailingDiectionalLong =>
      "(?<${formatType.name}_LONG_TD>$longPattern$trailingLong)";

  /// generates a pattern with a given seperator between lat and long patterns
  String withSeperatorPattern(String seperator) {
    String groupNameLat = "${formatType.name}_LAT";
    String groupNameLong = "${formatType.name}_LONG";
    late String result;

    if (!isDirectional) {
      result =
          "(?<$groupNameLat>$latPattern)" +
          seperator +
          "(?<$groupNameLong>$longPattern)";
    } else {
      result =
          leadingDiectionalLat +
          seperator +
          leadingDiectionalLong +
          "|" +
          trailingDiectionalLat +
          seperator +
          trailingDiectionalLong;
    }
    return _removeGroupNamesExceptMain(result);
  }
}

/// Normalizes various representations of coordinate strings to a standard format.
String _normalizeCoordinateString(String input) {
  return input
      // Normalize minus / dash variants to ASCII hyphen
      .replaceAll(RegExp(r"[−–—‑]"), "-")
      // Normalize prime symbols to ASCII
      .replaceAll(RegExp(r"[′ʹ]"), "'")
      .replaceAll(RegExp(r'[″]'), '"')
      // Normalize degree symbols (and similar) to °
      .replaceAll(RegExp(r'[º˚◦⁰]'), '°')
      // Normalize whitespace: non-breaking, narrow, etc.
      .replaceAll(RegExp(r"[\u00A0\u202F\u2009]"), ' ')
      // Trim extra whitespace
      .trim();
}

/// Returns -1 for South/West and 1 for North/East.
double _getMultiplierNS(String value) {
  return RegExp("S", caseSensitive: false).hasMatch(value) ? -1 : 1;
}

/// Returns -1 for South/West and 1 for North/East.
double _getMultiplierEW(String value) {
  return RegExp("W", caseSensitive: false).hasMatch(value) ? -1 : 1;
}

/// Extracts whether the key corresponds to latitude or longitude.
LatOrLong _latOrLong(String key) {
  RegExpMatch match = coordinateMainGroupNameParser.firstMatch(key)!;
  return LatOrLong.values.firstWhere(
    (element) => element.name.toUpperCase() == match.namedGroup("LatOrLong"),
  );
}

/// Extracts the coordinate format type from the key.
CoordinatesFormatTypes _getTypeFromKey(String key) {
  RegExpMatch match = coordinateMainGroupNameParser.firstMatch(key)!;
  return matchers.keys.firstWhere(
    (CoordinatesFormatTypes type) => match.namedGroup("type") == type.name,
  );
}

LeadingOrTrailing? _getLeadingOrTrailingFromKey(String key) {
  RegExpMatch match = coordinateMainGroupNameParser.firstMatch(key)!;
  String? leadingOrTrailingText = match.namedGroup("LeadingOrTrailing");
  if (leadingOrTrailingText == "LD") {
    return LeadingOrTrailing.leading;
  }
  if (leadingOrTrailingText == "TD") {
    return LeadingOrTrailing.trailing;
  }
  return null;
}

/// Pattern with default seperator used for parsing coordinates. matches ( "," or spaces or no space)
final String defaultFullPattern = fullPatternWithSeperator(
  seperator: defaultSeperatorPattern,
  nonDirectionalSeperator: defaultSeperatorPatternNonEmpty,
);

String fullPatternWithSeperator({
  required String seperator,
  String? nonDirectionalSeperator,
}) {
  List patterns = [];
  nonDirectionalSeperator ??= seperator;
  for (var matcher in matchers.values) {
    if (matcher.isDirectional) {
      patterns.add("(?:${matcher.withSeperatorPattern(seperator)})");
    } else {
      patterns.add(
        "(?:${matcher.withSeperatorPattern(nonDirectionalSeperator)})",
      );
    }
  }
  return patterns.join("|");
}

CoordinatesParseResult? tryParseSingle(
  String text, {
  String? seperatorPattern,
}) {
  String fullPattern = seperatorPattern ?? defaultFullPattern;
  RegExpMatch? match = RegExp(
    "^$fullPattern\$",
    multiLine: true,
  ).firstMatch(_normalizeCoordinateString(text));
  if (match == null) {
    return null;
  }
  return CoordinatesParseResult.fromMatch(match);
}

Iterable<CoordinatesParseResult> parseAll(
  String text, {
  String? seperatorPattern,
}) {
  String fullPattern = seperatorPattern ?? defaultFullPattern;
  Iterable<RegExpMatch> matches = RegExp(
    fullPattern,
  ).allMatches(_normalizeCoordinateString(text));
  return matches.map(CoordinatesParseResult.fromMatch);
}

bool hasMatchField(String text, {String? seperatorPattern}) {
  String fullPattern = seperatorPattern ?? defaultFullPattern;
  return RegExp(
    "^$fullPattern\$",
    multiLine: true,
  ).hasMatch(_normalizeCoordinateString(text));
}
