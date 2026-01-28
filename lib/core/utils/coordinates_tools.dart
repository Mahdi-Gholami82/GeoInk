import 'dart:math';

import 'package:geojson_vi/geojson_vi.dart';
import 'package:latlong2/latlong.dart';

/// Checks if two [LatLng] objects hold the same coordinates.
bool latLngsEqual(LatLng first, LatLng second) =>
    first.latitude == second.latitude && first.longitude == second.longitude;

bool isCounterClockwise(List<LatLng> coordinates) {
  double sum = 0;

  for (int i = 0; i < coordinates.length; i++) {
    final p1 = coordinates[i];
    final p2 = coordinates[(i + 1) % coordinates.length];

    sum += (p2.longitude - p1.longitude) * (p2.latitude + p1.latitude);
  }
  return sum < 0;
}

bool isClockwise(List<LatLng> coordinates) {
  double sum = 0;

  for (int i = 0; i < coordinates.length; i++) {
    final p1 = coordinates[i];
    final p2 = coordinates[(i + 1) % coordinates.length];

    sum += (p2.longitude - p1.longitude) * (p2.latitude + p1.latitude);
  }
  return sum > 0;
}

double _calculateCenterLat(List<LatLng> points) =>
    points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;
double _calculateCenterLong(List<LatLng> points) =>
    points.map((p) => p.longitude).reduce((a, b) => a + b) / points.length;

List<LatLng> sortClockwiseLatLng(List<LatLng> coordinates) {
  List<LatLng> coordinatesCopy = [...coordinates];
  if (!isCounterClockwise(coordinatesCopy)) return coordinatesCopy;
  final centerLat = _calculateCenterLat(coordinates);
  final centerLng = _calculateCenterLong(coordinates);

  coordinatesCopy.sort((a, b) {
    final angleA = atan2(a.latitude - centerLat, a.longitude - centerLng);
    final angleB = atan2(b.latitude - centerLat, b.longitude - centerLng);
    return angleB.compareTo(angleA);
  });

  return coordinatesCopy;
}

List<LatLng> sortCounterClockwiseLatLng(List<LatLng> coordinates) {
  List<LatLng> coordinatesCopy = [...coordinates];
  if (isCounterClockwise(coordinatesCopy)) return coordinatesCopy;
  final centerLat = _calculateCenterLat(coordinates);
  final centerLng = _calculateCenterLong(coordinates);

  coordinatesCopy.sort((a, b) {
    final angleA = atan2(a.latitude - centerLat, a.longitude - centerLng);
    final angleB = atan2(b.latitude - centerLat, b.longitude - centerLng);
    return angleA.compareTo(angleB);
  });

  return coordinatesCopy;
}

List<LatLng> processPolygonLatlngs(List<LatLng> coordinates) {
  List<LatLng> sorted = sortCounterClockwiseLatLng(
    latLngsEqual(coordinates.first, coordinates.last)
        ? coordinates.sublist(0, coordinates.length - 1)
        : coordinates,
  );
  if (!latLngsEqual(sorted.first, sorted.last)) sorted.add(sorted.first);
  return sorted;
}

LatLng listToLatLng(List c) => LatLng(c[1], c[0]);

List<LatLng> multipleListToLatLng(List<List<double>> coordinatesList) =>
    coordinatesList.map((e) => listToLatLng(e)).toList();

double calculateArea(List<LatLng> points) {
  return GeoJSONPolygon([
    [
      for (var point in points) [point.latitude, point.longitude],
    ],
  ]).area;
}

List<LatLng> findMaxCoordinatesArea(List<List<LatLng>> points) {
  assert(points.isNotEmpty, "Given points must not be empty.");
  var max = points.first;
  for (var point in points) {
    if ((calculateArea(point) > calculateArea(max))) {
      max = point;
    }
  }
  return max;
}
