import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart';
import 'package:http/retry.dart';

final httpClient = RetryClient(Client());
final networkTileProvider = NetworkTileProvider(httpClient: httpClient);

TileLayer getOpenStreetMapTileLayer({
  bool darkMode = false,
  bool instantLoad = false,
}) => TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  tileBuilder: darkMode ? darkModeTileBuilder : null,
  keepBuffer: 0,
  userAgentPackageName:
      "com.example.geoink (contact: mahdigholamigodarzi@gmail.com)",
  tileProvider: networkTileProvider,
  tileDisplay: instantLoad
      ? const TileDisplay.fadeIn()
      : const TileDisplay.instantaneous(),
);
