import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geoink/core/utils/unique_name_in_list.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:latlong2/latlong.dart';
import 'package:geoink/core/utils/map_colors.dart';
import 'package:unique_list/unique_list.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

typedef LayerEntryMap = Map<MapLayer, List<FlutterMapEntry>>;

/// Data models to keep track of map features or layers.

/// Base class for all Entries which are used to generate map features.
abstract class FlutterMapEntry {
  String name;
  String description;
  bool visible;

  /// will be overridden in each entry subclass.
  get flutterMapFeature;
  GeoJSONGeometry get geoJasonObject;
  GeoJSONFeature toGeoJsonFeature(String layerName);

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
    return other is FlutterMapEntry
        ? this.name.trim() == other.name.trim()
        : super == other;
  }
}

/// Keeps track of a [Marker] feature that will be added to map layers later.
class MarkerEntry extends FlutterMapEntry {
  LatLng point;
  Color color;

  MarkerEntry({
    required super.name,
    required this.point,
    this.color = MapDefaultColors.marker,
    super.visible,
    super.description,
  });

  MarkerEntry.withDefaults({
    super.name = "marker",
    required this.point,
    Color? color,
    bool? visible,
    String? description,
  }) : color = color ?? MapDefaultColors.marker,
       super(visible: visible ?? true, description: description ?? "");

  /// Generates a [Marker] from a [MarkerEntry] to be used in a [MarkerLayer].
  @override
  Marker get flutterMapFeature => Marker(
    point: point,
    width: 64,
    height: 64,
    child: Align(
      alignment: AlignmentGeometry.topCenter,
      child: Icon(Icons.location_pin, size: 40, color: color),
    ),
  );

  @override
  GeoJSONPoint get geoJasonObject =>
      GeoJSONPoint([point.longitude, point.latitude]);

  @override
  GeoJSONFeature toGeoJsonFeature(String layerName) => GeoJSONFeature(
    geoJasonObject,
    properties: {
      "name": name,
      "color": color.toHexString(),
      "visible": visible,
      "layer-name": layerName,
      "description": description,
    },
  );

  @override
  String toString() {
    return "MarkerEntry: $name\npoint: $point";
  }
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
    this.fillColor = MapDefaultColors.polygon,
    Color? borderColor,
    this.borderWidth = 2.0,
    super.description,
    super.visible,
  }) : borderColor = borderColor ?? MapDefaultColors.polygon.withAlpha(128);

  PolygonEntry.withDefaults({
    super.name = "polygon",
    required this.points,
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
    points: points,
    borderColor: borderColor,
    borderStrokeWidth: borderWidth,
    color: fillColor,
    hitValue: HitReference(this),
  );

  @override
  GeoJSONPolygon get geoJasonObject {
    return GeoJSONPolygon([
      points.map((p) => [p.longitude, p.latitude]).toList(),
    ]);
  }

  @override
  GeoJSONFeature toGeoJsonFeature(String layerName) => GeoJSONFeature(
    geoJasonObject,
    properties: {
      "name": name,
      "fill": fillColor.toHexString(),
      "stroke": borderColor.toHexString(),
      "stroke-width": borderWidth,
      "visible": visible,
      "layer-name": layerName,
      "description": description,
    },
  );

  @override
  String toString() {
    return "PolygonEntry: $name\nnumber of points: ${points.length}";
  }
}

/// Keeps track of a [Polyline] feature that will be added to map layers later.
class PolylineEntry extends FlutterMapEntry {
  List<LatLng> points;
  Color color;
  double strokeWidth;

  PolylineEntry({
    required super.name,
    required this.points,
    this.color = MapDefaultColors.polyline,
    this.strokeWidth = 3.0,
    super.visible,
    super.description,
  });

  PolylineEntry.withDefaults({
    super.name = "polyline",
    required this.points,
    Color? color,
    num? strokeWidth,
    bool? visible,
    String? description,
  }) : color = color ?? MapDefaultColors.polyline,
       strokeWidth = (strokeWidth ?? 2.0).toDouble(),
       super(visible: visible ?? true, description: description ?? "");

  /// Generates a [Polyline] from a [PolylineEntry] to be used in a [PolylineLayer].
  @override
  Polyline get flutterMapFeature => Polyline(
    points: points,
    strokeWidth: strokeWidth,
    color: color,
    hitValue: HitReference(this),
  );

  @override
  GeoJSONLineString get geoJasonObject =>
      GeoJSONLineString(points.map((p) => [p.longitude, p.latitude]).toList());

  @override
  GeoJSONFeature toGeoJsonFeature(String layerName) => GeoJSONFeature(
    geoJasonObject,
    properties: {
      "name": name,
      "stroke": color.toHexString(),
      "stroke-width": strokeWidth,
      "visible": visible,
      "layer-name": layerName,
      "description": description,
    },
  );

  @override
  String toString() {
    return "PolylineEntry: $name\nnumber of points: ${points.length}";
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
    hitValue: HitReference(this),
  );

  @override
  GeoJSONPoint get geoJasonObject =>
      GeoJSONPoint([center.longitude, center.latitude]);

  @override
  GeoJSONFeature toGeoJsonFeature(String layerName) => GeoJSONFeature(
    geoJasonObject,
    properties: {
      "name": name,
      "radius": radius,
      "fill": fillColor.toHexString(),
      "stroke": borderColor.toHexString(),
      "stroke-width": borderWidth,
      "visible": visible,
      "layer-name": layerName,
      "description": description,
      "subtype": "circle",
    },
  );

