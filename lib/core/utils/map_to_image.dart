import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/src/layer/tile_layer/tile_range_calculator.dart';
import 'package:flutter_map/src/layer/tile_layer/tile_range.dart';
import 'package:latlong2/latlong.dart';
import 'package:GeoInk/core/utils/max_merc_bounds.dart';
import 'package:GeoInk/core/utils/map_to_image/camera_with_prefered_size.dart';
import 'package:GeoInk/core/utils/map_to_image/map_to_image_waiter.dart';

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
  Duration timeout = const Duration(seconds: 10),
}) async {
  var mapOptions = MapOptions(
    initialCameraFit: CameraFit.bounds(bounds: bounds ?? MercBounds.maxBounds),
  );
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
    camera: CameraWithPreferedSize(
      preferedSize: Size(width, height),
      options: mapOptions,
    ),
    tileZoom: tileZoom,
  );
  Iterable<TileCoordinates> tiles = tileRange.coordinates;

  var imageFuture = mapToImageWaiter(
    FlutterMap(
      children: [tileLayer, ...mapChildren],
      options: MapOptions(
        initialCenter: LatLng(0, 0),
        initialCameraFit: CameraFit.bounds(bounds: MercBounds.maxBounds),
        initialZoom: 2,
      ),
    ),
    tilesLoadedGenerator: () {
      Future<List> tileLoad = Future.wait(
        _loadAllNeccessaryTiles(tiles, tileLayer),
      ).timeout(timeout);
      return tileLoad;
    },
  );
  return imageFuture;
}
