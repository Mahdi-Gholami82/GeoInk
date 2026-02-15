import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart';
import 'package:http/retry.dart';

final httpClient = RetryClient(Client());
final networkTileProvider = NetworkTileProvider(httpClient: httpClient);

TileLayer openStreetMapTileLayer = TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  userAgentPackageName: 'dev.fleaflet.flutter_map.example',
  tileProvider: networkTileProvider,
  tileBuilder: (context, tileWidget, tile) {
    return tileWidget;
  },
);

TileLayer openStreetMapTileLayerWaitLoad = TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  userAgentPackageName: 'dev.fleaflet.flutter_map.example',
  tileProvider: networkTileProvider,
);
