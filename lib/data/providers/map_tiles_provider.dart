import 'package:flutter/material.dart';
import 'package:mapify/data/models/coordinates_sheet_data.dart';
import 'package:mapify/data/models/flutter_map_entry.dart';

class TileEntriesProvider with ChangeNotifier {
  List<MapLayerEntry> mapEntriesCollection = [
    MapLayerEntry.circle(name: "main-circle", isMain: true),
    MapLayerEntry.polygon(name: "main-polygon", isMain: true),
    MapLayerEntry.polyline(name: "main-polyline", isMain: true),
    MapLayerEntry.marker(name: "main-marker", isMain: true),
  ];

  MapLayerEntry _getDefaultLayerEntry(EntryType type) {
    return mapEntriesCollection.firstWhere((element) => element.isMain);
  }

  void addMapLayerEntry({
    required EntryType type,
    required String name,
    FlutterMapEntry? firstEntry,
  }) {
    assert(
      mapEntriesCollection.any((entry) => entry.name == name),
      "Names of MapLayerEntry must be unique",
    );
    mapEntriesCollection.add(
      MapLayerEntry(
        type: type,
        name: name,
        items: [if (firstEntry != null) firstEntry],
      ),
    );
  }

  void addMarker(InputCoordinatesSheetResult result) {
    MapLayerEntry entries = _getDefaultLayerEntry(EntryType.marker);
    int count = entries.items.length;
    entries.items.add(
      MarkerEntry(
        coordinate: result.coordinates.first,
        name: result.name ?? "marker-${count++}",
      ),
    );
    notifyListeners();
  }

  void addPolyLine(InputCoordinatesSheetResult result) {
    MapLayerEntry entries = _getDefaultLayerEntry(EntryType.polyline);
    int count = entries.items.length;
    entries.items.add(
      PolylineEntry(
        name: result.name ?? "polyline-${count++}",
        points: result.coordinates.toList(),
      ),
    );
    notifyListeners();
  }

  void addPolygon(InputCoordinatesSheetResult result) {
    MapLayerEntry entries = _getDefaultLayerEntry(EntryType.polygon);
    int count = entries.items.length;
    entries.items.add(
      PolygonEntry(
        name: result.name ?? "polygon-${count++}",
        points: result.coordinates.toList(),
        borderColor: result.color,
        fillColor: result.color.withAlpha(128),
      ),
    );
    notifyListeners();
  }

  void addCircle(InputCoordinatesSheetResult result) {
    MapLayerEntry entries = _getDefaultLayerEntry(EntryType.circle);
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
    notifyListeners();
  }
}
