import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoink/core/ui/lock_screen_on_future.dart';
import 'package:geoink/data/models/geoink_project.dart';
import 'package:geoink/data/providers/projects.dart';
import 'package:geoink/features/appbar/widgets/appbar_menu.dart';
import 'package:geoink/features/home/utils/show_projects_sheet.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:geoink/data/providers/map_layer_list.dart';
import 'package:geoink/features/save_map_to_image/utils/show_bottom_sheet.dart';

class MapDropdownMenu extends ConsumerStatefulWidget {
  const MapDropdownMenu({super.key});

  @override
  ConsumerState<MapDropdownMenu> createState() => _MapDropdownMenuState();
}

class _MapDropdownMenuState extends ConsumerState<MapDropdownMenu> {
  late MapLayerList mapLayerList;
  late MapLayerListNotifier tileEntriesNotifier;
  late ProjectNotifier projectNotifier;

  @override
  void initState() {
    super.initState();
    mapLayerList = ref.read(mapLayerListProvider);
    tileEntriesNotifier = ref.read(mapLayerListProvider.notifier);
    projectNotifier = ref.read(projectProvider.notifier);
  }

  @override
  Widget build(BuildContext context) {
    return AppbarMenu(
      title: Text("Map"),
      menuChildren: [
        Column(
          children: [
            MenuItemButton(
              leadingIcon: Icon(Icons.map),
              onPressed: () {
                showProjectsSheet(context);
              },
              child: const Text("Projects"),
            ),
            MenuItemButton(
              leadingIcon: Icon(Icons.file_download),
              onPressed: () async {
                var result = await lockScreenOnFuture(
                  context,
                  FilePicker.platform.pickFiles(
                    dialogTitle: "Import From GeoJSON",
                  ),
                );
                if (result != null) {
                  GeoinkProject? project = null;
                  try {
                    project = await GeoinkProject.fromFile(
                      File(result.files.single.path!),
                    );
                  } on Exception {
                    return;
                  }
                  try {
                    projectNotifier.import(project.path!);
                  } on Exception {
                    // TODO: message to user
                  }
                }
              },
              child: const Text("Import"),
            ),
            MenuItemButton(
              leadingIcon: Icon(Icons.file_upload),
              onPressed: () async {
                await lockScreenOnFuture(
                  context,
                  FilePicker.platform.saveFile(
                    dialogTitle: "Export As GeoJSON",
                    bytes: utf8.encode(projectNotifier.export()),
                  ),
                );
              },
              child: const Text("Export"),
            ),
            MenuItemButton(
              leadingIcon: Icon(Icons.image_outlined),
              onPressed: () {
                showSaveToImageBottomSheet(context);
              },
              child: const Text("To Image"),
            ),

            // TODO: Implement parser tool.
            // MenuItemButton(
            //   leadingIcon: Icon(Icons.code),
            //   onPressed: () {},
            //   child: const Text("Parser"),
            // ),
          ],
        ),
      ],
    );
  }
}
