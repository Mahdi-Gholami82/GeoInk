import 'package:flutter/material.dart';
import 'package:GeoInk/data/models/flutter_map_entry.dart';

abstract final class MapIcons {
  static const IconData circle = Icons.adjust;
  static const IconData marker = Icons.location_on;
  static const IconData polygon = Icons.hexagon_outlined;
  static const IconData polyline = Icons.polyline;

  static IconData fromType(EntryType type) {
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
