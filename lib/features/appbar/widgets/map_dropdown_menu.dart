import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:geoink/data/providers/map_tiles_provider.dart';
import 'package:geoink/features/appbar/widgets/ink_well_text_button.dart';
import 'package:geoink/features/save_map_to_image/utils/show_buttom_sheet.dart';

class MapDropdownMenu extends ConsumerStatefulWidget {
  const MapDropdownMenu({super.key});

  @override
  ConsumerState<MapDropdownMenu> createState() => _MapDropdownMenuState();
}

class _MapDropdownMenuState extends ConsumerState<MapDropdownMenu> {
  late MapLayerList mapLayerList;

  @override
  void initState() {
    super.initState();
    mapLayerList = ref.read(tileEntriesProvider);
  }

  EntryType? entryTypeFromGeomatryType(GeoJSONType type, bool hasRadius) {
    switch (type) {
      case GeoJSONType.multiLineString || GeoJSONType.lineString:
        return EntryType.Polyline;
      case GeoJSONType.multiPolygon || GeoJSONType.polygon:
        return EntryType.Polygon;
      case GeoJSONType.point:
        if (hasRadius) return EntryType.Circle;
        return EntryType.Marker;
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
                        while (geomatries.isNotEmpty) {
                          List<GeoJSONGeometry> filteredGeomatries = geomatries
                              .where(
                                (e) => e.type != GeoJSONType.geometryCollection,
                              )
                              .toList();

                          for (var geomatryObject in filteredGeomatries) {
                            {
                              mapLayerList.addFromGeoJsonObject(
                                geomatryObject,
                                properties: properties,
                              );
                            }
                          }
                          geomatries.removeWhere(
                            (e) => filteredGeomatries.contains(e),
                          );
                          geomatries = geomatries.expand((e) {
                            return (e as GeoJSONGeometryCollection).geometries;
                          }).toList();
                        }
                      }
                    } on AssertionError {
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
