import 'package:geoink/core/ui/map_features_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:geoink/data/providers/history.dart';
import 'package:geoink/data/providers/map_tiles.dart';
import 'package:geoink/features/home/widgets/flutter_map_dropdown_menu.dart';
import 'package:geoink/features/home/widgets/new_layer_dialogue.dart';

class MapDrawer extends ConsumerStatefulWidget {
  const MapDrawer({super.key});

  @override
  ConsumerState<MapDrawer> createState() => _MapDrawerState();
}

class _MapDrawerState extends ConsumerState<MapDrawer> {
  late TileEntriesNotifier tileEntriesNotifier;
  late List<MapLayer> layers;
  Map<MapLayer,ExpansibleController> controllers = {};

  Color _colorFromEntry(FlutterMapEntry entry) {
    switch (EntryType.fromType(entry.runtimeType)) {
      case EntryType.polygon:
        return (entry as PolygonEntry).borderColor;
      case EntryType.polyline:
        return (entry as PolylineEntry).color;
      case EntryType.circle:
        return (entry as CircleEntry).borderColor;
      case EntryType.marker:
        return (entry as MarkerEntry).color;
    }
  }

  @override
  void initState() {
    tileEntriesNotifier = ref.read(tileEntriesProvider.notifier);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (var layer in ref.read(tileEntriesProvider).items) {
      if (!controllers.containsKey(layer)) {
        controllers[layer] = ExpansibleController();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    layers = ref
        .watch(tileEntriesProvider)
        .items
        .where((element) => !(element.isDefault && element.isEmpty))
        .toList();
    ref.watch(historyProvider);
    HistoryNotifier historyNotifier = ref.read(historyProvider.notifier);

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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Map Layers',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  Align(
                    alignment: AlignmentGeometry.topEnd,
                    child: MenuAnchor(
                      builder: (context, controller, child) {
                        return IconButton(
                          style: IconButton.styleFrom(
                            foregroundColor: Theme.of(
                              context,
                            ).primaryIconTheme.color,
                          ),
                          onPressed: () {
                            if (controller.isOpen) {
                              controller.close();
                            } else {
                              controller.open();
                            }
                          },
                          icon: Icon(Icons.more_vert),
                        );
                      },
                      menuChildren: [
                        MenuItemButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return NewLayerDialogue();
                              },
                            );
                          },
                          child: Text("New Layer"),
                        ),
                      ],
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.more_vert),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              onReorderItem: (oldIndex, newIndex) {
                historyNotifier.actionReorderLayer(oldIndex, newIndex);
              },
              buildDefaultDragHandles: false,
              itemBuilder: (BuildContext context, int layerIndex) {
                MapLayer layer = layers[layerIndex];
                var controller = controllers[layer];
                return ReorderableDragStartListener(
                  key: ValueKey(layer.name),
                  index: layerIndex,
                  child: Material(
                    color: theme.colorScheme.surfaceContainer,
                    child: ExpansionTile(
                      key: ValueKey(layer.name),
                      leading: Icon(MapIcons.fromType(layer.entryType)),
                      title: Text(layer.name),
                      controller: controller,
                      expansionAnimationStyle: AnimationStyle.noAnimation,
                      children: [
                        Padding(
                          padding: EdgeInsetsGeometry.only(left: 10),
                          child: Material(
                            color: theme.colorScheme.surfaceContainer,
                            child: ReorderableListView.builder(
                              key: PageStorageKey('inner-${layer.name}'),
                              buildDefaultDragHandles: false,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              onReorderItem: (int oldIndex, int newIndex) {
                                historyNotifier.actionReorderEntry(layer, oldIndex, newIndex);
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
                                      onTap: () {},
                                      leading: SizedBox(
                                        height: 40,
                                        child: VerticalDivider(
                                          thickness: 3,
                                          color: _colorFromEntry(item),
                                          radius: BorderRadius.circular(3),
                                        ),
                                      ),
                                      title: Text(item.name),
                                      key: ValueKey(item.name),
                                      trailing: IconButton(
                                        onPressed: () {
                                          historyNotifier.actionToggleEntryVisibility(item);
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
                          ),
                        ),
                      ],
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
