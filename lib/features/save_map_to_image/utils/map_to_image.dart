import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/src/layer/tile_layer/tile_range_calculator.dart';
import 'package:flutter_map/src/layer/tile_layer/tile_range.dart';
import 'package:latlong2/latlong.dart';
import 'package:screenshot/screenshot.dart';

const double _maxMercLat = 85.05112878;
const double _maxMercLong = 180;
final _maxMercBounds = LatLngBounds(
  LatLng(-_maxMercLat, -_maxMercLong),
  LatLng(_maxMercLat, _maxMercLong),
);

class _CameraExtra extends MapCamera {
  _CameraExtra({required this.preferedSize, required MapOptions options})
    : super.initialCamera(options);

  Size preferedSize;

  @override
  Size get size {
    return preferedSize;
  }
}

Future<ImageInfo> _getImage(ImageProvider provider) {
  final completer = Completer<ImageInfo>();
  provider
      .resolve(ImageConfiguration.empty)
      .addListener(
        ImageStreamListener(
          (imageInfo, _) => completer.complete(imageInfo),
          onError: completer.completeError,
        ),
      );
  return completer.future;
}

List<Future<dynamic>> _loadAllNeccessaryTiles(
  Iterable<TileCoordinates> tiles,
  TileLayer tileLayer,
) {
  debugPrint("lenght : ${tiles.length}");
  List<Future> images = [];
  var resolver = TileCoordinatesResolver(true);
  for (var tile in tiles.map((e) => resolver.get(e)).toSet()) {
    var imageProvider = tileLayer.tileProvider.getImageWithCancelLoadingSupport(
      tile,
      tileLayer,
      Future.sync(() {}),
    );
    images.add(_getImage(imageProvider));
  }
  return images;
}

Future<Uint8List> mapToImage({
  required TileLayer tileLayer,
  required List<Widget> mapChildren,
  LatLng center = const LatLng(0, 0),
  LatLngBounds? bounds,
  double width = 1920,
  double height = 1080,
  double ratio = 1,
}) async {
  var mapOptions = MapOptions(
    initialCameraFit: CameraFit.bounds(bounds: bounds ?? _maxMercBounds),
  );
  var screenshotController = ScreenshotController();
  var mapController = MapControllerImpl(options: mapOptions);
  var tileRangeCalculator = TileRangeCalculator(
    tileDimension: tileLayer.tileDimension,
  );
  MapCamera mapCamera = mapController.camera;
  final int tileZoom = mapCamera.zoom.round().clamp(
    tileLayer.minNativeZoom,
    tileLayer.maxNativeZoom,
  );

  DiscreteTileRange tileRange = tileRangeCalculator.calculate(
    camera: _CameraExtra(
      preferedSize: Size(width, height),
      options: mapOptions,
    ),
    tileZoom: tileZoom,
  );
  Iterable<TileCoordinates> tiles = tileRange.coordinates;
  print(tileRange.coordinates.length);
  var loadingTiles = _loadAllNeccessaryTiles(tiles, tileLayer);
  Future.wait(loadingTiles).then((v) {
    print(v.length);
  });

  return screenshotController.captureFromWidget(
    MediaQuery(
      data: MediaQueryData(),
      child: FlutterMap(
        mapController: mapController,
        options: mapOptions,
        children: [tileLayer, ...mapChildren],
      ),
    ),
    targetSize: Size(width, height),
    pixelRatio: ratio,
  );
}
