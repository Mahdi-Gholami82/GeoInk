import 'package:collection/collection.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapify/core/utils/coordinates_tools.dart';
import 'package:mapify/data/models/coordinates_sheet_data.dart';
import 'package:mapify/data/models/flutter_map_entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_tiles_provider.g.dart';

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
    int count = result.layer.items.length;
    result.layer.items.add(
      MarkerEntry(
        coordinate: result.coordinates.first,
        name: result.name ?? "marker-${count++}",
        color: result.color,
      ),
    );
    forceRebuild();
  }

  void addPolyLine(InputCoordinatesSheetResult result) {
    int count = result.layer.items.length;
    result.layer.items.add(
      PolylineEntry(
        name: result.name ?? "polyline-${count++}",
        coordinates: result.coordinates,
        color: result.color,
      ),
    );
    forceRebuild();
  }

  void addPolygon(InputCoordinatesSheetResult result) {
    int count = result.layer.items.length;
    var coordinates = result.coordinates;
    result.layer.items.add(
      PolygonEntry(
        name: result.name ?? "polygon-${count++}",
        coordinates: processPolygonLatlngs(coordinates),
        borderColor: result.color,
        fillColor: result.color.withAlpha(128),
      ),
    );
    forceRebuild();
  }

  void addCircle(InputCoordinatesSheetResult result) {
    int count = result.layer.items.length;
    result.layer.items.add(
      CircleEntry(
        name: result.name ?? "circle-${count++}",
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

    switch (geoJson.type) {
      case GeoJSONType.point:
        var geoJsonPoint = geoJson as GeoJSONPoint;
        if (properties["radius"] != null) {
          MapLayerEntry entryLayer =
              layer ?? getDefaultLayerEntry(EntryType.marker);
          int count = entryLayer.items.length;
          entryLayer.items.add(
            MarkerEntry.withDefaults(
              name: properties["name"] ?? "marker-${count++}",
              coordinate: toLatLng(geoJsonPoint.coordinates),
              color: properties["color"],
              visible: properties["visible"],
              description: properties["description"],
            ),
          );
        } else {
          MapLayerEntry entryLayer = getDefaultLayerEntry(EntryType.circle);
          int count = entryLayer.items.length;
          entryLayer.items.add(
            CircleEntry.withDefaults(
              name: properties["name"] ?? "marker-${count++}",
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
        int count = entryLayer.items.length;
        entryLayer.items.addAll(
          geoJsonMultiPoint.coordinates.map(
            (e) => MarkerEntry.withDefaults(
              name: "marker-${count++}",
              coordinate: toLatLng(e),
              color: properties["color"],
              visible: properties["visible"],
              description: properties["description"],
            ),
          ),
        );
        break;
      case GeoJSONType.lineString:
        var geoJsonLineString = geoJson as GeoJSONLineString;
        MapLayerEntry entryLayer = getDefaultLayerEntry(EntryType.polyline);
        int count = entryLayer.items.length;
        entryLayer.items.add(
          PolylineEntry.withDefaults(
            name: properties["name"] ?? "polyline-${count++}",
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
        int count = entryLayer.items.length;
        entryLayer.items.addAll(
          geoJsonMultiLineString.coordinates.map(
            (e) => PolylineEntry.withDefaults(
              name: properties["name"] ?? "polyline-${count++}",
              coordinates: toListLatLng(e),
              color: properties["color"],
              visible: properties["visible"],
              strokeWidth: properties["stroke_width"],
              description: properties["description"],
            ),
          ),
        );
        break;
      case GeoJSONType.polygon:
        var geoJsonPolygon = geoJson as GeoJSONPolygon;
        MapLayerEntry entryLayer = getDefaultLayerEntry(EntryType.polygon);
        int count = entryLayer.items.length;
        List<LatLng>? coordinates = geoJsonPolygon.coordinates
            .map((e) => toListLatLng(e))
            .firstWhereOrNull((e) => isCounterClockwise(e));
        if (coordinates == null) break;
        entryLayer.items.add(
          PolygonEntry.withDefaults(
            name: properties["name"] ?? "polygon-${count++}",
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
        int count = entryLayer.items.length;
        for (var polygonCoordinate in geoJsonMultiPolygon.coordinates) {
          List<LatLng>? coordinates = polygonCoordinate
              .map((e) => toListLatLng(e))
              .firstWhereOrNull((e) => isCounterClockwise(e));
          if (coordinates == null) continue;
          entryLayer.items.add(
            PolygonEntry.withDefaults(
              name: properties["name"] ?? "polygon-${count++}",
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
      case GeoJSONType.geometryCollection:
        var geoJsonGeomatryCollection = geoJson as GeoJSONGeometryCollection;
        for (var geomatry in geoJsonGeomatryCollection.geometries) {
          addFromGeoJsonObject(geomatry, properties: properties, layer: layer);
        }
      default:
        throw AssertionError("Geomatry not in supported types.");
    }
  }
}
