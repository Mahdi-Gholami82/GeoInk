import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:geoink/data/providers/map_tiles_provider.dart';

class FlutterMapDropdownMenu extends ConsumerWidget {
  final Widget child;
  final FlutterMapEntry entry;
  final MapLayer layer;
  final menuController = MenuController();

  FlutterMapDropdownMenu({
    super.key,
    required this.child,
    required this.entry,
    required this.layer,
  });

  List<Widget> getMenu(BuildContext context, WidgetRef ref) {
    TileEntriesNotifier tileEntriesNotifier = ref.read(
      tileEntriesProvider.notifier,
    );

    List<MapLayer> tileEntries = ref.read(tileEntriesProvider).items;

    List<Widget> menu = [
      MenuItemButton(
        leadingIcon: Icon(
          entry.visible ? Icons.visibility : Icons.visibility_off,
        ),
        child: Text("Visibility"),
        onPressed: () {
          entry.toggleVisiblity();
          tileEntriesNotifier.forceRebuild();
        },
      ),
      MenuItemButton(
        leadingIcon: Icon(Icons.delete),
        child: Text("Remove"),
        onPressed: () {
          showDialog(
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
            if (value) {
              layer.items.remove(entry);
              if (layer.isEmpty) {
                ref.read(tileEntriesProvider).items.remove(layer);
              }
              tileEntriesNotifier.forceRebuild();
            }
          });
        },
      ),
      MenuItemButton(
        leadingIcon: Icon(Icons.arrow_upward),
        child: Text("Move to top"),
        onPressed: () {
          layer.items.remove(entry);
          layer.items.insert(0, entry);
          tileEntriesNotifier.forceRebuild();
        },
      ),
      MenuItemButton(
        leadingIcon: Icon(Icons.arrow_downward),
        child: Text("Move to buttom"),
        onPressed: () {
          layer.items.remove(entry);
          layer.items.add(entry);
          tileEntriesNotifier.forceRebuild();
        },
      ),
      // TODO: Change properties impl in menu
      // MenuItemButton(
      //   leadingIcon: Icon(Icons.settings_applications),
      //   child: Text("Change properties"),
      //   onPressed: () {},
      // ),
    ];

    return menu;
  }

  void toggleMenu() {
    if (!menuController.isOpen) {
      menuController.open();
    } else {
      menuController.close();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MenuAnchor(
      controller: menuController,
      menuChildren: getMenu(context, ref),
      child: GestureDetector(
        child: child,
        onSecondaryTap: toggleMenu,
        onLongPress: toggleMenu,
        onTap: () {
          menuController.close();
        },
      ),
    );
  }
}
