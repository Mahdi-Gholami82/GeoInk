import 'package:flutter/material.dart';
import 'package:geoink/data/models/action_manager.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:geoink/data/models/map_actions.dart';
import 'package:geoink/data/providers/map_layer_list.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'history.g.dart';

extension<T> on List<T> {
  void swapByIndex(int oldIndex, int newIndex) {
    insert(newIndex, removeAt(oldIndex));
  }

  int moveToFirstGetIndex(T element) {
    int index = indexOf(element);
    assert(index != -1);
    removeAt(index);
    insert(0, element);
    return index;
  }

  int moveToLastGetIndex(T element) {
    int index = indexOf(element);
    assert(index != -1);
    removeAt(index);
    add(element);
    return index;
  }

  void moveLastToIndex(int index) {
    insert(index, removeLast());
  }

  void moveFirstToIndex(int index) {
    insert(index, removeAt(0));
  }
}

@Riverpod(keepAlive: true)
class HistoryNotifier extends _$HistoryNotifier {
  @override
  MapHistory build() {
    return MapHistory();
  }

  MapLayerList get _mapLayerList => ref.read(mapLayerListProvider);

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
    debugPrint("Job : Undo");
    state.undo();
    debugPrint("Undo stack lenght : ${state.undoStack.length} ");
    forceRebuild();
  }

  // doesnt enable redo after undo
  void shadowUndo() {
    debugPrint("Job : Shadow Undo");
    state.shadowUndo();
    debugPrint("Undo stack lenght : ${state.undoStack.length} ");
    forceRebuild();
  }

  void redo() {
    debugPrint("Job : Redo");
    state.redo();
    debugPrint("Redo stack lenght : ${state.redoStack.length} ");
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
    addAndDo(
      ManualDoable(
        executeBase: () {
          polygon.points.last = point;
        },
        undoBase: () {
          polygon.points.removeLast();
        },
      ),
    );
  }

  void actionAddPointToPolyline(PolylineEntry polyline, LatLng point) {
    addAndDo(
      ManualDoable(
        executeBase: () {
          polyline.points.add(point);
        },
        undoBase: () {
          polyline.points.removeLast();
        },
      ),
    );
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

  void actionReorderEntry(MapLayer layer, int oldIndex, int newIndex) {
    addAndDo(
      ManualDoable(
        executeBase: () {
          layer.items.swapByIndex(oldIndex, newIndex);
        },
        undoBase: () {
          layer.items.swapByIndex(newIndex, oldIndex);
        },
      ),
    );
  }

  void actionToggleEntryVisibility(FlutterMapEntry entry) {
    addAndDo(
      ManualDoable(
        executeBase: entry.toggleVisiblity,
        undoBase: entry.toggleVisiblity,
      ),
    );
  }

  void actionToggleLayerVisibility(MapLayer layer) {
    addAndDo(
      ManualDoable(
        executeBase: layer.toggleVisiblity,
        undoBase: layer.toggleVisiblity,
      ),
    );
  }

  void actionRemoveLayer(MapLayer layer) {
    MapLayer? data;
    addAndDo(
      ManualDoable(
        executeBase: () {
          data = layer;
          _mapLayerList.items.remove(layer);
        },
        undoBase: () {
          _mapLayerList.items.add(data!);
        },
      ),
    );
  }

  void actionRemoveEntryFromLayer(FlutterMapEntry entry, MapLayer layer) {
    FlutterMapEntry? data;
    int? index;
    addAndDo(
      ManualDoable(
        executeBase: () {
          data = entry;
          index = layer.items.indexOf(entry);
          layer.items.removeAt(index!);
        },
        undoBase: () {
          layer.items.insert(index!, data!);
        },
      ),
    );
  }

  void actionMoveEntryToBottom(FlutterMapEntry entry, MapLayer layer) {
    int? index;
    addAndDo(
      ManualDoable(
        executeBase: () {
          index = layer.items.moveToLastGetIndex(entry);
        },
        undoBase: () {
          layer.items.moveLastToIndex(index!);
        },
      ),
    );
  }

  void actionMoveEntryToTop(FlutterMapEntry entry, MapLayer layer) {
    int? index;
    addAndDo(
      ManualDoable(
        executeBase: () {
          index = layer.items.moveToFirstGetIndex(entry);
        },
        undoBase: () {
          layer.items.moveFirstToIndex(index!);
        },
      ),
    );
  }

  void actionMoveLayerToBottom(MapLayer layer) {
    int? index;
    addAndDo(
      ManualDoable(
        executeBase: () {
          index = _mapLayerList.items.moveToLastGetIndex(layer);
        },
        undoBase: () {
          _mapLayerList.items.moveLastToIndex(index!);
        },
      ),
    );
  }

  void actionMoveLayerToTop(MapLayer layer) {
    int? index;
    addAndDo(
      ManualDoable(
        executeBase: () {
          index = _mapLayerList.items.moveToFirstGetIndex(layer);
        },
        undoBase: () {
          _mapLayerList.items.moveFirstToIndex(index!);
        },
      ),
    );
  }

  void actionAddLayer(MapLayer layer) {
    addAndDo(
      ManualDoable(
        executeBase: () {
          _mapLayerList.addUnique(layer);
        },
        undoBase: () {
          _mapLayerList.items.removeLast();
        },
      ),
    );
  }

  void actionRenameLayer(MapLayer layer, String newName) {
    String? previousName;
    addAndDo(
      ManualDoable(
        executeBase: () {
          previousName = layer.name;
          layer.name = newName;
        },
        undoBase: () {
          layer.name = previousName!;
        },
      ),
    );
  }

  void actionRenameEntry(FlutterMapEntry entry, String newName) {
    String? previousName;
    addAndDo(
      ManualDoable(
        executeBase: () {
          previousName = entry.name;
          entry.name = newName;
        },
        undoBase: () {
          entry.name = previousName!;
        },
      ),
    );
  }

  void restoreFromPoints() {
    state.restore();
  }

  void setClearRedoAfterUndo() {
    state.clearRedoAfterUndo = true;
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
