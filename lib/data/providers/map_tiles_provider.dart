import 'package:GeoInk/data/models/coordinates_sheet_data.dart';
import 'package:GeoInk/data/models/flutter_map_entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_tiles_provider.g.dart';





@Riverpod(keepAlive: true)
class TileEntriesNotifier extends _$TileEntriesNotifier {
  @override
  MapLayerList build() {
    return MapLayerList();
  }

  void forceRebuild() {
    state = state.copy();
  }

  void updateState(List<MapLayer> newItems) {
    state = state.copy(newItems : newItems);
  }

  void setConsumersState(void Function() fn) {
    fn();
    forceRebuild();
  }

  void addMarker(InputCoordinatesResult result) {
    state.addMarker(result);
    forceRebuild();
  }

  void addPolyLine(InputCoordinatesResult result) {
    state.addPolyLine(result);
    forceRebuild();
  }

  void addPolygon(InputCoordinatesResult result) {
    state.addPolygon(result);
    forceRebuild();
  }

  void addCircle(InputCoordinatesResult result) {
    state.addCircle(result);
    forceRebuild();
  }
  
}
