import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:latlong2/latlong.dart';
import 'package:GeoInk/core/utils/map_colors.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

/// Data models to keep track of map features or layers.

/// Base class for all Entries which are used to generate map features.
abstract class FlutterMapEntry {
  String name;
  String description;
  bool visible;

  /// will be overridden in each entry subclass.
  get flutterMapFeature;
  GeoJSONGeometry get geoJasonObject;
  GeoJSONFeature toGeoJsonFeature(String layerName, String layerId);

  void toggleVisiblity() {
    visible = !visible;
  }

  FlutterMapEntry({
    required this.name,
    this.visible = true,
    this.description = "",
  });
}

/// Keeps track of a [Marker] feature that will be added to map layers later.
class MarkerEntry extends FlutterMapEntry {
  LatLng coordinate;
  Color color;

  MarkerEntry({
    required super.name,
    required this.coordinate,
    this.color = MapDefaultColors.marker,
    super.visible,
    super.description,
  });

  MarkerEntry.withDefaults({
    required super.name,
    required this.coordinate,
    Color? color,
    bool? visible,
    String? description,
  }) : color = color ?? MapDefaultColors.marker,
       super(visible: visible ?? true, description: description ?? "");

  /// Generates a [Marker] from a [MarkerEntry] to be used in a [MarkerLayer].
  @override
  Marker get flutterMapFeature => Marker(
    point: coordinate,
    width: 64,
    height: 64,
    child: Icon(Icons.location_pin, size: 40, color: color),
  );

  @override
  GeoJSONPoint get geoJasonObject =>
      GeoJSONPoint([coordinate.longitude, coordinate.latitude]);

  @override
  GeoJSONFeature toGeoJsonFeature(String layerName, String layerId) =>
      GeoJSONFeature(
        geoJasonObject,
        properties: {
          "name": name,
          "color": color.toHexString(),
          "visible": visible,
          "layer-id": layerId,
          "layer-name": layerName,
          "description": description,
        },
      );
}

/// Keeps track of a [Polygon] feature that will be added to map layers later.
class PolygonEntry extends FlutterMapEntry {
  final List<LatLng> coordinates;
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  PolygonEntry({
    required super.name,
    required this.coordinates,
    this.fillColor = MapDefaultColors.polygon,
    Color? borderColor,
    this.borderWidth = 2.0,
    super.description,
    super.visible,
  }) : borderColor = borderColor ?? MapDefaultColors.polygon.withAlpha(128);

  PolygonEntry.withDefaults({
    required super.name,
    required this.coordinates,
    Color? fillColor,
    Color? borderColor,
    num? borderWidth,
    bool? visible,
    String? description,
  }) : fillColor =
           fillColor ??
           (borderColor?.withAlpha(128) ??
               MapDefaultColors.polygon.withAlpha(128)),
       borderColor = borderColor ?? MapDefaultColors.polygon,

       borderWidth = (borderWidth ?? 2.0).toDouble(),
       super(visible: visible ?? true, description: description ?? "");

  /// Generates a [Polygon] from a [PolygonEntry] to be used in a [PolygonLayer].
  @override
  Polygon get flutterMapFeature => Polygon(
    points: coordinates,
    borderColor: borderColor,
    borderStrokeWidth: borderWidth,
    color: fillColor,
  );

  @override
  GeoJSONPolygon get geoJasonObject {
    return GeoJSONPolygon([
      coordinates.map((p) => [p.longitude, p.latitude]).toList(),
    ]);
  }

  @override
  GeoJSONFeature toGeoJsonFeature(String layerName, String layerId) =>
      GeoJSONFeature(
        geoJasonObject,
        properties: {
          "name": name,
          "fill": fillColor.toHexString(),
          "stroke": borderColor.toHexString(),
          "stroke-width": borderWidth,
          "visible": visible,
          "layer-id": layerId,
          "layer-name": layerName,
          "description": description,
        },
      );
}

/// Keeps track of a [Polyline] feature that will be added to map layers later.
class PolylineEntry extends FlutterMapEntry {
  List<LatLng> coordinates;
  Color color;
  double strokeWidth;

  PolylineEntry({
    required super.name,
    required this.coordinates,
    this.color = MapDefaultColors.polyline,
    this.strokeWidth = 3.0,
    super.visible,
    super.description,
  });

  PolylineEntry.withDefaults({
    required super.name,
    required this.coordinates,
    Color? color,
    num? strokeWidth,
    bool? visible,
    String? description,
  }) : color = color ?? MapDefaultColors.polyline,
       strokeWidth = (strokeWidth ?? 2.0).toDouble(),
       super(visible: visible ?? true, description: description ?? "");

  /// Generates a [Polyline] from a [PolylineEntry] to be used in a [PolylineLayer].
  @override
  Polyline get flutterMapFeature =>
      Polyline(points: coordinates, strokeWidth: strokeWidth, color: color);

  @override
  GeoJSONLineString get geoJasonObject => GeoJSONLineString(
    coordinates.map((p) => [p.longitude, p.latitude]).toList(),
  );

