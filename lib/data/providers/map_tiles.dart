import 'package:collection/collection.dart';
import 'package:geoink/core/utils/geojson.dart';
import 'package:geoink/data/models/coordinates_sheet_data.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:geoink/data/models/map_actions.dart';
import 'package:geoink/data/providers/history.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unique_list/unique_list.dart';

part 'map_tiles.g.dart';



@Riverpod(keepAlive: true)
class TileEntriesNotifier extends _$TileEntriesNotifier {
  @override
  MapLayerList build() {
    return MapLayerList.withMainLayers();
  }

  MapHistory get history => ref.read(historyProvider);
  HistoryNotifier get historyNotifier => ref.read(historyProvider.notifier);

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
    historyNotifier.actionAddToLayer(result.layer,entry: result.toMarker());
    forceRebuild();
  }

  void addPolyLine(InputCoordinatesResult result) {
    addLayerIfNotExist(result.layer);
    historyNotifier.actionAddToLayer(result.layer,entry: result.toPolyline());
    forceRebuild();
  }

  void addPolygon(InputCoordinatesResult result) {
    addLayerIfNotExist(result.layer);
    historyNotifier.actionAddToLayer(result.layer,entry: result.toPolygon());
    forceRebuild();
  }

  void addCircle(InputCoordinatesResult result) {
    addLayerIfNotExist(result.layer);
    historyNotifier.actionAddToLayer( result.layer,entry: result.toCircle());
    forceRebuild();
  }

  LayerEntryMap fromGeoJSONGeometries(List<GeoJSONGeometry> geometries,{required Map<String, dynamic> properties,}) {
    LayerEntryMap layerEntryMap = {};
    for (var geometry in geometries) {
      if (geometry.type == GeoJSONType.geometryCollection) {
        fromGeoJSONGeometries((geometry as GeoJSONGeometryCollection).geometries, properties: properties);
        continue;
      }
      List<FlutterMapEntry> entries = mapEntriesFromGeoJsonObject(geometry, properties: properties);
      if (entries.isEmpty) continue;
      assert(entries.every((e)=>e.runtimeType == entries.first.runtimeType));
      String? name = properties["name"];
      MapLayer layer =
          (name == null
              ? null
              : state.items.toList().firstWhereOrNull(
                  (e) => e.name.trim() == name,
                )) ??
          state.getDefaultLayerEntry(EntryType.fromType(entries.first.runtimeType));
      layerEntryMap[layer] = entries;
    }
    return layerEntryMap;
  }

  List<LayerEntryMap> fromGeoJSONFeatureCollection(GeoJSONFeatureCollection featureCollection) {
    List<LayerEntryMap> results = [];
    for (var feature in featureCollection.features) {
      if (feature == null || feature.geometry == null) {
        continue;
      }
      GeoJSONGeometry geometry = feature.geometry!;
      Map<String, dynamic> properties =
          feature.properties ?? {};
      List<GeoJSONGeometry> geomatries = [geometry];
      while (geomatries.isNotEmpty) {
        results.add(fromGeoJSONGeometries(geomatries, properties: properties));
        geomatries.removeWhere(
          (e) => geomatries.contains(e),
        );
        geomatries = geomatries.expand((e) {
          return (e as GeoJSONGeometryCollection).geometries;
        }).toList();
      }
    }
    return results;
  }

}
