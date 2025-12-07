import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:mapify/data/providers/map_tiles_provider.dart';
import 'package:mapify/features/add_map_layer/utils/show_coordinates_buttom_sheet.dart';

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
              minNumberOfCoordinatesFields: 1,
              maxNumberOfCoordinatesFields: 1,
              then: (value) {
                if (value != null) {
                  tileEntriesNotifier.addMarker(value);
                }
              },
            );
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
              minNumberOfCoordinatesFields: 2,
              then: (value) {
                if (value != null) {
                  tileEntriesNotifier.addPolyLine(value);
                }
              },
            );
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.adjust),
          label: "Circle",
          onTap: () {
            showCoordinatesButtomSheet(
              context,
              ref,
              maxNumberOfCoordinatesFields: 1,
              title: "Add Circle",
              then: (value) {
                if (value != null) {
                  tileEntriesNotifier.addCircle(value);
                }
              },
              needsRadiusField: true,
            );
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
              minNumberOfCoordinatesFields: 3,
              then: (value) {
                if (value != null) {
                  tileEntriesNotifier.addPolygon(value);
                }
              },
            );
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
