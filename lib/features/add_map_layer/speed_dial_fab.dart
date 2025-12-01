import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:mapify/data/providers/input_list_coordinates_provider.dart';
import 'package:mapify/data/providers/map_tiles_provider.dart';
import 'package:mapify/features/add_map_layer/draggable_coordinates_sheet.dart';
import 'package:provider/provider.dart';

void showCoordinatesButtomSheet(
  BuildContext context, {
  required Function(dynamic) then,

  /// Whether to be able to input radius in [DraggableCoordinatesSheet]
  ///
  /// if set to true, only one coordinate input field will be shown.
  bool needsRadiusField = false,
  int minNumberOfCoordinatesFields = 1,
  required String title,
}) {
  context.read<InputListCoordinatesProvider>().needsRadiusField =
      needsRadiusField;
  context.read<InputListCoordinatesProvider>().minNumberOfCoordinatesFields =
      minNumberOfCoordinatesFields;
  showModalBottomSheet(
    isDismissible: false,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    context: context,
    builder: (context) =>
        DraggableCoordinatesSheet(title, initialChildSize: 0.6),
  ).then(then);
}

class AddMapElementFab extends StatelessWidget {
  const AddMapElementFab({super.key, on});

  @override
  Widget build(BuildContext context) {
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
              title: "Add Marker",
              minNumberOfCoordinatesFields: 1,
              then: (value) {
                if (value != null) {
                  context.read<TileEntriesProvider>().addMarker(value);
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
              title: "Add Polyline",
              minNumberOfCoordinatesFields: 2,
              then: (value) {
                if (value != null) {
                  context.read<TileEntriesProvider>().addPolyLine(value);
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
              title: "Add Circle",
              then: (value) {
                if (value != null) {
                  context.read<TileEntriesProvider>().addCircle(value);
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
              title: "Add Polygon",
              minNumberOfCoordinatesFields: 3,
              then: (value) {
                if (value != null) {
                  context.read<TileEntriesProvider>().addPolygon(value);
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
