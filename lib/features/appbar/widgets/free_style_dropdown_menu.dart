import 'package:flutter/material.dart';
import 'package:mapify/core/ui/map_features_icons.dart';
import 'package:mapify/features/appbar/widgets/ink_well_text_button.dart';

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
                onPressed: () {},
                child: const Text('Marker'),
              ),
              MenuItemButton(
                leadingIcon: Icon(MapIcons.circle),
                onPressed: () {},
                child: const Text('Circle'),
              ),
              MenuItemButton(
                leadingIcon: Icon(MapIcons.polygon),
                onPressed: () {},
                child: const Text('Polygon'),
              ),
              MenuItemButton(
                leadingIcon: Icon(MapIcons.polyline),
                onPressed: () {},
                child: const Text('Polyline'),
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
