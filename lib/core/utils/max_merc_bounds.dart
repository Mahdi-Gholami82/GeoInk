import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MercBounds {
  static const double latLimit = 85.05112878;
  static const double longLimit = 180;
  static const LatLng minLatLng = LatLng(-latLimit, -longLimit);
  static const LatLng maxLatLng = LatLng(latLimit, longLimit);
  static final maxBounds = LatLngBounds(minLatLng, maxLatLng);
}
