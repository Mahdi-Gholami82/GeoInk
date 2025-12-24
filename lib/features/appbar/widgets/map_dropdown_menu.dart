import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapify/data/providers/map_tiles_provider.dart';
import 'package:mapify/features/home/widgets/ink_well_text_button.dart';

class MapDropdownMenu extends ConsumerStatefulWidget {
  const MapDropdownMenu({super.key});

  @override
  ConsumerState<MapDropdownMenu> createState() => _MapDropdownMenuState();
}

class _MapDropdownMenuState extends ConsumerState<MapDropdownMenu> {
  late TileEntriesNotifier tileEntriesNotifier;

  @override
  void initState() {
    super.initState();
    tileEntriesNotifier = ref.read(tileEntriesProvider.notifier);
  }

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
                onPressed: () async {
                  await FilePicker.platform.saveFile(
                    bytes: utf8.encode(
                      tileEntriesNotifier.toGeoJsonFeatureCollection().toJSON(),
                    ),
                  );
                },
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
