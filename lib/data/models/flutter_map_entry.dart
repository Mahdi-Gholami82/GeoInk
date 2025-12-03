import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Data models to keep track of map features or layers.

/// Base class for all Entries which are used to generate map features.
abstract class FlutterMapEntry extends ChangeNotifier {
  final String name;
  bool visible;

  /// will be overridden in each entry subclass.
  get feature;

  void toggleVisiblity() {
    visible = !visible;
    notifyListeners();
  }

  FlutterMapEntry({required this.name, this.visible = true});
}

/// Keeps track of a [Marker] feature that will be added to map layers later.
class MarkerEntry extends FlutterMapEntry {
  LatLng coordinate;
  Color color;

  MarkerEntry({
    required super.name,
    required this.coordinate,
    this.color = Colors.black,
    super.visible,
  });

  /// Generates a [Marker] from a [MarkerEntry] to be used in a [MarkerLayer].
  @override
  Marker get feature => Marker(
    point: coordinate,
    width: 64,
    height: 64,
    child: Icon(Icons.location_pin, size: 40, color: color),
  );
}

/// Keeps track of a [Polygon] feature that will be added to map layers later.
class PolygonEntry extends FlutterMapEntry {
  final List<LatLng> points;
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  PolygonEntry({
    required super.name,
    required this.points,
    required this.fillColor,
    required this.borderColor,
    this.borderWidth = 2.0,
  });

  /// Generates a [Polygon] from a [PolygonEntry] to be used in a [PolygonLayer].
  @override
  Polygon get feature => Polygon(
    points: points,
    borderColor: borderColor,
    borderStrokeWidth: borderWidth,
    color: fillColor,
  );
}

/// Keeps track of a [Polyline] feature that will be added to map layers later.
class PolylineEntry extends FlutterMapEntry {
  List<LatLng> points;
  Color color;
  double strokeWidth;

  PolylineEntry({
    required super.name,
    required this.points,
    this.color = Colors.red,
    this.strokeWidth = 3.0,
    super.visible,
  });

  /// Generates a [Polyline] from a [PolylineEntry] to be used in a [PolylineLayer].
  @override
  Polyline get feature =>
      Polyline(points: points, strokeWidth: strokeWidth, color: color);
}

/// Keeps track of a [CircleMarker] feature that will be added to map layers later.
class CircleEntry extends FlutterMapEntry {
  final LatLng center;
  final double radius;
  final Color borderColor;
  final double borderWidth;
  final Color fillColor;

  CircleEntry({
    required super.name,
    required this.center,
    required this.radius,
    required this.borderColor,
    this.borderWidth = 2.0,
    required this.fillColor,
  });

  /// Generates a [CircleMarker] from a [CircleEntry] to be used in a [CircleLayer].
  @override
  CircleMarker get feature => CircleMarker(
    useRadiusInMeter: true,
    point: center,
    radius: radius,
    borderColor: borderColor,
    borderStrokeWidth: borderWidth,
    color: fillColor.withAlpha(128),
  );
}

/// Differant types of [MapLayerEntry]
enum EntryType { marker, polygon, polyline, circle }

Map entryTypeClasses = {
  EntryType.circle: CircleEntry,
  EntryType.marker: MarkerEntry,
  EntryType.polygon: PolygonEntry,
  EntryType.polyline: PolylineEntry,
};

/// Collection of [FlutterMapEntry] sub classes, which have the same type.
class MapLayerEntry with ChangeNotifier {
  final EntryType type;
  final String name;
  final List<FlutterMapEntry> items;
  final bool isMain;

  MapLayerEntry({
    required this.type,
    required this.name,
    List<FlutterMapEntry>? items,
    this.isMain = false,
  }) : items = items ?? [];

  MapLayerEntry.marker({
    required String name,
    List<FlutterMapEntry>? items,
    bool isMain = false,
  }) : this(type: EntryType.marker, name: name, items: items, isMain: isMain);

  MapLayerEntry.polygon({
    required String name,
    List<FlutterMapEntry>? items,
    bool isMain = false,
  }) : this(type: EntryType.polygon, name: name, items: items, isMain: isMain);

  MapLayerEntry.polyline({
    required String name,
    List<FlutterMapEntry>? items,
    bool isMain = false,
  }) : this(type: EntryType.polyline, name: name, items: items, isMain: isMain);

  MapLayerEntry.circle({
    required String name,
    List<FlutterMapEntry>? items,
    bool isMain = false,
  }) : this(type: EntryType.circle, name: name, items: items, isMain: isMain);

  /// Converts all [FlutterMapEntry] sub classes in [items] to a map layer which will be added to the [FlutterMap] children.
  dynamic toFlutterMapObject() {
    List<FlutterMapEntry> filteredItems = items
        .where((element) => element.visible)
        .toList();
    switch (type) {
      case EntryType.marker:
        final markers = filteredItems.cast<MarkerEntry>();
        return MarkerLayer(
          markers: markers.map((marker) => marker.feature).toList(),
        );

      case EntryType.polyline:
        final lines = filteredItems.cast<PolylineEntry>();
        return PolylineLayer(
          polylines: lines.map((line) => line.feature).toList(),
        );

      case EntryType.polygon:
        final polys = filteredItems.cast<PolygonEntry>();
        return PolygonLayer(
          polygons: polys.map((poly) => poly.feature).toList(),
        );

      case EntryType.circle:
        final circles = filteredItems.cast<CircleEntry>();
        return CircleLayer(
          circles: circles.map((circle) => circle.feature).toList(),
        );
    }
  }
}
