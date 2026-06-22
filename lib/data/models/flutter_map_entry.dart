import 'dart:math' as math;

import 'package:geoink/core/utils/coordinates_tools.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:latlong2/latlong.dart';
import 'package:geoink/core/utils/map_colors.dart';
import 'package:unique_list/unique_list.dart';
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

  @override
  bool operator ==(Object other) {
    return other is FlutterMapEntry ? this.name.trim() == other.name.trim()  : super == other; 
  }
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
    super.name = "marker",
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
    child: Align(alignment: AlignmentGeometry.topCenter,child: Icon(Icons.location_pin, size: 40, color: color)),
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

  @override
  String toString() {
    return "MarkerEntry : $coordinate";
  }
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
    super.name = "polygon",
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
    hitValue: HitReference(this)
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

  @override
  String toString() {
    return "PolygonEntry :\n$coordinates";
  }
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
    super.name = "polyline",
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
      Polyline(points: coordinates, strokeWidth: strokeWidth, color: color,hitValue: HitReference(this));

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

  @override
  String toString() {
    return "PolylineEntry :\n$coordinates";
  }
}

/// Keeps track of a [CircleMarker] feature that will be added to map layers later.
class CircleEntry extends FlutterMapEntry {
  final LatLng center;
  double radius;
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
    super.name = "circle",
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
    hitValue: HitReference(this)
  );

  @override
  GeoJSONPoint get geoJasonObject =>
      GeoJSONPoint([center.longitude, center.latitude]);

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

  @override
  String toString() {
    return "CircleEntry :\n$center [$radius]";
  }
}

/// Differant types of [MapLayer]
enum EntryType { Marker, Polygon, Polyline, Circle }

Map<EntryType, Type> entryTypeClasses = {
  EntryType.Circle: CircleEntry,
  EntryType.Marker: MarkerEntry,
  EntryType.Polygon: PolygonEntry,
  EntryType.Polyline: PolylineEntry,
};

/// Collection of [FlutterMapEntry] sub classes, which have the same type.
class MapLayer {
  String name;
  final UniqueList<FlutterMapEntry> items = UniqueList(strict: true);
  final bool isDefault;
  final String id;
  final EntryType entryType;

  MapLayer({
    required this.name,
    required this.entryType,
    this.isDefault = false,
  }) : id = uuid.v4();

  bool get isEmpty => items.isEmpty;

  @override
  bool operator ==(Object other) => other is MapLayer ? (this.name.trim() == other.name.trim()) : super == other;

  MapLayer copy() => MapLayer(name: name, entryType: entryType,isDefault: isDefault)..items.addAll(items);

  String _getUniqueName(String name) {
    var uniqueNamePattern = RegExp(r"^\s*" + name + r"\s*?(?:\s+\((\d+)\))?");
    List<String> namesList = items.map((e) => e.name).toList();
    if (namesList.any((e) => e.trim() == name.trim())) {
      int maxNum = namesList
          .map((e) {
            var match = uniqueNamePattern.firstMatch(e);
            if (match != null) {
              return int.parse(match.group(1) ?? "0");
            }
            return null;
          })
          .nonNulls
          .reduce(math.max);
      return "$name (${maxNum + 1})";
    }
    return name;
  }

  void add(FlutterMapEntry entry) {
    assert(entry.runtimeType == entryTypeClasses[entryType]);
    entry.name = _getUniqueName(entry.name);
    items.add(entry);
  }

