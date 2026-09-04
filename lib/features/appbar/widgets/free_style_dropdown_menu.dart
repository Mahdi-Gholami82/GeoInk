import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:geoink/data/providers/map_camera.dart';
import 'package:geoink/features/appbar/widgets/appbar_menu.dart';
import 'package:geoink/features/freestyle/page.dart';
import 'package:flutter/material.dart';
import 'package:geoink/core/ui/map_features_icons.dart';
import 'package:geoink/features/home/page.dart';

class FreeStyleDropdownMenu extends ConsumerStatefulWidget {
  const FreeStyleDropdownMenu({super.key});

  @override
  ConsumerState<FreeStyleDropdownMenu> createState() =>
      _FreeStyleDropdownMenuState();
}

class _FreeStyleDropdownMenuState extends ConsumerState<FreeStyleDropdownMenu> {
  @override
  Widget build(BuildContext context) {
    void pushFreeStyleWithType(EntryType type) {
      MapCamera mapCamera = HomePageState.of(context).mapController.camera;
      ref.read(mapCameraProvider.notifier).update(mapCamera);
      Navigator.of(context).pushNamed(FreeStylePage.route, arguments: type);
    }

    return AppbarMenu(
      title: const Text("Free Style"),
      menuChildren: [
        Column(
          children: [
            MenuItemButton(
              leadingIcon: Icon(MapIcons.marker),
              onPressed: () {
                pushFreeStyleWithType(EntryType.marker);
              },
              child: Text(EntryType.marker.name),
            ),
            MenuItemButton(
              leadingIcon: Icon(MapIcons.circle),
              onPressed: () {
                pushFreeStyleWithType(EntryType.circle);
              },
              child: Text(EntryType.circle.name),
            ),
            MenuItemButton(
              leadingIcon: Icon(MapIcons.polygon),
              onPressed: () {
                pushFreeStyleWithType(EntryType.polygon);
              },
              child: Text(EntryType.polygon.name),
            ),
            MenuItemButton(
              leadingIcon: Icon(MapIcons.polyline),
              onPressed: () {
                pushFreeStyleWithType(EntryType.polyline);
              },
              child: Text(EntryType.polyline.name),
            ),
          ],
        ),
      ],
    );
  }
}
