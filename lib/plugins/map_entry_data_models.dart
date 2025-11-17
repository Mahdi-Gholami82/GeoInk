import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

abstract class MapEntry {
  final String name;
  bool visible;

  MapEntry({required this.name, this.visible = true});
}

class MarkerEntry extends MapEntry {
  LatLng coordinate;
  Color color;

  MarkerEntry({
    required super.name,
    required this.coordinate,
    this.color = Colors.black,
    super.visible,
  });
}

class PolygonEntry extends MapEntry {
  final List<LatLng> points;
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  PolygonEntry({
    required super.name,
    required this.points,
    required this.fillColor,
    required this.borderColor,
    this.borderWidth = 2.0,
  });
}

class PolylineEntry extends MapEntry {
  List<LatLng> points;
  Color color;
  double strokeWidth;

  PolylineEntry({
    required super.name,
    required this.points,
    this.color = Colors.red,
    this.strokeWidth = 3.0,
    super.visible,
  });
}

class CircleEntry extends MapEntry {
  final LatLng center;
  final double radius; // meters
  final Color borderColor;
  final double borderWidth;
  final Color fillColor;

  CircleEntry({
    required super.name,
    required this.center,
    required this.radius,
    this.borderColor = Colors.black,
    this.borderWidth = 2.0,
    required this.fillColor,
  });
}

enum EntryType { marker, polygon, polyline, circle }

Map flutterMapObjects = {
  EntryType.marker: Marker,
  EntryType.polygon: Polygon,
  EntryType.circle: CircleMarker,
  EntryType.polyline: Polyline,
};

class MapEntries {
  final EntryType type;
  final List<MapEntry> elements;

  MapEntries({required this.type, List<MapEntry>? entries})
    : elements = entries ?? [];

  dynamic toFlutterMapObject() {
    switch (type) {
      case EntryType.marker:
        final markers = elements.cast<MarkerEntry>();
        return MarkerLayer(
          markers: markers.map((marker) {
            return Marker(
              point: marker.coordinate,
              width: 64,
              height: 64,
              child: Icon(Icons.location_pin, size: 60, color: marker.color),
            );
          }).toList(),
        );

      case EntryType.polyline:
        final lines = elements.cast<PolylineEntry>();
        return PolylineLayer(
          polylines: lines.map((line) {
            return Polyline(
              points: line.points,
              strokeWidth: line.strokeWidth,
              color: line.color,
            );
          }).toList(),
        );

      case EntryType.polygon:
        final polys = elements.cast<PolygonEntry>();
        return PolygonLayer(
          polygons: polys.map((poly) {
            return Polygon(
              points: poly.points,
              borderColor: poly.borderColor,
              borderStrokeWidth: poly.borderWidth,
              color: poly.fillColor,
            );
          }).toList(),
        );

      case EntryType.circle:
        final circles = elements.cast<CircleEntry>();
        return CircleLayer(
          circles: circles.map((circle) {
            return CircleMarker(
              point: circle.center,
              radius: circle.radius,
              borderColor: circle.borderColor,
              borderStrokeWidth: circle.borderWidth,
              color: circle.fillColor,
            );
          }).toList(),
        );
    }
  }
}
