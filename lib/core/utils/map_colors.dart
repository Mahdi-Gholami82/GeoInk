import 'package:flutter/material.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';

abstract final class MapDefaultColors {
  static const Color circle = Colors.green;
  static const Color marker = Colors.black;
  static const Color polygon = Colors.blue;
  static const Color polyline = Colors.red;

  static Color from<T extends FlutterMapEntry>() {
    switch (T) {
      case CircleEntry:
        return circle;
      case MarkerEntry:
        return marker;
      case PolygonEntry:
        return polygon;
      case PolylineEntry:
        return polyline;
      default: 
        throw AssertionError("Invalid type");
    }
  }

  static Color fromType(EntryType type) {
    switch (type) {
      case EntryType.circle:
        return circle;
      case EntryType.marker:
        return marker;
      case EntryType.polygon:
        return polygon;
      case EntryType.polyline:
        return polyline;
    }
  }
}
