import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:geoink/core/ui/map_features_icons.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:geoink/data/providers/map_layer_list.dart';
import 'package:geoink/features/add_map_layer/utils/show_coordinates_bottom_sheet.dart';

class AddMapFeatureFab extends ConsumerWidget {
  const AddMapFeatureFab({super.key, on});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    MapLayerListNotifier tileEntriesNotifier = ref.read(
      mapLayerListProvider.notifier,
    );

    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      spacing: 3,
      children: [
        SpeedDialChild(
          key: ValueKey("speedDial${EntryType.marker.name}Add"),
          child: const Icon(MapIcons.marker),
          label: "Marker",
          onTap: () {
            showCoordinatesButtomSheet(
              context,
              ref,
              title: "Add Marker",
              type: EntryType.marker,
            ).then((value) {
              if (value != null) {
                tileEntriesNotifier.addMarker(value);
              }
            });
          },
        ),
        SpeedDialChild(
          key: ValueKey("speedDial${EntryType.polyline.name}Add"),
          child: const Icon(MapIcons.polyline),
          label: "Polyline",
          onTap: () {
            showCoordinatesButtomSheet(
              context,
              ref,
              title: "Add Polyline",
              type: EntryType.polyline,
              initialChildSize: 0.7,
            ).then((value) {
              if (value != null) {
                tileEntriesNotifier.addPolyLine(value);
              }
            });
          },
        ),
        SpeedDialChild(
          key: ValueKey("speedDial${EntryType.circle.name}Add"),
          child: const Icon(MapIcons.circle),
          label: "Circle",
          onTap: () {
            showCoordinatesButtomSheet(
              context,
              ref,
              title: "Add Circle",
              type: EntryType.circle,
              initialChildSize: 0.7,
            ).then((value) {
              if (value != null) {
                tileEntriesNotifier.addCircle(value);
              }
            });
          },
        ),
        SpeedDialChild(
          key: ValueKey("speedDial${EntryType.polygon.name}Add"),
          child: const Icon(MapIcons.polygon),
          label: "Polygon",
          onTap: () {
            showCoordinatesButtomSheet(
              context,
              ref,
              title: "Add Polygon",
              type: EntryType.polygon,
              initialChildSize: 0.8,
            ).then((value) {
              if (value != null) {
                tileEntriesNotifier.addPolygon(value);
              }
            });
          },
        ),
        // TODO: Implement overlay image adder
        // SpeedDialChild(
        //   child: const Icon(Icons.image_outlined),
        //   label: "Overlay Image",
        //   onTap: null,
        // ),
      ],
    );
  }
}