  @override
  GeoJSONFeature toGeoJsonFeature(String layerName, String layerId) =>
      GeoJSONFeature(
        geoJasonObject,
        properties: {
          "name": name,
          "stroke": color.toHexString(),
          "stroke-width": strokeWidth,
          "visible": visible,
          "layer-id": layerId,
          "layer-name": layerName,
          "description": description,
        },
      );
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
    required this.fillColor,
    this.borderWidth = 2.0,
  });

  CircleEntry.withDefaults({
    required super.name,
    required this.center,
    required this.radius,
    Color? fillColor,
    Color? borderColor,
    num? borderWidth,
    bool? visible,
    String? description,
  }) : fillColor =
           fillColor ??
           (borderColor?.withAlpha(128) ??
               MapDefaultColors.circle.withAlpha(128)),
       borderColor = borderColor ?? MapDefaultColors.circle,
       borderWidth = (borderWidth ?? 2.0).toDouble(),
       super(visible: visible ?? true, description: description ?? "");

  /// Generates a [CircleMarker] from a [CircleEntry] to be used in a [CircleLayer].
  @override
  CircleMarker get flutterMapFeature => CircleMarker(
    useRadiusInMeter: true,
    point: center,
    radius: radius,
    borderColor: borderColor,
    borderStrokeWidth: borderWidth,
    color: fillColor.withAlpha(128),
  );

  @override
  GeoJSONPoint get geoJasonObject =>
      throw GeoJSONPoint([center.longitude, center.latitude]);

  @override
  GeoJSONFeature toGeoJsonFeature(String layerName, String layerId) =>
      GeoJSONFeature(
        geoJasonObject,
        properties: {
          "name": name,
          "radius": radius,
          "fill": fillColor.toHexString(),
          "stroke": borderColor.toHexString(),
          "stroke-width": borderWidth,
          "visible": visible,
          "layer-id": layerId,
          "layer-name": layerName,
          "description": description,
          "subtype": "circle",
        },
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
class MapLayerEntry {
  final EntryType type;
  String name;
  final List<FlutterMapEntry> items;
  final bool isDefault;
  final String id;

  MapLayerEntry({
    required this.type,
    required this.name,
    List<FlutterMapEntry>? items,
    this.isDefault = false,
  }) : items = items ?? [],
       id = uuid.v4();

  bool get isEmpty => items.isEmpty;

  MapLayerEntry.marker({
    required String name,
    List<FlutterMapEntry>? items,
    bool isMain = false,
  }) : this(
         type: EntryType.marker,
         name: name,
         items: items,
         isDefault: isMain,
       );

  MapLayerEntry.polygon({
    required String name,
    List<FlutterMapEntry>? items,
    bool isMain = false,
  }) : this(
         type: EntryType.polygon,
         name: name,
         items: items,
         isDefault: isMain,
       );

  MapLayerEntry.polyline({
    required String name,
    List<FlutterMapEntry>? items,
    bool isMain = false,
  }) : this(
         type: EntryType.polyline,
         name: name,
         items: items,
         isDefault: isMain,
       );

  MapLayerEntry.circle({
    required String name,
    List<FlutterMapEntry>? items,
    bool isMain = false,
  }) : this(
         type: EntryType.circle,
         name: name,
         items: items,
         isDefault: isMain,
       );

  /// Converts all [FlutterMapEntry] sub classes in [items] to a map layer which will be added to the [FlutterMap] children.
  dynamic toFlutterMapObject() {
    List<FlutterMapEntry> filteredItems = items
        .where((element) => element.visible)
        .toList();
    List<String> namesList = items.map((e) => e.name).toList();
    assert(
      namesList.toSet().length == namesList.length,
      "There shouldnt be duplicate names inside a layer.",
    );
    switch (type) {
      case EntryType.marker:
        assert(filteredItems.every((e) => e is MarkerEntry));
        final markers = filteredItems.cast<MarkerEntry>();
        return MarkerLayer(
          markers: markers.map((marker) => marker.flutterMapFeature).toList(),
        );

      case EntryType.polyline:
        assert(filteredItems.every((e) => e is PolylineEntry));
        final lines = filteredItems.cast<PolylineEntry>();
        return PolylineLayer(
          polylines: lines.map((line) => line.flutterMapFeature).toList(),
        );

      case EntryType.polygon:
        assert(filteredItems.every((e) => e is PolygonEntry));
        final polys = filteredItems.cast<PolygonEntry>();
        return PolygonLayer(
          polygons: polys.map((poly) => poly.flutterMapFeature).toList(),
        );

      case EntryType.circle:
        assert(filteredItems.every((e) => e is CircleEntry));
        final circles = filteredItems.cast<CircleEntry>();
        return CircleLayer(
          circles: circles.map((circle) => circle.flutterMapFeature).toList(),
        );
    }
  }

  GeoJSONFeatureCollection toGeoJsonFeatureCollection() =>
      GeoJSONFeatureCollection(
        items.map((e) => e.toGeoJsonFeature(name, id)).toList(),
      );
}
