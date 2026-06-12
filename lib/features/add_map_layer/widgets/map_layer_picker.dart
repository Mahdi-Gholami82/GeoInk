import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:GeoInk/data/models/flutter_map_entry.dart';
import 'package:GeoInk/data/providers/input_list_coordinates_provider.dart';
import 'package:GeoInk/data/providers/map_tiles_provider.dart';

class MapLayerPicker extends ConsumerStatefulWidget {
  const MapLayerPicker({super.key,required this.entryType});
  final EntryType entryType;
  @override
  ConsumerState<MapLayerPicker> createState() => _MapLayerPickerState();
}

class _MapLayerPickerState extends ConsumerState<MapLayerPicker> {
  late TextEditingController controller;
  late MapLayerList mapLayerList;
  late InputListCoordinatesNotifier inputListCoordinatesNotifier;
  late InputListCoordinatesState inputListState;
  late MapLayer mainLayer;
  MapLayer? newLayer;

  void _handleTextChange() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    mapLayerList = ref.read(tileEntriesProvider);
    inputListCoordinatesNotifier = ref.read(
      inputListCoordinatesProvider.notifier,
    );
    controller = TextEditingController();
    controller.addListener(_handleTextChange);
    mainLayer = mapLayerList.getDefaultLayerEntry(widget.entryType);
    inputListState = ref.read(inputListCoordinatesProvider);
    inputListState.layer = mainLayer;
  }

  @override
  void dispose() {
    controller.removeListener(_handleTextChange);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<MapLayer> collection = ref.read(tileEntriesProvider).items;

    return Row(
      spacing: 10,
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownMenu(
          hintText: "main",
          onSelected: (value) {
            if (value == newLayer) {
              if ("main" != controller.text.trim()) {
                newLayer = MapLayer(
                  name: controller.text, entryType: widget.entryType,
                );
                inputListState.layer = newLayer!;
              }
            } else {
              inputListState.layer = value ?? mainLayer;
            }
          },
          controller: controller,
          enableFilter: true,
          dropdownMenuEntries: [
            DropdownMenuEntry(value: mainLayer, label: "main"),
            ...collection
                .where((e) => e.isDefault == false && e.entryType == widget.entryType)
                .map((e) => DropdownMenuEntry(value: e, label: e.name)),
            if (controller.text.isNotEmpty)
              DropdownMenuEntry(
                value: newLayer,
                label: controller.text,
                labelWidget: Text("+ Add : ${controller.text}"),
              ),
          ],
        ),
        Text("Select Layer", style: TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
