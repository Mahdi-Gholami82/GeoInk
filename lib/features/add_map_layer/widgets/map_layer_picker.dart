import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapify/data/models/flutter_map_entry.dart';
import 'package:mapify/data/providers/input_list_coordinates_provider.dart';
import 'package:mapify/data/providers/map_tiles_provider.dart';

class MapLayerPicker extends ConsumerStatefulWidget {
  const MapLayerPicker({super.key, required this.type});
  final EntryType type;
  @override
  ConsumerState<MapLayerPicker> createState() => _MapLayerPickerState();
}

class _MapLayerPickerState extends ConsumerState<MapLayerPicker> {
  late TextEditingController controller;
  late TileEntriesNotifier tileEntriesNotifier;
  late InputListCoordinatesNotifier inputListCoordinatesNotifier;
  late InputListCoordinatesState inputListState;
  late MapLayerEntry mainLayer;
  MapLayerEntry? newLayer;

  void _handleTextChange() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    tileEntriesNotifier = ref.read(tileEntriesProvider.notifier);
    inputListCoordinatesNotifier = ref.read(
      inputListCoordinatesProvider.notifier,
    );
    controller = TextEditingController();
    controller.addListener(_handleTextChange);
    mainLayer = tileEntriesNotifier.getDefaultLayerEntry(widget.type);
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
    List<MapLayerEntry> collection = ref.read(tileEntriesProvider);

    return Row(
      spacing: 10,
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownMenu(
          hintText: "main",
          onSelected: (value) {
            if (value == newLayer) {
              if ("main" != controller.text.trim()) {
                newLayer = MapLayerEntry(
                  name: controller.text,
                  type: widget.type,
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
                .where((e) => e.isDefault == false && e.type == widget.type)
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
