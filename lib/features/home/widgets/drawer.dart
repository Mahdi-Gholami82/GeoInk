import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:GeoInk/data/models/flutter_map_entry.dart';
import 'package:GeoInk/data/providers/map_tiles_provider.dart';
import 'package:GeoInk/features/home/widgets/flutter_map_dropdown_menu.dart';

class MapDrawer extends ConsumerStatefulWidget {
  const MapDrawer({super.key});

  @override
  ConsumerState<MapDrawer> createState() => _MapDrawerState();
}

class _MapDrawerState extends ConsumerState<MapDrawer> {
  late TileEntriesNotifier tileEntriesNotifier;
  late List<MapLayer> layers;
  late List<ExpansibleController> controllers;

  @override
  void initState() {
    tileEntriesNotifier = ref.read(tileEntriesProvider.notifier);
    layers = ref.read(tileEntriesProvider).items;
    controllers = List.generate(
      layers.length,
      (index) => ExpansibleController(),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void collapseAllExceptIndex(int selectedIndex) {
      for (int index = 0; index < controllers.length; index++) {
        if (index != selectedIndex) {
          controllers[index].collapse();
        }
      }
    }

    return Drawer(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        children: [
          SizedBox(
            height: 100,
            width: double.infinity,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                'Map Layers',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              onReorderItem: (oldIndex, newIndex) {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                layers.insert(newIndex, layers.removeAt(oldIndex));
                controllers.insert(newIndex, controllers.removeAt(oldIndex));
                tileEntriesNotifier.updateState(layers);
              },
              buildDefaultDragHandles: false,
              itemBuilder: (BuildContext context, int layerIndex) {
                MapLayer layer = layers[layerIndex];
                var controller = controllers[layerIndex];
                return ReorderableDragStartListener(
                  key: ValueKey(layer.name),
                  index: layerIndex,
                  child: Material(
                    child: Listener(
                      onPointerDown: (event) {
                        collapseAllExceptIndex(layerIndex);
                      },
                      child: ExpansionTile(
                        key: ValueKey(layer.name),
                        title: Text(layer.name),
                        controller: controller,
                        children: [
                          ReorderableListView.builder(
                            key: PageStorageKey('inner-${layer.name}'),
                            buildDefaultDragHandles: false,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            onReorder: (int oldIndex, int newIndex) {
                              tileEntriesNotifier.setConsumersState(() {
                                if (oldIndex < newIndex) {
                                  newIndex -= 1;
                                }
                                final FlutterMapEntry item = layer.items
                                    .removeAt(oldIndex);
                                layer.items.insert(newIndex, item);
                              });
                            },
                            itemCount: layer.items.length,
                            itemBuilder: (context, itemIndex) {
                              FlutterMapEntry item = layer.items[itemIndex];
                              return ReorderableDragStartListener(
                                key: ValueKey('${item.name}-padding'),
                                index: itemIndex,
                                child: FlutterMapDropdownMenu(
                                  entry: item,
                                  layer: layer,
                                  child: ListTile(
                                    title: Text(item.name),
                                    key: ValueKey(item.name),
                                    trailing: IconButton(
                                      onPressed: () {
                                        tileEntriesNotifier.setConsumersState(
                                          item.toggleVisiblity,
                                        );
                                      },
                                      icon: Icon(
                                        item.visible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              itemCount: layers.length,
            ),
          ),
        ],
      ),
    );
  }
}
