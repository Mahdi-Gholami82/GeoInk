import 'package:flutter_map/flutter_map.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_camera.g.dart';

class MapCameraState {
  MapCameraState([this.camera]);
  MapCamera? camera;
}

@Riverpod(keepAlive: true)
class MapCameraNotifier extends _$MapCameraNotifier {
  @override
  MapCameraState build() {
    return MapCameraState();
  }

  void update(MapCamera mapCamera) {
    state = MapCameraState(mapCamera);
  }
}
