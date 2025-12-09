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
            if (value != null) {
              setState(() {
                tileEntriesNotifier.addMapLayerEntry(
                  layerEntry: value,
                  ignoreIfExists: true,
                );
                inputListCoordinatesNotifier.layer = value;
              });
            }
          },
          controller: controller,
          enableFilter: true,
          dropdownMenuEntries:
              collection
                  .map(
                    (e) => DropdownMenuEntry(
                      value: e,
                      label: e.name,
                      labelWidget: Text(e.name),
                    ),
                  )
                  .toList() +
              [
                if (controller.text.isNotEmpty)
                  DropdownMenuEntry(
                    value: MapLayerEntry(
                      name: controller.text,
                      type: widget.type,
                    ),
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
