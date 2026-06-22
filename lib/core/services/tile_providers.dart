import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart';
import 'package:http/retry.dart';

final httpClient = RetryClient(Client());
final networkTileProvider = NetworkTileProvider(httpClient: httpClient);

TileLayer openStreetMapTileLayer = TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  userAgentPackageName: "geoink",
  tileProvider: networkTileProvider,
);

TileLayer openStreetMapTileLayerWaitLoad = TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  userAgentPackageName: "geoink",
  tileProvider: networkTileProvider,
  tileDisplay: TileDisplay.instantaneous(),
);
