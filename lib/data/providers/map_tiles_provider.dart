import 'package:geojson_vi/geojson_vi.dart';
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
        coordinates: result.coordinates.toList(),
        color: result.color,
      ),
    );
    _forceRebuild();
  }

  void addPolygon(InputCoordinatesSheetResult result) {
    MapLayerEntry entryLayer = _getLayerEntry(result.layer, EntryType.polygon);
    int count = entryLayer.items.length;
    entryLayer.items.add(
      PolygonEntry(
        name: result.name ?? "polygon-${count++}",
        coordinates: result.coordinates.toList(),
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
