import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class InputListCoordinatesProvider with ChangeNotifier {
  InputListCoordinatesProvider() {
    initCoordinatesProvider();
  }

  void initCoordinatesProvider() {
    _editingIndex = 0;
    coordinates = [null];
  }

  int? _editingIndex;
  late List<LatLng?> coordinates;

  set editingIndex(int? editingIndex) {
    _editingIndex = editingIndex;
    notifyListeners();
  }

  get editingIndex => _editingIndex;

  void addCoordinates(String? value) {
    if (value == null) {
      coordinates.add(null);
    } else {
      List<String> splitted = value.split(",");
      coordinates[coordinates.length - 1] = LatLng(
        double.parse(splitted[0]),
        double.parse(splitted[1]),
      );
    }
    notifyListeners();
  }

  void removeNull() {
    coordinates.removeWhere((item) => item == null);
    notifyListeners();
  }

  Set<LatLng> takeFinalCoordinates() {
    final result = coordinates.whereType<LatLng>().toSet();
    initCoordinatesProvider();
    notifyListeners();
    return result;
  }
}
