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

/// Holds regex patterns and format type for coordinate matching.
class CoordinatesMatcher {
  CoordinatesMatcher({
    required String latPattern,
    required String longPattern,
    required this.formatType,
    this.isDirectional = false,
  }) {
    this.latPattern = isDirectional
        ? r"(?:(?<northOrSouth_leading_LAT>[NS])\s*)?" +
              latPattern +
              r"(?:\s*(?<northOrSouth_trailing_LAT>[NS]))?"
        : latPattern;
    this.longPattern = isDirectional
        ? r"(?:(?<eastOrWest_leading_LONG>[EW])\s*)?" +
              longPattern +
              r"(?:\s*(?<eastOrWest_trailing_LONG>[EW]))?"
        : longPattern;
  }

  /// Regex pattern for latitude.
  late final String latPattern;

  /// Regex pattern for longitude.
  late final String longPattern;

  /// Regex pattern for latitude but without named groups.
  late final String latPatternUnnamedGroups = latPattern.replaceAll(
    RegExp(r"(?<=\()(\?\<\w+\>)"),
    "",
  );

  /// Regex pattern for longitude but without named groups.
  late final String longPatternUnnamedGroups = longPattern.replaceAll(
    RegExp(r"(?<=\()(\?\<\w+\>)"),
    "",
  );

  /// Indicates if the format uses directional indicators (N, S, E, W).
  bool isDirectional;

  /// The text format type of the matcher.
  CoordinatesFormatTypes formatType;

