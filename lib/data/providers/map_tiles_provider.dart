import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapify/core/utils/coordinates_tools.dart';
import 'package:mapify/data/models/coordinates_sheet_data.dart';
import 'package:mapify/data/models/flutter_map_entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_tiles_provider.g.dart';

String _getUniqueName(String name, MapLayerEntry layer) {
  var uniqueNamePattern = RegExp(r"^\s*" + name + r"\s*?(?:\s+\((\d+)\))?");
  List<String> namesList = layer.items.map((e) => e.name).toList();
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

@Riverpod(keepAlive: true)
class TileEntriesNotifier extends _$TileEntriesNotifier {
  @override
  List<MapLayerEntry> build() {
    return [];
  }

  void forceRebuild() {
    state = [...state];
  }

  void updateState(List<MapLayerEntry> newLayers) {
    state = [...newLayers];
  }

  GeoJSONFeatureCollection toGeoJsonFeatureCollection() {
    final allFeatures = state
        .expand((entry) => entry.toGeoJsonFeatureCollection().features)
        .toList();
    return GeoJSONFeatureCollection(allFeatures.nonNulls.toList());
  }

  MapLayerEntry getDefaultLayerEntry(EntryType type) {
    MapLayerEntry layerEntry = state.firstWhere(
      (element) => element.isDefault && element.type == type,
      orElse: () {
        MapLayerEntry newlayerEntry = MapLayerEntry(
          name: "${type.name} main layer",
          type: type,
          isDefault: true,
        );
        state.add(newlayerEntry);
        return newlayerEntry;
      },
    );
    return layerEntry;
  }

  MapLayerEntry? getLayerById(String? id) {
    return state.firstWhereOrNull((e) => e.id == id);
  }

  void setConsumersState(void Function() fn) {
    fn();
    forceRebuild();
  }

  void addMapLayerEntry({
    required MapLayerEntry layerEntry,
    bool ignoreIfExists = false,
  }) {
    try {
      assert(
        !state.any((entry) => entry.name == layerEntry.name),
        "Names of MapLayerEntry must be unique",
      );
    } on AssertionError {
      if (ignoreIfExists) {
        return;
      }
      rethrow;
    }
    state.add(layerEntry);
  }

  void addMarker(InputCoordinatesSheetResult result) {
    result.layer.items.add(
      MarkerEntry(
        coordinate: result.coordinates.first,
        name: _getUniqueName(result.name ?? "marker", result.layer),
        color: result.color,
      ),
    );
    forceRebuild();
  }

  void addPolyLine(InputCoordinatesSheetResult result) {
    result.layer.items.add(
      PolylineEntry(
        name: _getUniqueName(result.name ?? "polyline", result.layer),
        coordinates: result.coordinates,
        color: result.color,
      ),
    );
    forceRebuild();
  }

  void addPolygon(InputCoordinatesSheetResult result) {
    var coordinates = result.coordinates;
    result.layer.items.add(
      PolygonEntry(
        name: _getUniqueName(result.name ?? "polygon", result.layer),
        coordinates: processPolygonLatlngs(coordinates),
        borderColor: result.color,
        fillColor: result.color.withAlpha(128),
      ),
    );
    forceRebuild();
  }

  void addCircle(InputCoordinatesSheetResult result) {
    result.layer.items.add(
      CircleEntry(
        name: _getUniqueName(result.name ?? "circle", result.layer),
        center: result.coordinates[0],
        radius: result.radius!,
        fillColor: result.color,
        borderColor: result.color.withAlpha(128),
      ),
    );
    forceRebuild();
  }

  void addFromGeoJsonObject(
    GeoJSONGeometry geoJson, {
    required Map<String, dynamic> properties,
    MapLayerEntry? layer,
  }) {
    if (layer != null) {
      addMapLayerEntry(layerEntry: layer, ignoreIfExists: true);
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
          MapLayerEntry entryLayer =
              layer ?? getDefaultLayerEntry(EntryType.marker);
          entryLayer.items.add(
            MarkerEntry.withDefaults(
              name: _getUniqueName(name ?? "marker", entryLayer),
              coordinate: listToLatLng(geoJsonPoint.coordinates),
              color: _stringToColor(properties["color"]),
              visible: visible,
              description: description,
            ),
          );
        } else {
          MapLayerEntry entryLayer = getDefaultLayerEntry(EntryType.circle);
          entryLayer.items.add(
            CircleEntry.withDefaults(
              name: _getUniqueName(name ?? "circle", entryLayer),
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
        MapLayerEntry entryLayer = getDefaultLayerEntry(EntryType.marker);
        name ??= "marker";
        final Color? color = _stringToColor(properties["color"]);
        for (var polygonCoordinates in geoJsonMultiPoint.coordinates) {
          entryLayer.items.add(
            MarkerEntry.withDefaults(
              name: _getUniqueName(name, entryLayer),
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
        MapLayerEntry entryLayer = getDefaultLayerEntry(EntryType.polyline);
        entryLayer.items.add(
          PolylineEntry.withDefaults(
            name: _getUniqueName(name ?? "polyline", entryLayer),
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
        MapLayerEntry entryLayer = getDefaultLayerEntry(EntryType.polyline);
        name ??= "polyline";
        final Color? stroke = _stringToColor(properties["stroke"]);
        for (var polylineCoordinates in geoJsonMultiLineString.coordinates) {
          entryLayer.items.add(
            PolylineEntry.withDefaults(
              name: _getUniqueName(name, entryLayer),
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
        MapLayerEntry entryLayer = getDefaultLayerEntry(EntryType.polygon);
        List<List<LatLng>>? coordinates = geoJsonPolygon.coordinates
            .map((e) => multipleListToLatLng(e))
            .toList();
        List<LatLng>? polygonMainCoordinates = coordinates.length == 1
            ? coordinates.first
            : findMaxCoordinatesArea(coordinates);
        entryLayer.items.add(
          PolygonEntry.withDefaults(
            name: _getUniqueName(name ?? "polygon", entryLayer),
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
        MapLayerEntry entryLayer = getDefaultLayerEntry(EntryType.polygon);
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
          entryLayer.items.add(
            PolygonEntry.withDefaults(
              name: _getUniqueName(name, entryLayer),
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
}
