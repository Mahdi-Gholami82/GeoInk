import 'package:mapify/data/models/coordinates_sheet_data.dart';
import 'package:mapify/data/models/flutter_map_entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:collection/collection.dart';

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

  MapLayerEntry _getDefaultLayerEntry(EntryType type) {
    MapLayerEntry layerEntry = state.firstWhere(
      (element) => element.isDefault,
      orElse: () {
        MapLayerEntry newlayerEntry = MapLayerEntry(
          name: "${type.name} main layer",
          type: type,
          isDefault: true,
        );
        addMapLayerEntry(layerEntry: newlayerEntry);
        return newlayerEntry;
      },
    );
    return layerEntry;
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
    MapLayerEntry entryLayer =
        result.layer ?? _getDefaultLayerEntry(EntryType.marker);
    int count = entryLayer.items.length;
    entryLayer.items.add(
      MarkerEntry(
        coordinate: result.coordinates.first,
        name: result.name ?? "marker-layer-${count++}",
      ),
    );
    _forceRebuild();
  }

  void addPolyLine(InputCoordinatesSheetResult result, {MapLayerEntry? layer}) {
    MapLayerEntry entryLayer =
        layer ?? _getDefaultLayerEntry(EntryType.polyline);
    int count = entryLayer.items.length;
    entryLayer.items.add(
      PolylineEntry(
        name: result.name ?? "polyline-${count++}",
        points: result.coordinates.toList(),
      ),
    );
    _forceRebuild();
  }

  void addPolygon(InputCoordinatesSheetResult result, {MapLayerEntry? layer}) {
    MapLayerEntry entryLayer =
        layer ?? _getDefaultLayerEntry(EntryType.polygon);
    int count = entryLayer.items.length;
    entryLayer.items.add(
      PolygonEntry(
        name: result.name ?? "polygon-${count++}",
        points: result.coordinates.toList(),
        borderColor: result.color,
        fillColor: result.color.withAlpha(128),
      ),
    );
    _forceRebuild();
  }

  void addCircle(InputCoordinatesSheetResult result, {MapLayerEntry? layer}) {
    MapLayerEntry entryLayer = layer ?? _getDefaultLayerEntry(EntryType.circle);
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
