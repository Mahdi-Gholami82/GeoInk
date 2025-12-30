import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapify/data/models/flutter_map_entry.dart';
import 'package:mapify/core/utils/coordinates_reformatter.dart';

List<LatLng> _stringToCoordinates(List<String> coordinates) {
  return coordinates.map((e) => tryParseSingle(e)!.toLatLng()!).toList();
}

class InputCoordinatesSheetResult {
  InputCoordinatesSheetResult({
    required List<String> coordinates,
    required this.color,
    required this.layer,
    String? radius,
    this.name,
  }) : coordinates = _stringToCoordinates(coordinates),
       radius = double.tryParse(radius ?? "");
  List<LatLng> coordinates;
  double? radius;
  Color color;
  String? name;
  MapLayerEntry layer;
}

enum SheetInputFieldType { name, coordinate, radius }

class SheetListInput {
  SheetListInput({
    this.type = SheetInputFieldType.coordinate,
    String input = "",
  }) {
    value = input;
  }
  SheetInputFieldType type;
  TextEditingController controller = TextEditingController();
  set value(String value) {
    controller.text = value;
  }

  String get value => controller.text;

  SheetListInput.nameField({String input = ""})
    : this(type: SheetInputFieldType.name, input: input);
  SheetListInput.coordinateField({String input = ""})
    : this(type: SheetInputFieldType.coordinate, input: input);
  SheetListInput.radiusField({String input = ""})
    : this(type: SheetInputFieldType.radius, input: input);

  Icon get icon {
    switch (type) {
      case SheetInputFieldType.coordinate:
        return Icon(Icons.location_on);
      case SheetInputFieldType.name:
        return Icon(Icons.abc);
      case SheetInputFieldType.radius:
        return Icon(Icons.adjust);
    }
  }
}
