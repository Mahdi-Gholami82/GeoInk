import 'package:geoink/core/utils/coordinates_tools.dart';
import 'package:geoink/data/models/coordinates_sheet_data.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unique_list/unique_list.dart';

part 'map_tiles_provider.g.dart';





@Riverpod(keepAlive: true)
class TileEntriesNotifier extends _$TileEntriesNotifier {
  @override
  MapLayerList build() {
    return MapLayerList.withMainLayers();
  }

  void forceRebuild() {
    state = state.copy();
  }

  void updateState(MapLayerList mapLayer) {
    state = state.copy(newItems : mapLayer.items);
  }

  void updateStateByItems(List<MapLayer> newItems) {
    state = state.copy(newItems : newItems);
  }

  void addLayerOrElse(MapLayer layer, {void Function()? orElse}) {
    try{
      state.items.add(layer);
    } on DuplicateValueError {
      orElse?.call();
    }
  }

  void addLayerIfNotExist(MapLayer layer) {
    addLayerOrElse(layer);
  }

  void setConsumersState(void Function() fn) {
    fn();
    forceRebuild();
  }

  void addMarker(InputCoordinatesResult result) {
    addLayerIfNotExist(result.layer);
    result.layer.add(
      MarkerEntry(
        coordinate: result.coordinates.first,
        name: result.name ?? "marker",
        color: result.color,
      ),
    );
    forceRebuild();
  }

  void addPolyLine(InputCoordinatesResult result) {
    addLayerIfNotExist(result.layer);
    result.layer.add(
      PolylineEntry(
        name: result.name ?? "polyline",
        coordinates: result.coordinates,
        color: result.color,
      ),
    );
    forceRebuild();
  }

  void addPolygon(InputCoordinatesResult result) {
    var coordinates = result.coordinates;
    addLayerIfNotExist(result.layer);
    result.layer.add(
      PolygonEntry(
        name: result.name ?? "polygon",
        coordinates: processPolygonLatlngs(coordinates),
        borderColor: result.color,
        fillColor: result.color.withAlpha(128),
      ),
    );
    forceRebuild();
  }

  void addCircle(InputCoordinatesResult result) {
    addLayerIfNotExist(result.layer);
    result.layer.add(
      CircleEntry(
        name: result.name ?? "circle",
        center: result.coordinates[0],
        radius: result.radius!,
        fillColor: result.color,
        borderColor: result.color.withAlpha(128),
      ),
    );
    forceRebuild();
  }
  
}
