import 'package:flutter/material.dart';
import 'package:mapify/features/home/widgets/ink_well_text_button.dart';

class MapDropdownMenu extends StatefulWidget {
  const MapDropdownMenu({super.key});

  @override
  State<MapDropdownMenu> createState() => _MapDropdownMenuState();
}

class _MapDropdownMenuState extends State<MapDropdownMenu> {
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
                leadingIcon: Icon(Icons.file_download),
                onPressed: () {},
                child: const Text('Import'),
              ),
              MenuItemButton(
                leadingIcon: Icon(Icons.file_upload),
                onPressed: () {},
                child: const Text('Export'),
              ),
              MenuItemButton(
                leadingIcon: Icon(Icons.image_outlined),
                onPressed: () {},
                child: const Text('To Image'),
              ),
              MenuItemButton(
                leadingIcon: Icon(Icons.code),
                onPressed: () {},
                child: const Text('Parser'),
              ),
            ],
          ),
        ),
      ],
      alignmentOffset: Offset(0, 5),
      builder: (context, controller, child) {
        return InkWellTextButton(
          title: "Map",
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
