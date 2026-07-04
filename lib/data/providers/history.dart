import 'package:geoink/data/models/action_manager.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:geoink/data/models/map_actions.dart';
import 'package:geoink/data/providers/map_tiles.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'history.g.dart';

extension <T> on List<T> {
  void swapByIndex(int oldIndex, int newIndex) {
    this.insert(newIndex, this.removeAt(oldIndex));
  }
} 

@Riverpod(keepAlive: true)
class HistoryNotifier extends _$HistoryNotifier {
  @override
  MapHistory build() {
    return MapHistory();
  }

  MapLayerList get _mapLayerList => ref.read(tileEntriesProvider);

  void setRestorePoint() {
    state.setRestorePoint();
  }

  void switchHistory(MapHistory newHistory) {
    state = newHistory;
  }

  void forceRebuild() {
    state = state.copy();
  }

  void setConsumersState(Function f) {
    f();
    forceRebuild();
  }

  MapHistory resetHistory() {
    state = MapHistory();
    return state;
  }

  void undo() {
    state.undo();
    forceRebuild();
  }

  void redo() {
    state.redo();
    forceRebuild();
  }

  void addAndMarkDone(Doable doable) {
    doable.done = true;
    state.add(doable);
  }

  void addAndDo(Doable doable) {
    state.addAndDo(doable);
    forceRebuild();
  }

  void actionAddToLayer(
    MapLayer layer, {
    required FlutterMapEntry entry,
    bool unique = true,
  }) {
    addAndDo(
      ManualDoable(
        executeBase: () {
          if (unique) {
            layer.addUnique(entry);
          } else {
            layer.add(entry);
          }
        },
        undoBase: () {
          layer.items.removeLast();
        },
      ),
    );
  }

  void actionSetLastPointPolygon(PolygonEntry polygon, LatLng point) {
    LatLng? oldPoint;
    addAndDo(
      ManualDoable(
        executeBase: () {
          polygon.coordinates.last = point;
        },
        undoBase: () {
          polygon.coordinates.removeLast();
        },
      ),
    );
  }

  void actionAddPointToPolyline(PolylineEntry polyline, LatLng point) {
    addAndDo(ManualDoable(executeBase: () {
      polyline.coordinates.add(point);
    }, undoBase: () {
      polyline.coordinates.removeLast();
    }));
  }

  void actionAddAllToLayer(
    MapLayer layer, {
    required List<FlutterMapEntry> entries,
  }) {
    addAndDo(
      ManualDoable(
        executeBase: () {
          layer.addAllUnique(entries);
        },
        undoBase: () {
          int length = layer.items.length;
          layer.items.removeRange(length - entries.length, length);
        },
      ),
    );
  }

  void actionAddAllToAllLayer(LayerEntryMap layerEntryMap) {
    addAndDo(
      ManualDoable(
        executeBase: () {
          for (var layerFlutterMapEntriesPair in layerEntryMap.entries) {
            layerFlutterMapEntriesPair.key.addAllUnique(
              layerFlutterMapEntriesPair.value,
            );
          }
        },
        undoBase: () {
          for (var layerFlutterMapEntriesPair in layerEntryMap.entries) {
            MapLayer mapLayer = layerFlutterMapEntriesPair.key;
            int length = mapLayer.items.length;
            mapLayer.items.removeRange(
              length - layerFlutterMapEntriesPair.value.length,
              length,
            );
          }
        },
      ),
    );
  }

  void actionListAddAllToAllLayer(List<LayerEntryMap> layerEntryMaps) {
    addAndDo(
      ManualDoable(
        executeBase: () {
          for (var layerEntryMap in layerEntryMaps) {
            for (var layerFlutterMapEntriesPair in layerEntryMap.entries) {
              layerFlutterMapEntriesPair.key.addAllUnique(
                layerFlutterMapEntriesPair.value,
              );
            }
          }
        },
        undoBase: () {
          for (var layerEntryMap in layerEntryMaps) {
            for (var layerFlutterMapEntriesPair in layerEntryMap.entries) {
              MapLayer mapLayer = layerFlutterMapEntriesPair.key;
              int length = mapLayer.items.length;
              mapLayer.items.removeRange(
                length - layerFlutterMapEntriesPair.value.length,
                length,
              );
            }
          }
        },
      ),
    );
  }

  void actionListRemoveLast<T>(List<T> inputList) {
    T? data;
    addAndDo(
      ManualDoable(
        executeBase: () {
          data = inputList.removeLast();
        },
        undoBase: () {
          assert(data != null);
          inputList.add(data!);
        },
      ),
    );
  }

  void actionReorderLayer(int oldIndex, int newIndex) {
    addAndDo(
      ManualDoable(
        executeBase: () {
          _mapLayerList.items.swapByIndex(oldIndex, newIndex);
        },
        undoBase: () {
          _mapLayerList.items.swapByIndex(newIndex, oldIndex);
        },
      ),
    );
  }

  void actionReorderEntry(MapLayer layer,int oldIndex, int newIndex) {
    addAndDo(ManualDoable(executeBase: () {
      layer.items.swapByIndex(oldIndex, newIndex);
    }, undoBase: () {
      layer.items.swapByIndex(newIndex, oldIndex);
    }));
  }

  void actionToggleEntryVisibility(FlutterMapEntry entry) {
    addAndDo(ManualDoable(executeBase: entry.toggleVisiblity, undoBase: entry.toggleVisiblity));
  }

  void actionRemoveLayer(MapLayer layer) {
    MapLayer? data;
    addAndDo(ManualDoable(executeBase: () {
      data = layer;
      _mapLayerList.items.remove(layer);
    }, undoBase: () {
      _mapLayerList.items.add(data!);
    }));
  }

  void actionRemoveEntryFromLayer(FlutterMapEntry entry,MapLayer layer) {
    FlutterMapEntry? data;
    int? index;
    addAndDo(ManualDoable(executeBase: () {
      data = entry;
      index = layer.items.indexOf(entry);
      layer.items.removeAt(index!);
    }, undoBase: () {
      layer.items.insert(index!,data!);
    }));
  }

  void actionMoveEntryToBottom(FlutterMapEntry entry,MapLayer layer) {
    int? index;
    addAndDo(ManualDoable(executeBase: () {
      index = layer.items.indexOf(entry);
      layer.items.removeAt(index!);
      layer.items.add(entry);
    }, undoBase: () {
      layer.items.insert(index!, layer.items.removeLast());
    }));
  }

  void actionMoveEntryToTop(FlutterMapEntry entry,MapLayer layer) {
    int? index;
    addAndDo(ManualDoable(executeBase: () {
      index = layer.items.indexOf(entry);
      layer.items.removeAt(index!);
      layer.items.insert(0, entry);
    }, undoBase: () {
      layer.items.insert(index!, layer.items.removeAt(0));
    }));
  }

  void actionAddLayer(MapLayer layer) {
    addAndDo(ManualDoable(executeBase: () {
      _mapLayerList.items.add(layer);
    }, undoBase: () {
      _mapLayerList.items.removeLast();
    }));
  } 

  void restoreFromPoints() {
    state.restore();
  }

  void setClearAfterRedo() {
    state.clearUndoAfterUndo = true;
  }

  void applyFromPoints() {
    List<Doable> doables = state.getDoableFromRestorePoint();
    state.restore();
    ManualDoable bulkDoable = ManualDoable(
      executeBase: () {
        for (var doable in doables) {
          doable.doIt();
        }
      },
      undoBase: () {
        for (var doable in doables) {
          doable.undoIt();
        }
      },
    );
    bulkDoable.done = true;
    state.add(bulkDoable);
  }
}
