import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class MapEntry {
  MapEntry({required this.name});
  String name;
}

class MarkerEntry extends MapEntry {
  MarkerEntry({
    required super.name,
    required this.coordinate,
    this.color = Colors.black,
  });
  LatLng coordinate;
  Color color;
}

class GroupedEntries extends MapEntry {
  GroupedEntries({required super.name, required this.elements});
  Set<MapEntry> elements;
}

class Entries {
  Entries({this.mapLayers = const {}});
  Set<MapEntry> mapLayers;

  void add(MapEntry newLayer) {
    mapLayers.add(newLayer);
  }

  List<MapEntry> get ungrouped {
    return mapLayers
            .map((value) {
              if (value is GroupedEntries) {
                return value.elements;
              }
            })
            .expand((value) {
              if (value is Iterable) {
                return value!;
              }
              return [value];
            })
            .toList()
        as List<MapEntry>;
  }
}

class EntriesProvider with ChangeNotifier {
  Entries mapLayers = Entries();

  void addEntry(MapEntry newLayer) {
    mapLayers.add(newLayer);
    notifyListeners();
  }
}