  @override
  String toString() {
    return "CircleEntry: $name\ncenter: $center radius: $radius";
  }
}

/// Differant types of [MapLayer]
enum EntryType {
  polygon("Polygon", PolygonEntry),
  polyline("Polyline", PolylineEntry),
  circle("Circle", CircleEntry),
  marker("Marker", MarkerEntry);

  const EntryType(this.name, this.type) : mainLayerName = "${name} main";
  final String name;
  final String mainLayerName;
  final Type type;

  static EntryType fromType(Type type) {
    return EntryType.values.firstWhere(
      (e) => e.type == type,
      orElse: () =>
          throw ArgumentError("Invalid type: $type for FlutterMapEntry"),
    );
  }
}

/// Collection of [FlutterMapEntry] sub classes, which have the same type.
class MapLayer {
  String name;
  final UniqueList<FlutterMapEntry> items = UniqueList.strict();
  final bool isMain;
  final EntryType entryType;
  bool isInvalid = false;

  MapLayer({required this.name, required this.entryType, this.isMain = false});

  bool get isEmpty => items.isEmpty;
  int get length => items.length;
  List<String> get namesList => items.map((e) => e.name).toList();

  @override
  bool operator ==(Object other) => other is MapLayer
      ? (this.name.trim() == other.name.trim())
      : super == other;

  MapLayer copy() =>
      MapLayer(name: name, entryType: entryType, isMain: isMain)
        ..items.addAll(items);

  String getUniqueName(String name) {
    return getUniqueNameFromTargets(name, namesList);
  }

  void add(FlutterMapEntry entry) {
    assert(entry.runtimeType == entryType.type);
    items.add(entry);
  }

  void addAll(List<FlutterMapEntry> entries) {
    assert(entries.every((e) => e.runtimeType == entryType.type));
    items.addAll(entries);
  }

  void uniqifyName(FlutterMapEntry entry) {
    assert(entry.runtimeType == entryType.type);
    entry.name = getUniqueName(entry.name);
  }

  void addUnique(FlutterMapEntry entry) {
    uniqifyName(entry);
    items.add(entry);
  }

  void addAllUnique(List<FlutterMapEntry> entries) {
    Map<String, int> preNamesMax = {};
    List<String> names = namesList;
    for (var entry in entries) {
      int? preMax = preNamesMax[entry.name];
      int maxNum = 0;
      if (preMax == null) {
        maxNum = getUniqueMaxNum(entry.name, names);
        if (maxNum == 0) {
          items.add(entry);
          continue;
        }
      } else {
        maxNum = preMax;
      }
      maxNum++;
      preNamesMax[entry.name] = maxNum;
      entry.name = "${entry.name} (${maxNum})";
      items.add(entry);
    }
  }

  /// Converts all [FlutterMapEntry] sub classes in [items] to a map layer which will be added to the [FlutterMap] children.
  Widget toFlutterMapObject() {
    List<FlutterMapEntry> filteredItems = items
        .where((element) => element.visible)
        .toList();
    switch (entryType) {
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
        items.map((e) => e.toGeoJsonFeature(name)).toList(),
      );
}

class MapLayerList {
  final UniqueList<MapLayer> items = UniqueList(strict: true);

  MapLayerList() {}

  MapLayerList.withMainLayers() {
    items.addAll(
      EntryType.values.map(
        (type) =>
            MapLayer(name: type.mainLayerName, isMain: true, entryType: type),
      ),
    );
  }

  MapLayerList copy({List<MapLayer>? newItems}) =>
      MapLayerList()..items.addAll([...newItems ?? items]);
  MapLayerList deepCopy({List<MapLayer>? newItems}) =>
      MapLayerList()..items.addAll([...newItems ?? items].map((e) => e.copy()));

  GeoJSONFeatureCollection toGeoJsonFeatureCollection() {
    final allFeatures = items
        .expand((entry) => entry.toGeoJsonFeatureCollection().features)
        .toList();
    return GeoJSONFeatureCollection(allFeatures.nonNulls.toList());
  }

  MapLayer? getDefaultLayerEntryOrNull(EntryType type) =>
      items.firstWhereOrNull(
        (element) => element.isMain && element.entryType == type,
      );

  MapLayer createNewDefaultLayer(EntryType type) {
    var newLayer = MapLayer(
      name: type.mainLayerName,
      isMain: true,
      entryType: type,
    );
    items.add(newLayer);
    return newLayer;
  }

  MapLayer getDefaultLayerEntry(EntryType type) {
    MapLayer? layerEntry = getDefaultLayerEntryOrNull(type);
    return layerEntry == null ? createNewDefaultLayer(type) : layerEntry;
  }

  MapLayer getDefaultLayerEntryGeneric<T extends FlutterMapEntry>() {
    EntryType type = EntryType.fromType(T);
    return getDefaultLayerEntry(type);
  }

  void addLayer(MapLayer layerEntry) {
    try {
      items.add(layerEntry);
    } on DuplicateValueError {}
  }

  void addWithLayer<T extends FlutterMapEntry>(T entry, {MapLayer? layer}) {
    MapLayer mapLayer = layer ?? getDefaultLayerEntryGeneric<T>();
    mapLayer.addUnique(entry);
  }

  Iterable<Widget> getMapChildren() {
    return items.map((e) => e.toFlutterMapObject());
  }
}

class HitReference {
  HitReference(this.entry, {this.layer}) {}
  MapLayer? layer;
  FlutterMapEntry entry;
}
