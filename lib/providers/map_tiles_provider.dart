import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapify/plugins/map_entry_data_models.dart';

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

  void addMarker(Set<LatLng> coordinates) {
    MapEntries entries = _getEntryType(EntryType.marker);
    int count = entries.items.length;
    entries.items.addAll(
      coordinates.map((coordinate) {
        return MarkerEntry(coordinate: coordinate, name: "marker-${count++}");
      }).toList(),
    );
    notifyListeners();
  }

  void addPolyLine(Set<LatLng> coordinates) {
    MapEntries entries = _getEntryType(EntryType.polyline);
    int count = entries.items.length;
    entries.items.add(
      PolylineEntry(name: "polyline-${count++}", points: coordinates.toList()),
    );
    notifyListeners();
  }

  void addPolygon(Set<LatLng> coordinates) {
    MapEntries entries = _getEntryType(EntryType.polygon);
    int count = entries.items.length;
    entries.items.add(
      PolygonEntry(
        name: "polygon-${count++}",
        points: coordinates.toList(),
        fillColor: Colors.red.withAlpha(128),
        borderColor: Colors.red,
      ),
    );
    notifyListeners();
  }
}
