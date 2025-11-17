import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapify/plugins/map_entry_data_models.dart';

class TileEntriesProvider with ChangeNotifier {
  List<MapEntries> mapEntriesCollection = [
    MapEntries(type: EntryType.marker),
    MapEntries(type: EntryType.circle),
    MapEntries(type: EntryType.polygon),
    MapEntries(type: EntryType.polyline),
  ];

  void addMarker(Set<LatLng> coordinates) {
    MapEntries entries = mapEntriesCollection.firstWhere(
      (element) => element.type == EntryType.marker,
    );
    int count = entries.elements.length;
    entries.elements.addAll(
      coordinates.map((coordinate) {
        return MarkerEntry(coordinate: coordinate, name: "marker-$count");
      }).toList(),
    );
    notifyListeners();
  }
}
