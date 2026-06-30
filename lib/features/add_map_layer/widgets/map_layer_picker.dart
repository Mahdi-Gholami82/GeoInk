import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:geoink/data/providers/input_list_coordinates.dart';
import 'package:geoink/data/providers/map_tiles.dart';

class MapLayerPicker extends ConsumerStatefulWidget {
  const MapLayerPicker({super.key,required this.entryType});
  final EntryType entryType;
  @override
  ConsumerState<MapLayerPicker> createState() => _MapLayerPickerState();
}

class _MapLayerPickerState extends ConsumerState<MapLayerPicker> {
  late TextEditingController controller;
  late InputListCoordinatesNotifier inputListCoordinatesNotifier;
  late InputListCoordinatesState inputListState;

  void _handleTextChange() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    super.initState();
    inputListCoordinatesNotifier = ref.read(
      inputListCoordinatesProvider.notifier,
    );
    controller = TextEditingController();
    controller.addListener(_handleTextChange);
    inputListState = ref.read(inputListCoordinatesProvider);
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
                inputListState.layer = value;
          },
          controller: controller,
          enableFilter: true,
          dropdownMenuEntries: [
            DropdownMenuEntry(value: null, label: "main"),
            ...collection
                .where((e) => e.isDefault == false && e.entryType == widget.entryType)
                .map((e) => DropdownMenuEntry(value: e, label: e.name)),
            if (controller.text.isNotEmpty && controller.text.trim() != "main")
              DropdownMenuEntry(
                value: MapLayer(
                  name: controller.text, entryType: widget.entryType,
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
