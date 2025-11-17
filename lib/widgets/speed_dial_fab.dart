import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:mapify/providers/map_tiles_provider.dart';
import 'package:mapify/widgets/add_map_layer/add_marker_dialogue.dart';
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
              context: context,
              builder: (context) => AddMarkerDialogue(),
            ).then((value) {
              context.read<TileEntriesProvider>().addMarker(value);
            });
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.polyline),
          label: "Polyline",
          onTap: null,
        ),
        SpeedDialChild(
          child: Icon(Icons.adjust),
          label: "Circular",
          onTap: null,
        ),
        SpeedDialChild(
          child: Icon(Icons.hexagon_outlined),
          label: "Polygon",
          onTap: null,
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
