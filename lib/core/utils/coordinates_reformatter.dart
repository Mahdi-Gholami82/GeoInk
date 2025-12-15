enum CoordinatesFormatTypes {
  // Decimal degrees
  // Example: 51.5074, -0.1278
  decimalDegrees,

  // Decimal degrees with hemisphere
  // Example: 51.5074N 0.1278W
  decimalDegreesHemisphere,

  // Degrees + decimal minutes (symbolic)
  // Example: 51°23.45'N 004°12.34'E
  degreesDecimalMinutesSymbolic,

  // Degrees + decimal minutes (compact aviation)
  // Example: 5123.45N 00412.34E
  degreesDecimalMinutesCompact,

  // Degrees + minutes + seconds (symbolic)
  // Example: 51°30'26"N 004°12'10"E
  degreesMinutesSeconds,

  // Degrees + minutes + seconds (compact)
  // Example: 513026N 0041210E
  degreesMinutesSecondsCompact,

  // NOTAM DDMM (compact)
  // Example: 5123N00412E
  notamCompactDDMM,

  // NOTAM DDMM with spaces
  // Example: 5123 N 00412 E
  notamDDMMSpaced,

  // NOTAM DDMMSS (compact)
  // Example: 512345N0041234E
  notamCompactDDMMSS,

  // NOTAM DDMMSS with spaces
  // Example: 512345 N 0041234 E
  notamDDMMSSSpaced,
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
      latPattern: r"[+\-−]?\d{1,3}(?:\.\d+)?",
      longPattern: r"[+\-−]?\d{1,3}(?:\.\d+)?",
      formatType: CoordinatesFormatTypes.decimalDegrees,
    ),
    CoordinatesFormatTypes.decimalDegreesHemisphere: CoordinatesMatcher(
      latPattern: r"[+\-−]?\d{1,3}(?:\.\d+)?\s*[NS]",
      longPattern: r"[+\-−]?\d{1,3}(?:\.\d+)?\s*[EW]",
      formatType: CoordinatesFormatTypes.decimalDegreesHemisphere,
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
    CoordinatesFormatTypes.degreesMinutesSecondsCompact: CoordinatesMatcher(
      latPattern: r"\d{6}[NS]",
      longPattern: r"\d{7}[EW]",
      formatType: CoordinatesFormatTypes.degreesMinutesSecondsCompact,
    ),
    CoordinatesFormatTypes.notamCompactDDMM: CoordinatesMatcher(
      latPattern: r"\d{4}[NS]",
      longPattern: r"\d{5}[EW]",
      formatType: CoordinatesFormatTypes.notamCompactDDMM,
    ),
    CoordinatesFormatTypes.notamDDMMSpaced: CoordinatesMatcher(
      latPattern: r"\d{4}\s[NS]",
      longPattern: r"\d{5}\s[EW]",
      formatType: CoordinatesFormatTypes.notamDDMMSpaced,
    ),
    CoordinatesFormatTypes.notamCompactDDMMSS: CoordinatesMatcher(
      latPattern: r"\d{6}[NS]",
      longPattern: r"\d{7}[EW]",
      formatType: CoordinatesFormatTypes.notamCompactDDMMSS,
    ),
    CoordinatesFormatTypes.notamDDMMSSSpaced: CoordinatesMatcher(
      latPattern: r"\d{6}\s[NS]",
      longPattern: r"\d{7}\s[EW]",
      formatType: CoordinatesFormatTypes.notamDDMMSSSpaced,
    ),
  };

  late final String defaultFullPattern = fullPatternWithSeperator(
    r"(?:[,\s]|(?<=\D))",
  );

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
    print(fullPattern);
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
