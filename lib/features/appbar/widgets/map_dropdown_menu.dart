import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoink/data/providers/history.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:geoink/data/providers/map_tiles.dart';
import 'package:geoink/features/appbar/widgets/ink_well_text_button.dart';
import 'package:geoink/features/save_map_to_image/utils/show_buttom_sheet.dart';

class MapDropdownMenu extends ConsumerStatefulWidget {
  const MapDropdownMenu({super.key});

  @override
  ConsumerState<MapDropdownMenu> createState() => _MapDropdownMenuState();
}

class _MapDropdownMenuState extends ConsumerState<MapDropdownMenu> {
  late MapLayerList mapLayerList;
  late TileEntriesNotifier tileEntriesNotifier;

  @override
  void initState() {
    super.initState();
    mapLayerList = ref.read(tileEntriesProvider);
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
                onPressed: () async {
                  var result = await FilePicker.platform.pickFiles();
                  if (result != null) {
                    var file = File(result.files.single.path!);
                    try {
                      var featureCollection = GeoJSONFeatureCollection.fromJSON(
                        file.readAsStringSync(),
                      );
                      List<LayerEntryMap> layerEntryMaps = tileEntriesNotifier
                          .fromGeoJSONFeatureCollection(featureCollection); 
                      ref.read(historyProvider.notifier).actionListAddAllToAllLayer(layerEntryMaps);
                    } on Exception {
                      // TODO: message to user
                    }
                    ref.read(tileEntriesProvider.notifier).forceRebuild();
                  }
                },
                child: const Text('Import'),
              ),
              MenuItemButton(
                leadingIcon: Icon(Icons.file_upload),
                onPressed: () async {
                  await FilePicker.platform.saveFile(
                    bytes: utf8.encode(
                      mapLayerList.toGeoJsonFeatureCollection().toJSON(),
                    ),
                  );
                },
                child: const Text('Export'),
              ),
              MenuItemButton(
                leadingIcon: Icon(Icons.image_outlined),
                onPressed: () {
                  showSaveToImageButtomSheet(context);
                },
                child: const Text('To Image'),
              ),
              // TODO: Implement parser tool.
              // MenuItemButton(
              //   leadingIcon: Icon(Icons.code),
              //   onPressed: () {},
              //   child: const Text('Parser'),
              // ),
              MenuItemButton(
                leadingIcon: Icon(Icons.undo),
                onPressed: () {
                  ref.read(historyProvider.notifier).undo();
                },
                child: const Text('Undo'),
              ),
              MenuItemButton(
                leadingIcon: Icon(Icons.redo),
                onPressed: () {
                  ref.read(historyProvider.notifier).redo();
                },
                child: const Text('Redo'),
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
