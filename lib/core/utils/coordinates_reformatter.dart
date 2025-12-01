import 'dart:io';

enum CoordinatesFormatTypes {
  // Decimal degrees, e.g. "51.5074, -0.1278"
  decimalDegrees,

  // Degrees + decimal minutes (symbolic), e.g. "51°23.45' N"
  degreesDecimalMinutesSymbolic,

  // Degrees + decimal minutes (compact aviation), e.g. "5123.45N"
  degreesDecimalMinutesCompact,

  // Degrees + minutes + seconds, e.g. "51°30'26"N"
  degreesMinutesSeconds,

  // NOTAM compact without seconds: "5123N00412E"
  notamCompactDDMM,

  // NOTAM compact with seconds: "512345N0041234E"
  notamCompactDDMMSS,

  // GeoURI scheme, e.g. "geo:51.5074,-0.1278"
  geoURI,

  // Well-known text, e.g. "POINT (-0.1278 51.5074)"
  wkt,
}

enum LatOrLong { lat, long }

class CoordinatesMatcher {
  CoordinatesMatcher({
    required this.latPattern,
    required this.longPattern,
    required this.formatType,
  });
  String latPattern;
  String longPattern;

  CoordinatesFormatTypes formatType;

  String withSeperatorPattern(String seperator) {
    return "(?<${formatType.name}_LAT>$latPattern)$seperator(?<${formatType.name}_LONG>$longPattern)";
  }
}

class CoordinatesParser {
  Map<CoordinatesFormatTypes, CoordinatesMatcher> matchers = {
    CoordinatesFormatTypes.decimalDegrees: CoordinatesMatcher(
      latPattern: r"[+-]?\d{1,3}(?:\.\d+)?",
      longPattern: r"[+-]?\d{1,3}(?:\.\d+)?",
      formatType: CoordinatesFormatTypes.decimalDegrees,
    ),
    CoordinatesFormatTypes.degreesDecimalMinutesSymbolic: CoordinatesMatcher(
      latPattern: r"[NS]?\s*\d{1,3}°?\s*\d{1,2}\.\d+'?\s*[NS]?",
      longPattern: r"[EW]?\s*\d{1,3}°?\s*\d{1,2}\.\d+'?\s*[EW]?",
      formatType: CoordinatesFormatTypes.degreesDecimalMinutesSymbolic,
    ),
    CoordinatesFormatTypes.degreesDecimalMinutesCompact: CoordinatesMatcher(
      latPattern: r"\d{2}\d{2}\.\d+[NS]",
      longPattern: r"\d{3}\d{2}\.\d+[EW]",
      formatType: CoordinatesFormatTypes.degreesDecimalMinutesCompact,
    ),
    CoordinatesFormatTypes.degreesMinutesSeconds: CoordinatesMatcher(
      latPattern:
          r"""[NS]?\s*\d{1,3}[°\s]\d{1,2}['\s]\d{1,2}(\.\d+)?"?\s*[NS]?""",
      longPattern:
          r"""[EW]?\s*\d{1,3}[°\s]\d{1,2}['\s]\d{1,2}(\.\d+)?"?\s*[EW]?""",
      formatType: CoordinatesFormatTypes.degreesMinutesSeconds,
    ),
    CoordinatesFormatTypes.notamCompactDDMM: CoordinatesMatcher(
      latPattern: r"\d{4}[NS]",
      longPattern: r"\d{5}[EW]",
      formatType: CoordinatesFormatTypes.notamCompactDDMM,
    ),
    CoordinatesFormatTypes.notamCompactDDMMSS: CoordinatesMatcher(
      latPattern: r"\d{6}[NS]",
      longPattern: r"\d{7}[EW]",
      formatType: CoordinatesFormatTypes.notamCompactDDMMSS,
    ),
    CoordinatesFormatTypes.geoURI: CoordinatesMatcher(
      latPattern: r"geo:[+-]?\d{1,3}\.\d+",
      longPattern: r",[+-]?\d{1,3}\.\d+",
      formatType: CoordinatesFormatTypes.geoURI,
    ),
    CoordinatesFormatTypes.wkt: CoordinatesMatcher(
      latPattern: r"POINT\s*\(\s*-?\d+(\.\d+)?",
      longPattern: r"\s+-?\d+(\.\d+)?\s*\)",
      formatType: CoordinatesFormatTypes.wkt,
    ),
  };

  late final String defaultFullPattern = fullPatternWithSeperator(r".*?");

  LatOrLong _latOrLong(String key) {
    RegExpMatch match = RegExp(r"^[a-zA-Z]+_((?:LAT|LONG))$").firstMatch(key)!;
    return LatOrLong.values.firstWhere(
      (element) => element.name.toUpperCase() == match.group(1),
    );
  }

  CoordinatesFormatTypes _getTypeFromKey(String key) {
    RegExpMatch match = RegExp(r"^([a-zA-Z]+)_(?:LAT|LONG)$").firstMatch(key)!;
    return matchers.keys.firstWhere(
      (CoordinatesFormatTypes type) => match.group(1) == type.name,
    );
  }

  String fullPatternWithSeperator(String seperator) {
    List patterns = [];
    for (var matcher in matchers.values) {
      patterns.add("(?:${matcher.withSeperatorPattern(seperator)})");
    }
    return patterns.join("|");
  }

  Iterable<Map> parseAll(String text, {String? seperator}) {
    String fullPattern = seperator == null
        ? defaultFullPattern
        : fullPatternWithSeperator(seperator);
    Iterable<RegExpMatch> matches = RegExp(fullPattern).allMatches(text);
    return matches.map((RegExpMatch match) {
      Map coordinates = {};
      late CoordinatesFormatTypes type;
      for (String groupName in match.groupNames) {
        String? value = match.namedGroup(groupName);
        if (value != null) {
          type = _getTypeFromKey(groupName);
          coordinates[_latOrLong(groupName)] = value;
        }
      }
      coordinates["type"] = type;
      return coordinates;
    });
  }

  bool hasMatchField(String text, {String? seperator}) {
    String fullPattern = seperator == null
        ? defaultFullPattern
        : fullPatternWithSeperator(seperator);
    return RegExp("^$fullPattern\$", multiLine: true).hasMatch(text.trim());
  }
}
