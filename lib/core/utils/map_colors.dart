import 'package:flutter/material.dart';
import 'package:GeoInk/data/models/flutter_map_entry.dart';

abstract final class MapDefaultColors {
  static const Color circle = Colors.red;
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
      case EntryType.Circle:
        return circle;
      case EntryType.Marker:
        return marker;
      case EntryType.Polygon:
        return polygon;
      case EntryType.Polyline:
        return polyline;
    }
  }
}
