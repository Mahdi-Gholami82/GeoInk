import 'package:mapify/data/models/coordinates_sheet_data.dart';
import 'package:mapify/data/models/flutter_map_entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:collection/collection.dart';

part 'map_tiles_provider.g.dart';

@riverpod
class TileEntriesNotifier extends _$TileEntriesNotifier {
  @override
  List<MapLayerEntry> build() {
    return [];
  }

  void _forceRebuild() {
    state = [...state];
  }

  MapLayerEntry? _getDefaultLayerEntry(EntryType type) {
    return state.firstWhereOrNull((element) => element.isMain);
  }

  MapLayerEntry addMapLayerEntry({
    required EntryType type,
    required String name,
    FlutterMapEntry? firstEntry,
  }) {
    assert(
      !state.any((entry) => entry.name == name),
      "Names of MapLayerEntry must be unique",
    );
    MapLayerEntry newEntry = MapLayerEntry(
      type: type,
      name: name,
      items: [if (firstEntry != null) firstEntry],
    );
    state.add(newEntry);
    return newEntry;
  }

  void addMarker(InputCoordinatesSheetResult result) {
    MapLayerEntry? entryLayer = _getDefaultLayerEntry(EntryType.marker);
    entryLayer ??= addMapLayerEntry(
      type: EntryType.marker,
      name: "main-marker",
    );
    int count = entryLayer.items.length;
    entryLayer.items.add(
      MarkerEntry(
        coordinate: result.coordinates.first,
        name: result.name ?? "marker-${count++}",
      ),
    );
    _forceRebuild();
  }

  void addPolyLine(InputCoordinatesSheetResult result) {
    MapLayerEntry? entries = _getDefaultLayerEntry(EntryType.polyline);
    entries ??= addMapLayerEntry(
      type: EntryType.polyline,
      name: "main-polyline",
    );
    int count = entries.items.length;
    entries.items.add(
      PolylineEntry(
        name: result.name ?? "polyline-${count++}",
        points: result.coordinates.toList(),
      ),
    );
    _forceRebuild();
  }

  void addPolygon(InputCoordinatesSheetResult result) {
    MapLayerEntry? entries = _getDefaultLayerEntry(EntryType.polygon);
    entries ??= addMapLayerEntry(type: EntryType.polygon, name: "main-polygon");
    int count = entries.items.length;
    entries.items.add(
      PolygonEntry(
        name: result.name ?? "polygon-${count++}",
        points: result.coordinates.toList(),
        borderColor: result.color,
        fillColor: result.color.withAlpha(128),
      ),
    );
    _forceRebuild();
  }

  void addCircle(InputCoordinatesSheetResult result) {
    MapLayerEntry? entries = _getDefaultLayerEntry(EntryType.circle);
    entries ??= addMapLayerEntry(type: EntryType.circle, name: "main-circle");
    int count = entries.items.length;
    entries.items.add(
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
