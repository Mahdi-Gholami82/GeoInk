import 'package:flutter/material.dart';
import 'package:geoink/core/utils/coordinates_tools.dart';
import 'package:latlong2/latlong.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:geoink/core/utils/coordinates_reformatter.dart';

List<LatLng> _stringToCoordinates(List<String> coordinates) {
  return coordinates.map((e) => tryParseSingle(e)!.toLatLng()!).toList();
}

class InputCoordinatesResult {
  InputCoordinatesResult({
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
  MapLayer layer;

  MarkerEntry toMarker() => MarkerEntry(
    point: coordinates.first,
    name: layer.getUniqueName(name ?? "marker"),
    color: color,
  );

  PolylineEntry toPolyline() => PolylineEntry(
        name: layer.getUniqueName(name ?? "polyline"),
        points: coordinates,
        color: color,
      );
  PolygonEntry toPolygon() => PolygonEntry(
        name: name ?? "polygon",
        points: processPolygonLatlngs(coordinates),
        borderColor: color,
        fillColor: color.withAlpha(128),
      );
  CircleEntry toCircle() => CircleEntry(
        name: layer.getUniqueName(name ?? "circle"),
        center: coordinates[0],
        radius: radius!,
        fillColor: color,
        borderColor: color.withAlpha(128),
      );
}

enum SheetInputFieldType { name, coordinates, radius }

class SheetListInput {
  SheetListInput({
    this.type = SheetInputFieldType.coordinates,
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
  SheetListInput.coordinatesField({String input = ""})
    : this(type: SheetInputFieldType.coordinates, input: input);
  SheetListInput.radiusField({String input = ""})
    : this(type: SheetInputFieldType.radius, input: input);

  Icon get icon {
    switch (type) {
      case SheetInputFieldType.coordinates:
        return Icon(Icons.location_on);
      case SheetInputFieldType.name:
        return Icon(Icons.abc);
      case SheetInputFieldType.radius:
        return Icon(Icons.adjust);
    }
  }
}
