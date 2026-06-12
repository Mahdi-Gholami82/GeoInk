import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:GeoInk/data/models/flutter_map_entry.dart';
import 'package:GeoInk/data/providers/map_tiles_provider.dart';
import 'package:GeoInk/features/add_map_layer/utils/show_coordinates_buttom_sheet.dart';

class AddMapElementFab extends ConsumerWidget {
  const AddMapElementFab({super.key, on});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TileEntriesNotifier tileEntriesNotifier = ref.read(
      tileEntriesProvider.notifier,
    );
    MapLayerList tileEntries = ref.read(
      tileEntriesProvider
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
              type: EntryType.Marker,
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
              type: EntryType.Polyline,
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
              type: EntryType.Circle,
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
              type: EntryType.Polygon,
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