  /// Converts all [FlutterMapEntry] sub classes in [items] to a map layer which will be added to the [FlutterMap] children.
  Widget toFlutterMapObject() {
    List<FlutterMapEntry> filteredItems = items
        .where((element) => element.visible)
        .toList();
    switch (entryType) {
      case EntryType.Marker:
        assert(filteredItems.every((e) => e is MarkerEntry));
        final markers = filteredItems.cast<MarkerEntry>();
        return MarkerLayer(
          markers: markers.map((marker) => marker.flutterMapFeature).toList(),
        );

      case EntryType.Polyline:
        assert(filteredItems.every((e) => e is PolylineEntry));
        final lines = filteredItems.cast<PolylineEntry>();
        return PolylineLayer(
          polylines: lines.map((line) => line.flutterMapFeature).toList(),
        );

      case EntryType.Polygon:
        assert(filteredItems.every((e) => e is PolygonEntry));
        final polys = filteredItems.cast<PolygonEntry>();
        return PolygonLayer(
          polygons: polys.map((poly) => poly.flutterMapFeature).toList(),
        );

      case EntryType.Circle:
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

Color? _stringToColor(String? text) {
  if (text == null) return null;
  text = text.trim();
  if (RegExp(
    r"^#?(?:[0-9A-F]{8}|[0-9A-F]{6})$",
    caseSensitive: false,
  ).hasMatch(text)) {
    text = text.replaceFirst("#", "").toUpperCase();
    return Color(int.parse("0x${text.length == 6 ? "88$text" : text}"));
  }
  return null;
}



class MapLayerList {
  final UniqueList<MapLayer> items = UniqueList(strict: true);

  MapLayerList() {}

  MapLayerList.withMainLayers() {
    items.addAll(
      EntryType.values.map(
        (type) => MapLayer(
          name: "${type.name} main",
          isDefault: true,
          entryType: type,
        ),
      ),
    );
  }

  MapLayerList copy({List<MapLayer>? newItems}) => MapLayerList()..items.addAll([...newItems ?? items]);
  MapLayerList deepCopy({List<MapLayer>? newItems}) => MapLayerList()..items.addAll([...newItems ?? items].map((e)=>e.copy()));

  GeoJSONFeatureCollection toGeoJsonFeatureCollection() {
    final allFeatures = items
        .expand((entry) => entry.toGeoJsonFeatureCollection().features)
        .toList();
    return GeoJSONFeatureCollection(allFeatures.nonNulls.toList());
  }

  MapLayer? getDefaultLayerEntryOrNull(EntryType type) => items.firstWhereOrNull(
      (element) => element.isDefault && element.entryType == type,
    );

  MapLayer createNewDefaultLayer(EntryType type) {
    var newLayer = MapLayer(
          name: "${type.name} main layer",
          isDefault: true, entryType: type,
        );
    items.add(newLayer);
    return newLayer;
  }

  MapLayer getDefaultLayerEntry(EntryType type) {
    MapLayer? layerEntry = getDefaultLayerEntryOrNull(type);
    return layerEntry == null ? createNewDefaultLayer(type) : layerEntry;
  }

  MapLayer getDefaultLayerEntryGeneric<T extends FlutterMapEntry>() {
    EntryType type = entryTypeClasses.keys.firstWhere((e)=> entryTypeClasses[e] == T);
    return getDefaultLayerEntry(type);
  }

  MapLayer? getLayerById(String? id) {
    return items.firstWhereOrNull((e) => e.id == id);
  }

  

  


  void addLayer(MapLayer layerEntry,) {
    try {
      items.add(layerEntry);
    } on DuplicateValueError {}
  }

  void addWithLayer<T extends FlutterMapEntry>(T entry, {MapLayer? layer}) {
    MapLayer mapLayer = layer ?? getDefaultLayerEntryGeneric<T>();
    mapLayer.add(entry);
  }

  void addFromGeoJsonObject(
    GeoJSONGeometry geoJson, {
    required Map<String, dynamic> properties,
    MapLayer? layer,
  }) {
    if (layer != null) {
      addLayer(layer);
    } else {
      layer = getLayerById(properties["layer-id"]);
    }
    String? name = properties["name"];
    final bool visible = properties["visible"] ?? true;
    final String? description = properties["description"];
    switch (geoJson.type) {
      case GeoJSONType.point:
        var geoJsonPoint = geoJson as GeoJSONPoint;
        if (properties["radius"] == null) {
          MapLayer entryLayer =
              layer ?? getDefaultLayerEntry(EntryType.Marker);
          entryLayer.add(
            MarkerEntry.withDefaults(
              name: name ?? "marker",
              coordinate: listToLatLng(geoJsonPoint.coordinates),
              color: _stringToColor(properties["color"]),
              visible: visible,
              description: description,
            ),
          );
        } else {
          MapLayer entryLayer = getDefaultLayerEntry(EntryType.Circle);
          entryLayer.add(
            CircleEntry.withDefaults(
              name: name ?? "circle",
              center: listToLatLng(geoJsonPoint.coordinates),
              radius: properties["radius"],
              fillColor: _stringToColor(properties["fill"]),
              borderColor: _stringToColor(properties["stroke"]),
              borderWidth: properties["stroke-width"],
              visible: visible,
              description: description,
            ),
          );
        }
        break;
      case GeoJSONType.multiPoint:
        var geoJsonMultiPoint = geoJson as GeoJSONMultiPoint;
        MapLayer entryLayer = getDefaultLayerEntry(EntryType.Marker);
        name ??= "marker";
        final Color? color = _stringToColor(properties["color"]);
        for (var polygonCoordinates in geoJsonMultiPoint.coordinates) {
          entryLayer.add(
            MarkerEntry.withDefaults(
              name: name,
              coordinate: listToLatLng(polygonCoordinates),
              color: color,
              visible: visible,
              description: description,
            ),
          );
        }
        break;
      case GeoJSONType.lineString:
        var geoJsonLineString = geoJson as GeoJSONLineString;
        MapLayer entryLayer = getDefaultLayerEntry(EntryType.Polyline);
        entryLayer.add(
          PolylineEntry.withDefaults(
            name: name ?? "polyline",
            coordinates: multipleListToLatLng(geoJsonLineString.coordinates),
            color: _stringToColor(properties["stroke"]),
            strokeWidth: properties["stroke-width"],
            visible: visible,
            description: description,
          ),
        );
        break;
      case GeoJSONType.multiLineString:
        var geoJsonMultiLineString = geoJson as GeoJSONMultiLineString;
        MapLayer entryLayer = getDefaultLayerEntry(EntryType.Polyline);
        name ??= "polyline";
        final Color? stroke = _stringToColor(properties["stroke"]);
        for (var polylineCoordinates in geoJsonMultiLineString.coordinates) {
          entryLayer.add(
            PolylineEntry.withDefaults(
              name: name,
              coordinates: multipleListToLatLng(polylineCoordinates),
              color: stroke,
              strokeWidth: properties["stroke-width"],
              visible: visible,
              description: description,
            ),
          );
        }
        break;
      case GeoJSONType.polygon:
        var geoJsonPolygon = geoJson as GeoJSONPolygon;
        MapLayer entryLayer = getDefaultLayerEntry(EntryType.Polygon);
        List<List<LatLng>>? coordinates = geoJsonPolygon.coordinates
            .map((e) => multipleListToLatLng(e))
            .toList();
        List<LatLng>? polygonMainCoordinates = coordinates.length == 1
            ? coordinates.first
            : findMaxCoordinatesArea(coordinates);
        entryLayer.add(
          PolygonEntry.withDefaults(
            name: name ?? "polygon",
            coordinates: polygonMainCoordinates,
            fillColor: _stringToColor(properties["fill"]),
            borderColor: _stringToColor(properties["stroke"]),
            borderWidth: properties["stroke-width"],
            visible: visible,
            description: description,
          ),
        );
        break;
      case GeoJSONType.multiPolygon:
        var geoJsonMultiPolygon = geoJson as GeoJSONMultiPolygon;
        MapLayer entryLayer = getDefaultLayerEntry(EntryType.Polygon);
        name ??= "polygon";
        final Color? stroke = _stringToColor(properties["stroke"]);
        final Color? fill = _stringToColor(properties["fill"]);
        for (var polygonCoordinates in geoJsonMultiPolygon.coordinates) {
          List<List<LatLng>>? coordinates = polygonCoordinates
              .map((e) => multipleListToLatLng(e))
              .toList();
          List<LatLng>? polygonMainCoordinates = coordinates.length == 1
              ? coordinates.first
              : findMaxCoordinatesArea(coordinates);
          entryLayer.add(
            PolygonEntry.withDefaults(
              name: name,
              coordinates: polygonMainCoordinates,
              fillColor: fill,
              borderColor: stroke,
              borderWidth: properties["stroke-width"],
              visible: visible,
              description: description,
            ),
          );
        }
        break;
      default:
        throw AssertionError("Geomatry not in supported types.");
    }
  }

  Iterable<Widget> getMapChildren() {
    return items.map((e) => e.toFlutterMapObject());
  }
} 


class HitReference {
  HitReference(this.entry,{this.layer}) {}
  MapLayer? layer;
  FlutterMapEntry entry;
}