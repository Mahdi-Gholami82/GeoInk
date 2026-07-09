import 'package:flutter_map/flutter_map.dart';
import 'package:geoink/data/inherited/inherited_map_controller.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:geoink/data/models/freestyle_arguments.dart';
import 'package:geoink/features/freestyle/page.dart';
import 'package:flutter/material.dart';
import 'package:geoink/core/ui/map_features_icons.dart';
import 'package:geoink/features/appbar/widgets/ink_well_text_button.dart';

class FreeStyleDropdownMenu extends StatefulWidget {
  const FreeStyleDropdownMenu({super.key});

  @override
  State<FreeStyleDropdownMenu> createState() => _FreeStyleDropdownMenuState();
}

class _FreeStyleDropdownMenuState extends State<FreeStyleDropdownMenu> {
  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      style: MenuStyle(
        shape: WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
      ),
      menuChildren: [
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: 150),
          child: Column(
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
        ),
      ],
      alignmentOffset: Offset(0, 5),
      builder: (context, controller, child) {
        return InkWellTextButton(
          title: "Free Style",
          onTap: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        );
      },
    );
  }
}
