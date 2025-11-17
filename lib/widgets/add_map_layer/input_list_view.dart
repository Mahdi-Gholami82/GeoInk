import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapify/providers/input_list_coordinates_provider.dart';
import 'package:mapify/widgets/add_map_layer/input_list_tile.dart';
import 'package:provider/provider.dart';

class InputListView extends StatefulWidget {
  const InputListView({super.key});

  @override
  State<InputListView> createState() => _InputListViewState();
}

class _InputListViewState extends State<InputListView> {
  late List<LatLng?> coordinates;

  @override
  void initState() {
    super.initState();
  }

  String coordinateToText(LatLng? value) {
    return value == null ? "" : "${value.latitude},${value.longitude}";
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InputListCoordinatesProvider>();
    coordinates = provider.coordinates;
    return ListView.builder(
      itemCount: coordinates.length,
      itemBuilder: (context, index) {
        return InputListTile(
          tileIndex: index,
          title: Text(coordinateToText(coordinates[index])),
          onEditPressed: () {
            provider.editingIndex = index;
            if (provider.editingIndex < provider.coordinates.length - 1) {
              provider.removeNull();
            }
          },
          onSubmit: (value) {
            provider.addCoordinates(value);
            provider.addCoordinates(null);
            provider.editingIndex = coordinates.length - 1;
          },
        );
      },
    );
  }
}
