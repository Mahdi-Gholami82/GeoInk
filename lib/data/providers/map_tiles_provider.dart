import 'dart:math' as math;

import 'package:collection/collection.dart';
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

@Riverpod(keepAlive: true)
class TileEntriesNotifier extends _$TileEntriesNotifier {
  @override
  List<MapLayerEntry> build() {
    return [];
  }

  void forceRebuild() {
    state = [...state];
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

  MapLayerEntry? getLayerById(String id) {
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
    LatLng toLatLng(List c) => LatLng(c[1], c[0]);
    List<LatLng> toListLatLng(List<List<double>> coordinates) =>
        coordinates.map((e) => toLatLng(e)).toList();
    if (layer != null) {
      addMapLayerEntry(layerEntry: layer, ignoreIfExists: true);
    } else {
      layer = getLayerById(properties["id"]);
    }
    String? name = properties["name"];
    switch (geoJson.type) {
      case GeoJSONType.point:
        var geoJsonPoint = geoJson as GeoJSONPoint;
        if (properties["radius"] == null) {
          MapLayerEntry entryLayer =
              layer ?? getDefaultLayerEntry(EntryType.marker);
          entryLayer.items.add(
            MarkerEntry.withDefaults(
              name: _getUniqueName(name ?? "marker", entryLayer),
              coordinate: toLatLng(geoJsonPoint.coordinates),
              color: properties["color"],
              visible: properties["visible"],
              description: properties["description"],
            ),
          );
        } else {
          MapLayerEntry entryLayer = getDefaultLayerEntry(EntryType.circle);
          entryLayer.items.add(
            CircleEntry.withDefaults(
              name: _getUniqueName(name ?? "circle", entryLayer),
              center: toLatLng(geoJsonPoint.coordinates),
              radius: properties["radius"],
              fillColor: properties["color"],
              visible: properties["visible"],
              description: properties["description"],
            ),
          );
        }
        break;
      case GeoJSONType.multiPoint:
        var geoJsonMultiPoint = geoJson as GeoJSONMultiPoint;
        MapLayerEntry entryLayer = getDefaultLayerEntry(EntryType.marker);
        name ??= "marker";
        for (var polygonCoordinates in geoJsonMultiPoint.coordinates) {
          entryLayer.items.add(
            MarkerEntry.withDefaults(
              name: _getUniqueName(name, entryLayer),
              coordinate: toLatLng(polygonCoordinates),
              color: properties["color"],
              visible: properties["visible"],
              description: properties["description"],
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
            coordinates: toListLatLng(geoJsonLineString.coordinates),
            color: properties["color"],
            visible: properties["visible"],
            strokeWidth: properties["stroke_width"],
            description: properties["description"],
          ),
        );
        break;
      case GeoJSONType.multiLineString:
        var geoJsonMultiLineString = geoJson as GeoJSONMultiLineString;
        MapLayerEntry entryLayer = getDefaultLayerEntry(EntryType.polyline);
        name ??= "polyline";
        for (var polylineCoordinates in geoJsonMultiLineString.coordinates) {
          entryLayer.items.add(
            PolylineEntry.withDefaults(
              name: _getUniqueName(name, entryLayer),
              coordinates: toListLatLng(polylineCoordinates),
              color: properties["color"],
              visible: properties["visible"],
              strokeWidth: properties["stroke_width"],
              description: properties["description"],
            ),
          );
        }
        break;
      case GeoJSONType.polygon:
        var geoJsonPolygon = geoJson as GeoJSONPolygon;
        MapLayerEntry entryLayer = getDefaultLayerEntry(EntryType.polygon);
        List<LatLng>? coordinates = geoJsonPolygon.coordinates
            .map((e) => toListLatLng(e))
            .firstWhereOrNull((e) => isCounterClockwise(e));
        if (coordinates == null) break;
        entryLayer.items.add(
          PolygonEntry.withDefaults(
            name: _getUniqueName(name ?? "polygon", entryLayer),
            coordinates: coordinates,
            fillColor: properties["fill_color"],
            visible: properties["visible"],
            borderColor: properties["border_color"],
            description: properties["description"],
            borderWidth: properties["border_width"],
          ),
        );
        break;
      case GeoJSONType.multiPolygon:
        var geoJsonMultiPolygon = geoJson as GeoJSONMultiPolygon;
        MapLayerEntry entryLayer = getDefaultLayerEntry(EntryType.polygon);
        name ??= "polygon";
        for (var polygonCoordinates in geoJsonMultiPolygon.coordinates) {
          List<LatLng>? coordinates = polygonCoordinates
              .map((e) => toListLatLng(e))
              .firstWhereOrNull((e) => isCounterClockwise(e));
          if (coordinates == null) continue;
          entryLayer.items.add(
            PolygonEntry.withDefaults(
              name: _getUniqueName(name, entryLayer),
              coordinates: coordinates,
              fillColor: properties["fill_color"],
              visible: properties["visible"],
              borderColor: properties["border_color"],
              description: properties["description"],
              borderWidth: properties["border_width"],
            ),
          );
        }
        break;
      default:
        throw AssertionError("Geomatry not in supported types.");
    }
  }
}
