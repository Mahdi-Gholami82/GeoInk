import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:geoink/data/providers/map_tiles.dart';
import 'package:geoink/features/add_map_layer/utils/show_coordinates_bottom_sheet.dart';

class AddMapElementFab extends ConsumerWidget {
  const AddMapElementFab({super.key, on});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TileEntriesNotifier tileEntriesNotifier = ref.read(
      tileEntriesProvider.notifier,
    );

    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      spacing: 3,
      children: [
        SpeedDialChild(
          child: Icon(Icons.location_on),
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
          child: Icon(Icons.polyline),
          label: "Polyline",
          onTap: () {
            showCoordinatesButtomSheet(
              context,
              ref,
              title: "Add Polyline",
              type: EntryType.polyline,
            ).then((value) {
              if (value != null) {
                tileEntriesNotifier.addPolyLine(value);
              }
            });
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.adjust),
          label: "Circle",
          onTap: () {
            showCoordinatesButtomSheet(
              context,
              ref,
              title: "Add Circle",
              type: EntryType.circle,
            ).then((value) {
              if (value != null) {
                tileEntriesNotifier.addCircle(value);
              }
            });
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.hexagon_outlined),
          label: "Polygon",
          onTap: () {
            showCoordinatesButtomSheet(
              context,
              ref,
              title: "Add Polygon",
              type: EntryType.polygon,
            ).then((value) {
              if (value != null) {
                tileEntriesNotifier.addPolygon(value);
              }
            });
          },
        ),
        // TODO: Implement overlay image adder
        // SpeedDialChild(
        //   child: Icon(Icons.image_outlined),
        //   label: "Overlay Image",
        //   onTap: null,
        // ),
      ],
    );
  }
}