  /// generates a pattern with a given seperator between lat and long patterns
  String withSeperatorPattern(String seperator) {
    return "(?<${formatType.name}_LAT>$latPatternUnnamedGroups)$seperator(?<${formatType.name}_LONG>$longPatternUnnamedGroups)";
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

/// Predefined matchers for various coordinate formats.
Map<CoordinatesFormatTypes, CoordinatesMatcher> matchers = {
  CoordinatesFormatTypes.decimalDegrees: CoordinatesMatcher(
    latPattern: r"(?<number>[+\-−]?\d{1,3}(?:\.\d+)?)",
    longPattern: r"(?<number>[+\-−]?\d{1,3}(?:\.\d+)?)",
    formatType: CoordinatesFormatTypes.decimalDegrees,
  ),
  CoordinatesFormatTypes.decimalDegreesHemisphere: CoordinatesMatcher(
    latPattern: r"(?<number>\d{1,3}(?:\.\d+)?)\s*",
    longPattern: r"(?<number>\d{1,3}(?:\.\d+)?)\s*",
    isDirectional: true,
    formatType: CoordinatesFormatTypes.decimalDegreesHemisphere,
  ),
  CoordinatesFormatTypes.degreesDecimalMinutesSymbolic: CoordinatesMatcher(
    latPattern: r"(?<degrees>\d{1,3})[°∘]\s*(?<minutes>\d{1,2}\.\d+)[′']",
    longPattern: r"(?<degrees>\d{1,3})[°∘]\s*(?<minutes>\d{1,2}\.\d+)[′']",
    isDirectional: true,
    formatType: CoordinatesFormatTypes.degreesDecimalMinutesSymbolic,
  ),
  CoordinatesFormatTypes.degreesDecimalMinutesCompact: CoordinatesMatcher(
    latPattern: r"(?<degrees>\d{2})(?<minutes>\d{2}\.\d+)",
    longPattern: r"(?<degrees>\d{3})(?<minutes>\d{2}\.\d+)",
    isDirectional: true,
    formatType: CoordinatesFormatTypes.degreesDecimalMinutesCompact,
  ),
  CoordinatesFormatTypes.degreesMinutesSeconds: CoordinatesMatcher(
    latPattern:
        r"""(?<degrees>\d{1,3})[°∘\s](?<minutes>\d{1,2})[′'\s](?<seconds>\d{1,2}(\.\d+)?)"?""",
    longPattern:
        r"""(?<degrees>\d{1,3})[°∘\s](?<minutes>\d{1,2})[′'\s](?<seconds>\d{1,2}(\.\d+)?)"?""",
    isDirectional: true,
    formatType: CoordinatesFormatTypes.degreesMinutesSeconds,
  ),
  CoordinatesFormatTypes.degreesMinutesSecondsCompact: CoordinatesMatcher(
    latPattern: r"(?<degrees>\d{2})(?<minutes>\d{2})(?<seconds>\d{2})",
    longPattern: r"(?<degrees>\d{3})(?<minutes>\d{2})(?<seconds>\d{2})",
    isDirectional: true,
    formatType: CoordinatesFormatTypes.degreesMinutesSecondsCompact,
  ),
  CoordinatesFormatTypes.notamCompactDDMM: CoordinatesMatcher(
    latPattern: r"(?<degrees>\d{2})(?<minutes>\d{2})",
    longPattern: r"(?<degrees>\d{3})(?<minutes>\d{2})",
    isDirectional: true,
    formatType: CoordinatesFormatTypes.notamCompactDDMM,
  ),
  CoordinatesFormatTypes.notamCompactDDMMSS: CoordinatesMatcher(
    latPattern: r"(?<degrees>\d{2})(?<minutes>\d{2})(?<seconds>\d{2})",
    longPattern: r"(?<degrees>\d{3})(?<minutes>\d{2})(?<seconds>\d{2})",
    isDirectional: true,
    formatType: CoordinatesFormatTypes.notamCompactDDMMSS,
  ),
};

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
  RegExpMatch match = RegExp(r"^[a-zA-Z]+_((?:LAT|LONG))$").firstMatch(key)!;
  return LatOrLong.values.firstWhere(
    (element) => element.name.toUpperCase() == match.group(1),
  );
}

/// Extracts the coordinate format type from the key.
CoordinatesFormatTypes _getTypeFromKey(String key) {
  RegExpMatch match = RegExp(r"^([a-zA-Z]+)_(?:LAT|LONG)$").firstMatch(key)!;
  return matchers.keys.firstWhere(
    (CoordinatesFormatTypes type) => match.group(1) == type.name,
  );
}

/// Extracts directional indicators (N, S, E, W) from latitude and longitude strings.
List<String> _getDirections(
  String lat,
  String long,
  CoordinatesFormatTypes type,
) {
  if (!matchers[type]!.isDirectional) {
    return [];
  }
  var matcher = matchers[type]!;
  String? northOrSouthLeading = RegExp(
    matcher.latPattern,
  ).firstMatch(lat)?.namedGroup("northOrSouth_leading_LAT");
  String? eastOrWestLeading = RegExp(
    matcher.longPattern,
  ).firstMatch(long)?.namedGroup("eastOrWest_leading_LONG");
  String? northOrSouthTrailing = RegExp(
    matcher.latPattern,
  ).firstMatch(lat)?.namedGroup("northOrSouth_trailing_LAT");
  String? eastOrWestTrailing = RegExp(
    matcher.longPattern,
  ).firstMatch(long)?.namedGroup("eastOrWest_trailing_LONG");
  if (northOrSouthLeading != null && eastOrWestLeading != null) {
    return [northOrSouthLeading, eastOrWestLeading];
  }
  if (northOrSouthTrailing != null && eastOrWestTrailing != null) {
    return [northOrSouthTrailing, eastOrWestTrailing];
  }
  return [];
}

/// Generic parser that converts latitude and longitude strings into a [LatLng] object based on the specified format type.
LatLng? _genericCoordinatesToLatLngParser(
  String lat,
  String long,
  CoordinatesFormatTypes formatType,
) {
  List<String> filterGroupNames(Iterable<String> groupNames) {
    return groupNames
        .where((e) => e.contains(RegExp(r"northOrSouth|eastOrWest")) == false)
        .toList();
  }

  Map dividers = {"number": 1, "degrees": 1, "minutes": 60, "seconds": 3600};
  var matcher = matchers[formatType];
  List<String> directions = _getDirections(lat, long, formatType);
  String? northOrSouth = directions.elementAtOrNull(0);
  String? eastOrWest = directions.elementAtOrNull(1);
  if (matcher != null) {
    var latMatch = RegExp(matcher.latPattern).firstMatch(lat);
    var longMatch = RegExp(matcher.longPattern).firstMatch(long);
    List<String> filteredLatGroupNames = filterGroupNames(
      latMatch?.groupNames ?? [],
    );
    List<String> filteredLongGroupNames = filterGroupNames(
      longMatch?.groupNames ?? [],
    );
    if (latMatch != null &&
        longMatch != null &&
        (filteredLatGroupNames.every((e) => latMatch.namedGroup(e) != null)) &&
        filteredLongGroupNames.every((e) => longMatch.namedGroup(e) != null)) {
      var latResult =
          filteredLatGroupNames
              .map((e) {
                return double.parse(latMatch.namedGroup(e) ?? "0") /
                    dividers[e];
              })
              .fold(0.0, (previousValue, element) => previousValue + element) *
          (northOrSouth != null ? _getMultiplierNS(northOrSouth) : 1);
      var longResult =
          filteredLongGroupNames
              .map(
                (e) =>
                    double.parse(longMatch.namedGroup(e) ?? "0") / dividers[e],
              )
              .fold(0.0, (previousValue, element) => previousValue + element) *
          (eastOrWest != null ? _getMultiplierEW(eastOrWest) : 1);
      return LatLng(latResult, longResult);
    }
  }
  return null;
}

/// Processes a [RegExpMatch] to extract latitude, longitude, and format type into a map.
Map _processMatchToMap(RegExpMatch match) {
  Map result = {};
  late CoordinatesFormatTypes type;
  for (String groupName in match.groupNames.where(
    (e) => RegExp(r"(?:LAT|LONG)$").hasMatch(e),
  )) {
    String? value = match.namedGroup(groupName);
    if (value != null) {
      type = _getTypeFromKey(groupName);
      result[_latOrLong(groupName)] = value;
    }
  }
  result["type"] = type;
  return result;
}

/// Parses and reformats coordinate strings into structured data.
class CoordinatesParser {
  late final String defaultFullPattern = fullPatternWithSeperator(
    r"(?:[,\s]|(?<=\D))",
  );

