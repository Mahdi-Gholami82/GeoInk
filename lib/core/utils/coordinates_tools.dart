import 'dart:math';

import 'package:geojson_vi/geojson_vi.dart';
import 'package:latlong2/latlong.dart';

/// Checks if two [LatLng] objects hold the same coordinates.
bool latLngsEqual(LatLng first, LatLng second) =>
    first.latitude == second.latitude && first.longitude == second.longitude;

bool isCounterClockwise(List<LatLng> points) {
  double sum = 0;

  for (int i = 0; i < points.length; i++) {
    final p1 = points[i];
    final p2 = points[(i + 1) % points.length];

    sum += (p2.longitude - p1.longitude) * (p2.latitude + p1.latitude);
  }
  return sum < 0;
}

bool isClockwise(List<LatLng> points) {
  double sum = 0;

  for (int i = 0; i < points.length; i++) {
    final p1 = points[i];
    final p2 = points[(i + 1) % points.length];

    sum += (p2.longitude - p1.longitude) * (p2.latitude + p1.latitude);
  }
  return sum > 0;
}

double _calculateCenterLat(List<LatLng> points) =>
    points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;
double _calculateCenterLong(List<LatLng> points) =>
    points.map((p) => p.longitude).reduce((a, b) => a + b) / points.length;

List<LatLng> sortClockwiseLatLng(List<LatLng> points) {
  List<LatLng> pointsCopy = [...points];
  if (!isCounterClockwise(pointsCopy)) return pointsCopy;
  final centerLat = _calculateCenterLat(points);
  final centerLng = _calculateCenterLong(points);

  pointsCopy.sort((a, b) {
    final angleA = atan2(a.latitude - centerLat, a.longitude - centerLng);
    final angleB = atan2(b.latitude - centerLat, b.longitude - centerLng);
    return angleB.compareTo(angleA);
  });

  return pointsCopy;
}

List<LatLng> sortCounterClockwiseLatLng(List<LatLng> points) {
  List<LatLng> pointsCopy = [...points];
  if (isCounterClockwise(pointsCopy)) return pointsCopy;
  final centerLat = _calculateCenterLat(points);
  final centerLng = _calculateCenterLong(points);

  pointsCopy.sort((a, b) {
    final angleA = atan2(a.latitude - centerLat, a.longitude - centerLng);
    final angleB = atan2(b.latitude - centerLat, b.longitude - centerLng);
    return angleA.compareTo(angleB);
  });

  return pointsCopy;
}

List<LatLng> processPolygonLatlngs(List<LatLng> points) {
  List<LatLng> sorted = sortCounterClockwiseLatLng(
    latLngsEqual(points.first, points.last)
        ? points.sublist(0, points.length - 1)
        : points,
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
