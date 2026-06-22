import 'package:geoink/data/models/action_manager.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';


extension <T> on List<T> {
  void swapValue(T oldValue,T newValue) {
    int index = this.indexOf(oldValue);
    assert(index != -1);
    this[index] = newValue;
  }
}


class MapEntryMemento extends Doable {
  MapEntryMemento({
    required MapLayer layer,
    required FlutterMapEntry newEntry,
    required FlutterMapEntry oldEntry,
  }) : super(executeBase: () {
      layer.items.swapValue(oldEntry,newEntry);
    },undoBase: () {
      layer.items.swapValue(newEntry,oldEntry);
    });

  MapEntryMemento.fromIndex({
    required MapLayer layer,
    required FlutterMapEntry newEntry,
    required FlutterMapEntry oldEntry,
    required int index
  })  : super(executeBase:  () {
      layer.items[index] = newEntry;
    }, undoBase:() {
      layer.items[index] = oldEntry;
    });
}


class MapLayerMemento extends Doable {
  MapLayerMemento({
    required MapLayerList layerList,
    required MapLayer newLayer,
    required MapLayer oldLayer,
  }) : super(executeBase: () {
      layerList.items.swapValue(oldLayer,newLayer);
    },undoBase: () {
      layerList.items.swapValue(newLayer,oldLayer);
    });

  MapLayerMemento.fromIndex({
    required MapLayerList layerList,
    required MapLayer newLayer,
    required MapLayer oldLayer,
    required int index
  }) : super(executeBase:  () {
      layerList.items[index] = newLayer;
    }, undoBase:() {
      layerList.items[index] = oldLayer;
    });
}

class ManualDoable extends Doable {
  ManualDoable({required super.executeBase, required super.undoBase});
}