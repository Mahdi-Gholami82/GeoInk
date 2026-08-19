import 'package:geoink/core/ui/exiver/etc.dart';
import 'package:geoink/core/ui/exiver/exiver.dart';
import 'package:geoink/core/ui/exiver/nested_child.dart';
import 'package:geoink/core/ui/map_features_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoink/core/ui/widgets/ok_cancel_dialog.dart';
import 'package:geoink/core/ui/widgets/responsive_drawer.dart';
import 'package:geoink/core/utils/standard_name.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:geoink/data/providers/history.dart';
import 'package:geoink/data/providers/map_layer_list.dart';
import 'package:geoink/features/home/widgets/new_layer_dialogue.dart';
import 'package:geoink/features/home/widgets/rename_dialogue.dart';

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
          var childMenuController = MenuController();

          List<Widget> menu = [
            MenuItemButton(
              leadingIcon: Icon(
                entry.visible ? Icons.visibility_off : Icons.visibility,
              ),
              child: Text("Visibility"),
              onPressed: () {
                historyNotifier.actionToggleEntryVisibility(entry);
              },
            ),
            MenuItemButton(
              leadingIcon: Icon(Icons.abc),
              child: Text("Rename"),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => RenameDialogue(
                    initialName: entry.name,
                    onRename: (String newName) {
                      historyNotifier.actionRenameEntry(entry, newName);
                    },
                    validator: (value) => standarNameValidatorForEntries(
                      value,
                      currentLayer.items,
                    ),
                  ),
                );
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
                      content: Text("Remove entry?"),
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
            controller: childMenuController,
            menuChildren: menu,
            child: GestureDetector(
              onSecondaryTapDown: (details) {
                childMenuController.toggle(details.localPosition);
              },
              onTap: () {
                childMenuController.close();
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
        headerBuilder: (context, doExpand, expanded) {
          var headerMonuroller = MenuController();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            child: MenuAnchor(
              controller: headerMonuroller,
              menuChildren: [
                MenuItemButton(
                  leadingIcon: Icon(
                    currentLayer.visible
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  child: Text("Visibility"),
                  onPressed: () {
                    historyNotifier.actionToggleLayerVisibility(currentLayer);
                  },
                ),
                MenuItemButton(
                  leadingIcon: Icon(Icons.abc),
                  child: Text("Rename"),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => RenameDialogue(
                        initialName: currentLayer.name,
                        onRename: (String newName) {
                          historyNotifier.actionRenameLayer(
                            currentLayer,
                            newName,
                          );
                        },
                        validator: (value) =>
                            standarNameValidatorForLayers(value, layers),
                      ),
                    );
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
                          content: Text("Remove layer?"),
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
                        historyNotifier.actionRemoveLayer(currentLayer);
                      }
                    });
                  },
                ),
                MenuItemButton(
                  leadingIcon: Icon(Icons.arrow_upward),
                  child: Text("Move to top"),
                  onPressed: () {
                    historyNotifier.actionMoveLayerToTop(currentLayer);
                  },
                ),
                MenuItemButton(
                  leadingIcon: Icon(Icons.arrow_downward),
                  child: Text("Move to bottom"),
                  onPressed: () {
                    historyNotifier.actionMoveLayerToBottom(currentLayer);
                  },
                ),
              ],
              child: GestureDetector(
                onSecondaryTapDown: (details) {
                  headerMonuroller.toggle(details.localPosition);
                },
                child: ListTile(
                  trailing: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                    ),
                  ),
                  tileColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(10),
                  ),
                  onTap: () {
                    headerMonuroller.close();
                    doExpand();
                  },
                  title: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(MapIcons.fromType(currentLayer.entryType)),
                      ),
                      Flexible(
                        child: Text(
                          currentLayer.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            decoration: currentLayer.visible
                                ? TextDecoration.none
                                : TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },

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
                      MenuItemButton(
                        onPressed: () {
                          ResponsiveDrawer.of(context).controller.close();
                        },
                        child: Text("Close"),
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
            childDraggingColor: theme.colorScheme.surface,
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
