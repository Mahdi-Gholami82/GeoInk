import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:mapify/data/models/flutter_map_entry.dart';
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

  EntryType? entryTypeFromGeomatryType(GeoJSONType type, bool hasRadius) {
    switch (type) {
      case GeoJSONType.multiLineString || GeoJSONType.lineString:
        return EntryType.polyline;
      case GeoJSONType.multiPolygon || GeoJSONType.polygon:
        return EntryType.polygon;
      case GeoJSONType.point:
        if (hasRadius) return EntryType.circle;
        return EntryType.marker;
      default:
        return null;
    }
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
                  final stopwatch = Stopwatch();
                  stopwatch.start();
                  if (result != null) {
                    var file = File(result.files.single.path!);
                    try {
                      var featureCollection = GeoJSONFeatureCollection.fromJSON(
                        file.readAsStringSync(),
                      );
                      for (var feature in featureCollection.features) {
                        if (feature == null || feature.geometry == null) {
                          continue;
                        }
                        GeoJSONGeometry geometry = feature.geometry!;
                        Map<String, dynamic> properties =
                            feature.properties ?? {};
                        List<GeoJSONGeometry> geomatries = [geometry];
                        while (geomatries.any(
                          (e) => e.type == GeoJSONType.geometryCollection,
                        )) {
                          geomatries.expand((geomatry) {
                            if (geomatry.type ==
                                GeoJSONType.geometryCollection) {
                              var geomatryCollection =
                                  geometry as GeoJSONGeometryCollection;
                              return geomatryCollection.geometries;
                            }
                            return [geomatry];
                          });
                        }
                        for (var noneCollectionGeomatry in geomatries) {
                          tileEntriesNotifier.addFromGeoJsonObject(
                            noneCollectionGeomatry,
                            properties: properties,
                          );
                        }
                      }
                    } on AssertionError {
                      // TODO: message to user
                    }
                    tileEntriesNotifier.forceRebuild();
                  }
                  stopwatch.stop();
                  print('Execution time: ${stopwatch.elapsed}');
                  print(
                    'Elapsed milliseconds: ${stopwatch.elapsedMilliseconds}ms',
                  );
                  print(
                    'Elapsed microseconds: ${stopwatch.elapsedMicroseconds}us',
                  );
                },
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
