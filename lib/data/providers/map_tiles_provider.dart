import 'dart:math';

import 'package:geojson_vi/geojson_vi.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapify/core/utils/coordinates_tools.dart';
import 'package:mapify/data/models/coordinates_sheet_data.dart';
import 'package:mapify/data/models/flutter_map_entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_tiles_provider.g.dart';

bool _isCounterClockwise(List<LatLng> coordinates) {
  double sum = 0;

  for (int i = 0; i < coordinates.length; i++) {
    final p1 = coordinates[i];
    final p2 = coordinates[(i + 1) % coordinates.length];

    sum += (p2.longitude - p1.longitude) * (p2.latitude + p1.latitude);
  }
  return sum < 0;
}

double _calculateCenterLat(List<LatLng> points) =>
    points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;
double _calculateCenterLong(List<LatLng> points) =>
    points.map((p) => p.longitude).reduce((a, b) => a + b) / points.length;

List<LatLng> _sortClockwiseLatLng(List<LatLng> coordinates) {
  List<LatLng> coordinatesCopy = [...coordinates];
  if (!_isCounterClockwise(coordinatesCopy)) return coordinatesCopy;
  final centerLat = _calculateCenterLat(coordinates);
  final centerLng = _calculateCenterLong(coordinates);

  coordinatesCopy.sort((a, b) {
    final angleA = atan2(a.latitude - centerLat, a.longitude - centerLng);
    final angleB = atan2(b.latitude - centerLat, b.longitude - centerLng);
    return angleB.compareTo(angleA);
  });

  return coordinatesCopy;
}

List<LatLng> _sortCounterClockwiseLatLng(List<LatLng> coordinates) {
  List<LatLng> coordinatesCopy = [...coordinates];
  if (_isCounterClockwise(coordinatesCopy)) return coordinatesCopy;
  final centerLat = _calculateCenterLat(coordinates);
  final centerLng = _calculateCenterLong(coordinates);

  coordinatesCopy.sort((a, b) {
    final angleA = atan2(a.latitude - centerLat, a.longitude - centerLng);
    final angleB = atan2(b.latitude - centerLat, b.longitude - centerLng);
    return angleA.compareTo(angleB);
  });

  return coordinatesCopy;
}

List<LatLng> processPolygonLatlngs(List<LatLng> coordinates) {
  List<LatLng> sorted = _sortCounterClockwiseLatLng(
    latLngsEqual(coordinates.first, coordinates.last)
        ? coordinates.sublist(0, coordinates.length - 1)
        : coordinates,
  );
  if (!latLngsEqual(sorted.first, sorted.last)) sorted.add(sorted.first);
  return sorted;
}

@Riverpod(keepAlive: true)
class TileEntriesNotifier extends _$TileEntriesNotifier {
  @override
  List<MapLayerEntry> build() {
    return [];
  }

  void _forceRebuild() {
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

  void setConsumersState(void Function() fn) {
    fn();
    _forceRebuild();
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
        name: result.name ?? "marker-layer-${count++}",
        color: result.color,
      ),
    );
    _forceRebuild();
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
    _forceRebuild();
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
    _forceRebuild();
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
    _forceRebuild();
  }
}
