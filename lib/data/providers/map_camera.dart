import 'package:flutter_map/flutter_map.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_camera.g.dart';

@Riverpod(keepAlive: true)
class MapCameraNotifier extends _$MapCameraNotifier {
  @override
  MapCamera? build() {
    return null;
  }

  void update(MapCamera mapCamera) {
    state = mapCamera;
  }
}
