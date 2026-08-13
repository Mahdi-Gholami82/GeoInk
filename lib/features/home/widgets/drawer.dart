import 'package:geoink/core/ui/exiver/etc.dart';
import 'package:geoink/core/ui/exiver/exiver.dart';
import 'package:geoink/core/ui/exiver/nested_child.dart';
import 'package:geoink/core/ui/map_features_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:geoink/data/providers/history.dart';
import 'package:geoink/data/providers/map_layer_list.dart';
import 'package:geoink/features/home/widgets/new_layer_dialogue.dart';

extension Drawer on MenuController {
  void toggle([Offset? position]) {
    if (!isOpen) {
      open(position: position);
    } else {
      close();
    }
  }
}

class MapDrawer extends ConsumerStatefulWidget {
  const MapDrawer({super.key});

  @override
  ConsumerState<MapDrawer> createState() => _MapDrawerState();
}

class _MapDrawerState extends ConsumerState<MapDrawer> {
  late MapLayerListNotifier tileEntriesNotifier;
  late List<MapLayer> layers;
  Map<MapLayer, ExpansibleController> controllers = {};

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
    tileEntriesNotifier = ref.read(mapLayerListProvider.notifier);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    layers = ref.watch(mapLayerListProvider).items;
    ref.watch(historyProvider);
    HistoryNotifier historyNotifier = ref.read(historyProvider.notifier);

    var children = List.generate(layers.length, (index) {
      var currentLayer = layers[index];
      return NestedChild(
        (context, childIndex) {
          FlutterMapEntry entry = currentLayer.items[childIndex];
          var menuController = MenuController();

          List<Widget> menu = [
            MenuItemButton(
              leadingIcon: Icon(
                entry.visible ? Icons.visibility : Icons.visibility_off,
              ),
              child: Text("Visibility"),
              onPressed: () {
                historyNotifier.actionToggleEntryVisibility(entry);
              },
            ),
            MenuItemButton(
              leadingIcon: Icon(Icons.delete),
              child: Text("Remove"),
              onPressed: () {
                showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text("Remove \"${entry.name}\"?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Text("cancel"),
                        ),

                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: Text("ok"),
                        ),
                      ],
                    );
                  },
                ).then((value) {
                  if (value!) {
                    historyNotifier.actionRemoveEntryFromLayer(
                      entry,
                      currentLayer,
                    );
                  }
                });
              },
            ),
            MenuItemButton(
              leadingIcon: Icon(Icons.arrow_upward),
              child: Text("Move to top"),
              onPressed: () {
                historyNotifier.actionMoveEntryToTop(entry, currentLayer);
              },
            ),
            MenuItemButton(
              leadingIcon: Icon(Icons.arrow_downward),
              child: Text("Move to bottom"),
              onPressed: () {
                historyNotifier.actionMoveEntryToBottom(entry, currentLayer);
              },
            ),
            // TODO: Change properties impl in menu
            // MenuItemButton(
            //   leadingIcon: Icon(Icons.settings_applications),
            //   child: Text("Change properties"),
            //   onPressed: () {},
            // ),
          ];

          return MenuAnchor(
            controller: menuController,
            menuChildren: menu,
            child: GestureDetector(
              onSecondaryTapDown: (details) {
                menuController.toggle(details.localPosition);
              },
              onTap: () {
                menuController.close();
              },
              child: ListTile(
                contentPadding: EdgeInsets.all(0),
                leading: SizedBox(
                  height: 40,
                  child: VerticalDivider(
                    thickness: 3,
                    color: _colorFromEntry(entry),
                    radius: BorderRadius.circular(3),
                  ),
                ),
                title: Text(entry.name),
                key: ValueKey(entry.name),
                trailing: Builder(
                  builder: (context) {
                    var iconMenuController = MenuController();
                    return MenuAnchor(
                      controller: iconMenuController,
                      menuChildren: menu,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              historyNotifier.actionToggleEntryVisibility(
                                entry,
                              );
                            },
                            icon: Icon(
                              entry.visible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              iconMenuController.toggle();
                            },
                            icon: Icon(Icons.more_vert),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
        headerBuilder: () => Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Icon(MapIcons.fromType(currentLayer.entryType)),
            ),
            Text(currentLayer.name),
          ],
        ),

        childCount: currentLayer.length,
        index: index,
        onReorder: (fromIndex, toIndex, isUpperHalf) {
          historyNotifier.actionReorderEntry(
            currentLayer,
            fromIndex,
            getInsertInIndex(
              fromIndex,
              toIndex,
              isUpperHalf,
            ).clamp(0, currentLayer.length - 1),
          );
        },
      );
    });

    return Column(
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
          child: ExiverList(
            headerColor: Theme.of(context).colorScheme.primaryContainer,
            childDraggingColor: theme.colorScheme.surface,
            headerPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 3,
            ),
            headerShape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(10),
            ),
            childPadding: EdgeInsetsGeometry.symmetric(horizontal: 10),
            onReorder: (fromIndex, toIndex, isUpperHalf) {
              historyNotifier.actionReorderLayer(
                fromIndex,
                getInsertInIndex(
                  fromIndex,
                  toIndex,
                  isUpperHalf,
                ).clamp(0, layers.length - 1),
              );
            },
            children: children,
          ),
        ),
      ],
    );
  }
}