  String fullPatternWithSeperator(String seperator) {
    List patterns = [];
    for (var matcher in matchers.values) {
      patterns.add("(?:${matcher.withSeperatorPattern(seperator)})");
    }
    return patterns.join("|");
  }

  Map? parseSingle(String text, {String? seperator}) {
    String fullPattern = seperator == null
        ? defaultFullPattern
        : fullPatternWithSeperator(seperator);
    RegExpMatch? match = RegExp(
      "^$fullPattern\$",
      multiLine: true,
    ).firstMatch(_normalizeCoordinateString(text));
    if (match == null) {
      return null;
    }
    return _processMatchToMap(match);
  }

  Iterable<Map> parseAll(String text, {String? seperator}) {
    String fullPattern = seperator == null
        ? defaultFullPattern
        : fullPatternWithSeperator(seperator);
    Iterable<RegExpMatch> matches = RegExp(
      fullPattern,
    ).allMatches(_normalizeCoordinateString(text));
    return matches.map(_processMatchToMap);
  }

  bool hasMatchField(String text, {String? seperator}) {
    String fullPattern = seperator == null
        ? defaultFullPattern
        : fullPatternWithSeperator(seperator);
    return RegExp(
      "^$fullPattern\$",
      multiLine: true,
    ).hasMatch(_normalizeCoordinateString(text));
  }

  LatLng? parseSingleToLatLng(String text, {String? seperator}) {
    Map? coordinate = parseSingle(text, seperator: seperator);
    if (coordinate == null) return null;
    LatLng? latLng = _genericCoordinatesToLatLngParser(
      coordinate[LatOrLong.lat]!,
      coordinate[LatOrLong.long]!,
      coordinate["type"],
    );
    return latLng;
  }

  List<LatLng> parseAllToLatLng(String text, {String? seperator}) {
    Iterable<Map> coordinates = parseAll(text, seperator: seperator);
    print(coordinates.length);
    List<LatLng> latLngs = [];
    for (var coordinate in coordinates) {
      LatLng? latLng = _genericCoordinatesToLatLngParser(
        coordinate[LatOrLong.lat]!,
        coordinate[LatOrLong.long]!,
        coordinate["type"],
      );
      if (latLng == null) {
        continue;
      }
      latLngs.add(latLng);
    }
    return latLngs;
  }
}
