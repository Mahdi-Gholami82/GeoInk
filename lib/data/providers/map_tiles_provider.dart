import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapify/data/models/coordinates_sheet_data_models.dart';
import 'package:mapify/data/models/map_entry_data_models.dart';

class TileEntriesProvider with ChangeNotifier {
  List<MapEntries> mapEntriesCollection = [
    MapEntries(type: EntryType.circle),
    MapEntries(type: EntryType.polygon),
    MapEntries(type: EntryType.polyline),
    MapEntries(type: EntryType.marker),
  ];

  MapEntries _getEntryType(EntryType type) {
    return mapEntriesCollection.firstWhere((element) => element.type == type);
  }

  void addMarker(InputCoordinatesSheetResult result) {
    MapEntries entries = _getEntryType(EntryType.marker);
    int count = entries.items.length;
    entries.items.addAll(
      result.coordinates.map((coordinate) {
        return MarkerEntry(coordinate: coordinate, name: "marker-${count++}");
      }).toList(),
    );
    notifyListeners();
  }

  void addPolyLine(InputCoordinatesSheetResult result) {
    MapEntries entries = _getEntryType(EntryType.polyline);
    int count = entries.items.length;
    entries.items.add(
      PolylineEntry(
        name: "polyline-${count++}",
        points: result.coordinates.toList(),
      ),
    );
    notifyListeners();
  }

  void addPolygon(InputCoordinatesSheetResult result) {
    MapEntries entries = _getEntryType(EntryType.polygon);
    int count = entries.items.length;
    entries.items.add(
      PolygonEntry(
        name: "polygon-${count++}",
        points: result.coordinates.toList(),
        fillColor: Colors.red.withAlpha(128),
        borderColor: Colors.red,
      ),
    );
    notifyListeners();
  }

  void addCircle(InputCoordinatesSheetResult result) {
    MapEntries entries = _getEntryType(EntryType.circle);
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
