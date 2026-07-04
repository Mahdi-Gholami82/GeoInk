import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:geoink/data/providers/history.dart';
import 'package:geoink/data/providers/map_tiles.dart';

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
    final HistoryNotifier historyNotifier = ref.read(historyProvider.notifier);


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
              historyNotifier.actionRemoveEntryFromLayer(entry,layer);
            }
          });
        },
      ),
      MenuItemButton(
        leadingIcon: Icon(Icons.arrow_upward),
        child: Text("Move to top"),
        onPressed: () {
          historyNotifier.actionMoveEntryToTop(entry, layer);
        },
      ),
      MenuItemButton(
        leadingIcon: Icon(Icons.arrow_downward),
        child: Text("Move to bottom"),
        onPressed: () {
          historyNotifier.actionMoveEntryToBottom(entry, layer);
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
        onTap: () {
          menuController.close();
        },
      ),
    );
  }
}
