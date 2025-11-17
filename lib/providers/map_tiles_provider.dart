import 'package:flutter/material.dart';
import 'package:mapify/plugins/map_entry_data_models.dart';

class TileEntriesProvider with ChangeNotifier {
  Set<MapEntry> entries = {};

  void _addEntry(MapEntry newLayer) {
    entries.add(newLayer);
    notifyListeners();
  }

  void addEntries() {}
}
