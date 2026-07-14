import 'package:geoink/data/inherited/inherited_map_controller.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:geoink/data/models/freestyle_arguments.dart';
import 'package:geoink/features/appbar/widgets/appbar_menu.dart';
import 'package:geoink/features/freestyle/page.dart';
import 'package:flutter/material.dart';
import 'package:geoink/core/ui/map_features_icons.dart';

class FreeStyleDropdownMenu extends StatefulWidget {
  const FreeStyleDropdownMenu({super.key});

  @override
  State<FreeStyleDropdownMenu> createState() => _FreeStyleDropdownMenuState();
}

class _FreeStyleDropdownMenuState extends State<FreeStyleDropdownMenu> {
  @override
  Widget build(BuildContext context) {
    return AppbarMenu(
      title: Text("Free Style"),
      menuChildren: [
        Column(
          children: [
            MenuItemButton(
              leadingIcon: Icon(MapIcons.marker),
              onPressed: () {
                Navigator.of(context).pushNamed(
                  FreeStylePage.route,
                  arguments: FreestyleArguments(
                    initSelectedType: EntryType.marker,
                    mapCamera: InheritedMapController.of(
                      context,
                    ).mapController.camera,
                  ),
                );
              },
              child: Text(EntryType.marker.name),
            ),
            MenuItemButton(
              leadingIcon: Icon(MapIcons.circle),
              onPressed: () {
                Navigator.of(context).pushNamed(
                  FreeStylePage.route,
                  arguments: FreestyleArguments(
                    initSelectedType: EntryType.circle,
                    mapCamera: InheritedMapController.of(
                      context,
                    ).mapController.camera,
                  ),
                );
              },
              child: Text(EntryType.circle.name),
            ),
            MenuItemButton(
              leadingIcon: Icon(MapIcons.polygon),
              onPressed: () {
                Navigator.of(context).pushNamed(
                  FreeStylePage.route,
                  arguments: FreestyleArguments(
                    initSelectedType: EntryType.polygon,
                    mapCamera: InheritedMapController.of(
                      context,
                    ).mapController.camera,
                  ),
                );
              },
              child: Text(EntryType.polygon.name),
            ),
            MenuItemButton(
              leadingIcon: Icon(MapIcons.polyline),
              onPressed: () {
                Navigator.of(context).pushNamed(
                  FreeStylePage.route,
                  arguments: FreestyleArguments(
                    initSelectedType: EntryType.polyline,
                    mapCamera: InheritedMapController.of(
                      context,
                    ).mapController.camera,
                  ),
                );
              },
              child: Text(EntryType.polyline.name),
            ),
          ],
        ),
      ],
    );
  }
}
