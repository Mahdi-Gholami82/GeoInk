import 'dart:convert';
import 'dart:ui';
import 'package:geoink/core/utils/coordinates_tools.dart';
import 'package:geoink/core/utils/string_to_color.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:latlong2/latlong.dart';

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


List<FlutterMapEntry> mapEntriesFromGeoJsonObject(
    GeoJSONGeometry geoJson, {
    required Map<String, dynamic> properties,
  }) {
    List<FlutterMapEntry> resultEntries = [];
    String? name = properties["name"];
    final bool visible = properties["visible"] ?? true;
    final String? description = properties["description"];
    switch (geoJson.type) {
      case GeoJSONType.point:
        var geoJsonPoint = geoJson as GeoJSONPoint;
        if (properties["radius"] == null) {
          resultEntries.add(
            MarkerEntry.withDefaults(
              name: name ?? "marker",
              point: listToLatLng(geoJsonPoint.coordinates),
              color: stringToColor(properties["color"]),
              visible: visible,
              description: description,
            ),
          );
        } else {
          resultEntries.add(
            CircleEntry.withDefaults(
              name: name ?? "circle",
              center: listToLatLng(geoJsonPoint.coordinates),
              radius: properties["radius"],
              fillColor: stringToColor(properties["fill"]),
              borderColor: stringToColor(properties["stroke"]),
              borderWidth: properties["stroke-width"],
              visible: visible,
              description: description,
            ),
          );
        }
        break;
      case GeoJSONType.multiPoint:
        var geoJsonMultiPoint = geoJson as GeoJSONMultiPoint;
        name ??= "marker";
        final Color? color = stringToColor(properties["color"]);
        for (var polygonCoordinates in geoJsonMultiPoint.coordinates) {
          resultEntries.add(
            MarkerEntry.withDefaults(
              name: name,
              point: listToLatLng(polygonCoordinates),
              color: color,
              visible: visible,
              description: description,
            ),
          );
        }
        break;
      case GeoJSONType.lineString:
        var geoJsonLineString = geoJson as GeoJSONLineString;
        resultEntries.add(
          PolylineEntry.withDefaults(
            name: name ?? "polyline",
            points: multipleListToLatLng(geoJsonLineString.coordinates),
            color: stringToColor(properties["stroke"]),
            strokeWidth: properties["stroke-width"],
            visible: visible,
            description: description,
          ),
        );
        break;
      case GeoJSONType.multiLineString:
        var geoJsonMultiLineString = geoJson as GeoJSONMultiLineString;
        name ??= "polyline";
        final Color? stroke = stringToColor(properties["stroke"]);
        for (var polylineCoordinates in geoJsonMultiLineString.coordinates) {
          resultEntries.add(
            PolylineEntry.withDefaults(
              name: name,
              points: multipleListToLatLng(polylineCoordinates),
              color: stroke,
              strokeWidth: properties["stroke-width"],
              visible: visible,
              description: description,
            ),
          );
        }
        break;
      case GeoJSONType.polygon:
        var geoJsonPolygon = geoJson as GeoJSONPolygon;
        List<List<LatLng>>? coordinates = geoJsonPolygon.coordinates
            .map((e) => multipleListToLatLng(e))
            .toList();
        List<LatLng>? polygonMainCoordinates = coordinates.length == 1
            ? coordinates.first
            : findMaxCoordinatesArea(coordinates);
        resultEntries.add(
          PolygonEntry.withDefaults(
            name: name ?? "polygon",
            points: polygonMainCoordinates,
            fillColor: stringToColor(properties["fill"]),
            borderColor: stringToColor(properties["stroke"]),
            borderWidth: properties["stroke-width"],
            visible: visible,
            description: description,
          ),
        );
        break;
      case GeoJSONType.multiPolygon:
        var geoJsonMultiPolygon = geoJson as GeoJSONMultiPolygon;
        name ??= "polygon";
        final Color? stroke = stringToColor(properties["stroke"]);
        final Color? fill = stringToColor(properties["fill"]);
        for (var polygonCoordinates in geoJsonMultiPolygon.coordinates) {
          List<List<LatLng>>? coordinates = polygonCoordinates
              .map((e) => multipleListToLatLng(e))
              .toList();
          List<LatLng>? polygonMainCoordinates = coordinates.length == 1
              ? coordinates.first
              : findMaxCoordinatesArea(coordinates);
          resultEntries.add(
            PolygonEntry.withDefaults(
              name: name,
              points: polygonMainCoordinates,
              fillColor: fill,
              borderColor: stroke,
              borderWidth: properties["stroke-width"],
              visible: visible,
              description: description,
            ),
          );
        }
        break;
      default:
        throw Exception("Geomatry not in supported types.");
    }
    return resultEntries;
  }
