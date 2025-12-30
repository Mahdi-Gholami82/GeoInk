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
        return newlayerEntry;
      },
    );
    return layerEntry;
  }

  MapLayerEntry _getLayerEntry(MapLayerEntry? layer, EntryType type) {
    MapLayerEntry entryLayer = layer ?? getDefaultLayerEntry(type);
    addMapLayerEntry(layerEntry: entryLayer, ignoreIfExists: true);
    return entryLayer;
  }

  MapLayerEntry getLayerByIdOrMain(String id, EntryType type) {
    return state.firstWhereOrNull((e) => e.id == id) ??
        getDefaultLayerEntry(type);
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
    MapLayerEntry entryLayer = _getLayerEntry(result.layer, EntryType.marker);
    int count = entryLayer.items.length;
    entryLayer.items.add(
      MarkerEntry(
        coordinate: result.coordinates.first,
        name: result.name ?? "marker-${count++}",
        color: result.color,
      ),
    );
    forceRebuild();
  }

  void addPolyLine(InputCoordinatesSheetResult result) {
    MapLayerEntry entryLayer = _getLayerEntry(result.layer, EntryType.polyline);
    int count = entryLayer.items.length;
    entryLayer.items.add(
      PolylineEntry(
        name: result.name ?? "polyline-${count++}",
        coordinates: result.coordinates,
        color: result.color,
      ),
    );
    forceRebuild();
  }

  void addPolygon(InputCoordinatesSheetResult result) {
    MapLayerEntry entryLayer = _getLayerEntry(result.layer, EntryType.polygon);
    int count = entryLayer.items.length;
    var coordinates = result.coordinates;
    entryLayer.items.add(
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
    MapLayerEntry entryLayer = _getLayerEntry(result.layer, EntryType.circle);
    int count = entryLayer.items.length;
    entryLayer.items.add(
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
    GeoJSONGeometry geoJson,
    MapLayerEntry layer,
    Map<String, dynamic> properties,
  ) {
    LatLng toLatLng(List c) => LatLng(c[1], c[0]);
    List<LatLng> toListLatLng(List<List<double>> coordinates) =>
        coordinates.map((e) => toLatLng(e)).toList();

    switch (geoJson.type) {
      case GeoJSONType.point:
        assert(layer.type == EntryType.marker);
        var geoJsonPoint = geoJson as GeoJSONPoint;
        if (properties["radius"] != null) {
          MapLayerEntry entryLayer = _getLayerEntry(layer, EntryType.marker);
          int count = entryLayer.items.length;
          layer.items.add(
            MarkerEntry.withDefaults(
              name: properties["name"] ?? "marker-${count++}",
              coordinate: toLatLng(geoJsonPoint.coordinates),
              color: properties["color"],
              visible: properties["visible"],
              description: properties["description"],
            ),
          );
        } else {
          MapLayerEntry entryLayer = _getLayerEntry(layer, EntryType.circle);
          int count = entryLayer.items.length;
          layer.items.add(
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
        assert(layer.type == EntryType.marker);
        var geoJsonMultiPoint = geoJson as GeoJSONMultiPoint;
        MapLayerEntry entryLayer = _getLayerEntry(layer, EntryType.marker);
        int count = entryLayer.items.length;
        layer.items.addAll(
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
        assert(layer.type == EntryType.polyline);
        var geoJsonLineString = geoJson as GeoJSONLineString;
        MapLayerEntry entryLayer = _getLayerEntry(layer, EntryType.polyline);
        int count = entryLayer.items.length;
        layer.items.add(
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
        MapLayerEntry entryLayer = _getLayerEntry(layer, EntryType.polyline);
        int count = entryLayer.items.length;
        layer.items.addAll(
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
        MapLayerEntry entryLayer = _getLayerEntry(layer, EntryType.polygon);
        int count = entryLayer.items.length;
        List<LatLng>? coordinates = geoJsonPolygon.coordinates
            .map((e) => toListLatLng(e))
            .firstWhereOrNull((e) => isCounterClockwise(e));
        if (coordinates == null) break;
        layer.items.add(
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
        MapLayerEntry entryLayer = _getLayerEntry(layer, EntryType.polygon);
        int count = entryLayer.items.length;
        for (var polygonCoordinate in geoJsonMultiPolygon.coordinates) {
          List<LatLng>? coordinates = polygonCoordinate
              .map((e) => toListLatLng(e))
              .firstWhereOrNull((e) => isCounterClockwise(e));
          if (coordinates == null) continue;
          layer.items.add(
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
      default:
        throw AssertionError("Geomatry not in supported types.");
    }
  }
}
