import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class InputListCoordinatesProvider with ChangeNotifier {
  int? _editingIndex = 0;
  List<LatLng?> coordinates = [null];

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
}
