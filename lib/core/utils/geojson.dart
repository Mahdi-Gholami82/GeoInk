import 'dart:convert';
import 'package:geojson_vi/geojson_vi.dart';

GeoJSON parseGeoJson(String jsonString) {
  final Map<String, dynamic> json = jsonDecode(jsonString);

  final type = json['type'];
  if (type == null) {
    throw FormatException('GeoJSON missing "type" field');
  }

  switch (type) {
    case 'FeatureCollection':
      return GeoJSONFeatureCollection.fromMap(json);

    case 'Feature':
      return GeoJSONFeature.fromMap(json);

    case 'Point':
    case 'MultiPoint':
    case 'LineString':
    case 'MultiLineString':
    case 'Polygon':
    case 'MultiPolygon':
    case 'GeometryCollection':
      return GeoJSONGeometry.fromMap(json);

    default:
      throw UnsupportedError('Unsupported GeoJSON type: $type');
  }
}
