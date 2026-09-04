import 'package:geoink/core/ui/exiver/etc.dart';
import 'package:geoink/core/ui/exiver/exiver.dart';
import 'package:geoink/core/ui/exiver/nested_child.dart';
import 'package:geoink/core/ui/map_features_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoink/core/ui/widgets/responsive_drawer.dart';
import 'package:geoink/core/utils/standard_name.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:geoink/data/providers/history.dart';
import 'package:geoink/data/providers/map_layer_list.dart';
import 'package:geoink/features/home/widgets/new_layer_dialog.dart';
import 'package:geoink/features/home/widgets/rename_dialog.dart';

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
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    List<MapLayer> layers = ref.watch(mapLayerListProvider).items;
    ref.watch(historyProvider);
    HistoryNotifier historyNotifier = ref.read(historyProvider.notifier);

    var children = List.generate(layers.length, (index) {
      var currentLayer = layers[index];
      return NestedChild(
        key: ValueKey(currentLayer.name),
        (context, childIndex) {
          FlutterMapEntry entry = currentLayer.items[childIndex];

          List<Widget> menu = [
            MenuItemButton(
              leadingIcon: Icon(
                entry.visible ? Icons.visibility_off : Icons.visibility,
              ),
              child: const Text("Visibility"),
              onPressed: () {
                historyNotifier.actionToggleEntryVisibility(entry);
              },
            ),
            MenuItemButton(
              leadingIcon: const Icon(Icons.abc),
              child: const Text("Rename"),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => RenameDialog(
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
              leadingIcon: const Icon(Icons.delete),
              child: const Text("Remove"),
              onPressed: () {
                showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: const Text("Remove entry?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: const Text("cancel"),
                        ),

                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: const Text("ok"),
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
              leadingIcon: const Icon(Icons.arrow_upward),
              child: const Text("Move to top"),
              onPressed: () {
                historyNotifier.actionMoveEntryToTop(entry, currentLayer);
              },
            ),
            MenuItemButton(
              leadingIcon: const Icon(Icons.arrow_downward),
              child: const Text("Move to bottom"),
              onPressed: () {
                historyNotifier.actionMoveEntryToBottom(entry, currentLayer);
              },
            ),
            // TODO: Change properties impl in menu
            // MenuItemButton(
            //   leadingIcon: const Icon(Icons.settings_applications),
            //   child: const Text("Change properties"),
            //   onPressed: () {},
            // ),
          ];

          return MenuAnchor(
            menuChildren: menu,
            builder: (context, childMenuController, child) {
              return GestureDetector(
                onSecondaryTapDown: (details) {
                  childMenuController.toggle(details.localPosition);
                },
                onTap: () {
                  childMenuController.close();
                },
                child: ListTile(
                  contentPadding: const EdgeInsets.all(0),
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
                      return MenuAnchor(
                        menuChildren: menu,
                        builder: (context, iconMenuController, child) {
                          return Row(
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
                                icon: const Icon(Icons.more_vert),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
        headerBuilder: (context, doExpand, expanded) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            child: MenuAnchor(
              menuChildren: [
                MenuItemButton(
                  leadingIcon: Icon(
                    currentLayer.visible
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  child: const Text("Visibility"),
                  onPressed: () {
                    historyNotifier.actionToggleLayerVisibility(currentLayer);
                  },
                ),
                MenuItemButton(
                  leadingIcon: const Icon(Icons.abc),
                  child: const Text("Rename"),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => RenameDialog(
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
                  leadingIcon: const Icon(Icons.delete),
                  child: const Text("Remove"),
                  onPressed: () {
                    showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: const Text("Remove layer?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              child: const Text("cancel"),
                            ),

                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                              child: const Text("ok"),
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
                  leadingIcon: const Icon(Icons.arrow_upward),
                  child: const Text("Move to top"),
                  onPressed: () {
                    historyNotifier.actionMoveLayerToTop(currentLayer);
                  },
                ),
                MenuItemButton(
                  leadingIcon: const Icon(Icons.arrow_downward),
                  child: const Text("Move to bottom"),
                  onPressed: () {
                    historyNotifier.actionMoveLayerToBottom(currentLayer);
                  },
                ),
              ],
              builder: (context, headerMonuroller, child) {
                return GestureDetector(
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
                    tileColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHigh,
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
                          child: Icon(
                            MapIcons.fromType(currentLayer.entryType),
                          ),
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
                );
              },
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
                          controller.toggle();
                        },
                        icon: const Icon(Icons.more_vert),
                      );
                    },
                    menuChildren: [
                      MenuItemButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return NewLayerDialog();
                            },
                          );
                        },
                        child: const Text("New Layer"),
                      ),
                      MenuItemButton(
                        onPressed: () {
                          ResponsiveDrawer.of(context).controller.close();
                        },
                        child: const Text("Close"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          child: ExiverList(
            childDraggingColor: theme.colorScheme.surface,
            childPadding: const EdgeInsetsGeometry.symmetric(horizontal: 10),
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
