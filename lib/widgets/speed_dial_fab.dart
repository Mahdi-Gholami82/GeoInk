import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:mapify/providers/map_tiles_provider.dart';
import 'package:mapify/widgets/add_map_layer/add_coordinates_sheet.dart';
import 'package:provider/provider.dart';

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
            showModalBottomSheet(
              isDismissible: false,
              context: context,
              builder: (context) => AddCoordinatesSheet(title: "Add Marker"),
            ).then((value) {
              if (value != null) {
                context.read<TileEntriesProvider>().addMarker(value);
              }
            });
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.polyline),
          label: "Polyline",
          onTap: () {
            showModalBottomSheet(
              isDismissible: false,
              context: context,
              builder: (context) => AddCoordinatesSheet(title: "Add Polyline"),
            ).then((value) {
              if (value != null) {
                context.read<TileEntriesProvider>().addPolyLine(value);
              }
            });
          },
        ),
        SpeedDialChild(child: Icon(Icons.adjust), label: "Circle", onTap: null),
        SpeedDialChild(
          child: Icon(Icons.hexagon_outlined),
          label: "Polygon",
          onTap: () {
            showModalBottomSheet(
              isDismissible: false,
              context: context,
              builder: (context) => AddCoordinatesSheet(title: "Add Polygon"),
            ).then((value) {
              if (value != null) {
                context.read<TileEntriesProvider>().addPolygon(value);
              }
            });
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.image_outlined),
          label: "Overlay Image",
          onTap: null,
        ),
      ],
    );
  }
}
