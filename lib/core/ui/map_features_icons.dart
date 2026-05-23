import 'package:flutter/material.dart';
import 'package:GeoInk/data/models/flutter_map_entry.dart';

abstract final class MapIcons {
  static const IconData circle = Icons.adjust;
  static const IconData marker = Icons.location_on;
  static const IconData polygon = Icons.hexagon_outlined;
  static const IconData polyline = Icons.polyline;

  static IconData fromType(EntryType type) {
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
