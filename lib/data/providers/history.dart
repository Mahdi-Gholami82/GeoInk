import 'package:geoink/data/models/action_manager.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:geoink/data/models/map_actions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'history.g.dart';

@Riverpod(keepAlive: true)
class HistoryNotifier extends _$HistoryNotifier {
  @override
  MapHistory build() {
    return MapHistory();
  }

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

  void addAndDo(Doable doable) {
    state.addAndDo(doable);
    forceRebuild();
  }

  void actionAddToLayer(
    MapLayer layer, {
    required FlutterMapEntry entry,
    bool unique = true,
  }) {
    state.addAndDo(
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

  void actionAddAllToLayer(
    MapLayer layer, {
    required List<FlutterMapEntry> entries,
  }) {
    state.addAndDo(
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
    state.addAndDo(
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
    state.addAndDo(
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
    state.addAndDo(
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

  void restoreFromPoints() {
    state.restore();
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
