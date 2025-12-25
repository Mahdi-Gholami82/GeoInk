import 'package:latlong2/latlong.dart';

/// Checks if two [LatLng] objects hold the same coordinates.
bool latLngsEqual(LatLng first, LatLng second) =>
    first.latitude == second.latitude && first.longitude == second.longitude;
