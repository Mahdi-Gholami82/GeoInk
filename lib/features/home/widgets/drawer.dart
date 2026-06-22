import 'package:geoink/core/ui/map_features_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:geoink/data/providers/map_tiles_provider.dart';
import 'package:geoink/features/home/widgets/flutter_map_dropdown_menu.dart';

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    layers = ref.watch(tileEntriesProvider).items.where((element) => !(element.isDefault && element.isEmpty)).toList();
    controllers = List.generate(
      layers.length,
      (index) => ExpansibleController(),
    );

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
                        MenuItemButton(onPressed: () {
                          showDialog(context: context, builder:(context) {
                                final formKey = GlobalKey<FormState>();
                                var controller = TextEditingController();
                                EntryType selectedType = EntryType.Circle;

                                void validateAndPop() {
                                  final bool isValid =
                                      formKey.currentState?.validate() ?? false;
                                  if (isValid) {
                                    setState(() {
                                      ref.read(tileEntriesProvider).addLayer(MapLayer(
                                                      name: controller.text,
                                                      entryType: selectedType,
                                                    ));
                                    });
                                    Navigator.of(context).pop();
                                  }
                                }

                                return AlertDialog(
                                  title: Text("Add a layer"),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      DropdownMenu(
                                        initialSelection: selectedType,
                                        dropdownMenuEntries: EntryType.values
                                            .map(
                                              (e) => DropdownMenuEntry(
                                                value: e,
                                                label: e.name,
                                              ),
                                            )
                                            .toList(),
                                        onSelected: (value) {
                                          selectedType = value ?? selectedType;
                                        },
                                      ),
                                      Form(
                                        key: formKey,
                                        child: TextFormField(
                                          controller: controller,
                                          onFieldSubmitted: (Text) {
                                            validateAndPop();
                                          },
                                          validator: (value) {
                                            if (value == null ||
                                                !RegExp(
                                                  r"^[\w\s]+$",
                                                ).hasMatch(value.trim())) {
                                              return "Invalid name";
                                            } else if (layers.contains(
                                              MapLayer(
                                                name: value,
                                                entryType: selectedType,
                                              ),
                                            )) {
                                              return "Duplicate name";
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(onPressed: () {
                                        validateAndPop();
                                      },
                                      child: Text("ok"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("cancel"),
                                    ),
                                  ],
                                );
                          },);
                        },child: Text("New Layer"),)
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
                layers.insert(newIndex, layers.removeAt(oldIndex));
                controllers.insert(newIndex, controllers.removeAt(oldIndex));
                tileEntriesNotifier.updateStateByItems(layers);
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
                        leading: Icon(MapIcons.fromType(layer.entryType)),
                        title: Text(layer.name),
                        controller: controller,
                        children: [
                          ReorderableListView.builder(
                            key: PageStorageKey('inner-${layer.name}'),
                            buildDefaultDragHandles: false,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            onReorderItem: (int oldIndex, int newIndex) {
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
