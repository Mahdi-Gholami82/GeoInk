import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoink/core/utils/show_simple_snackbar.dart';
import 'package:geoink/core/utils/standard_name.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:geoink/data/providers/input_list_coordinates.dart';
import 'package:geoink/data/providers/map_layer_list.dart';

class MapLayerPicker extends ConsumerStatefulWidget {
  const MapLayerPicker({super.key, required this.entryType});
  final EntryType entryType;
  @override
  ConsumerState<MapLayerPicker> createState() => _MapLayerPickerState();
}

class _MapLayerPickerState extends ConsumerState<MapLayerPicker> {
  late TextEditingController controller;
  late InputListCoordinatesNotifier inputListCoordinatesNotifier;
  late InputListCoordinatesState inputListState;
  late MapLayer? initialSelection;
  late MapLayerList mapLayerList = ref.read(mapLayerListProvider);
  late List<MapLayer> layers = mapLayerList.items
      .where((e) => e.entryType == widget.entryType)
      .toList();
  late String defaultLayerName = widget.entryType.defaultLayerName;
  DropdownMenuEntry<MapLayer?>? addMenuEntry;

  List<DropdownMenuEntry<MapLayer?>> filterCallback(
    List<DropdownMenuEntry<MapLayer?>> entries,
    String filter,
  ) {
    final String trimmedFilter = filter.trim().toLowerCase();
    if (trimmedFilter.isEmpty) {
      return entries;
    }

    List<DropdownMenuEntry<MapLayer?>> filtered = entries
        .where(
          (DropdownMenuEntry<MapLayer?> entry) =>
              entry.label.toLowerCase().contains(trimmedFilter),
        )
        .toList();

    if (filtered.isEmpty || filtered.every((e) => e.label != filter)) {
      addMenuEntry = DropdownMenuEntry<MapLayer?>(
        value: MapLayer(name: controller.text, entryType: widget.entryType),
        label: controller.text,
        labelWidget: Text("+ Add : ${controller.text}"),
      );
      filtered.add(addMenuEntry!);
    }

    return filtered;
  }

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
    initialSelection = layers.firstOrNull;
    if (initialSelection == null) {
      defaultLayerName = mapLayerList.getUniqueName(defaultLayerName);
    }
  }

  @override
  void dispose() {
    controller.removeListener(_handleTextChange);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownMenu(
          filterCallback: filterCallback,
          width: 180,
          hintText: initialSelection?.name ?? defaultLayerName,
          onSelected: (value) {
            if (value == null) {
              inputListState.layer = initialSelection;
              return;
            }
            var match = standardNameRegex.firstMatch(value.name);
            String? name = match?.group(1);
            if (match == null || name == null) {
              showSimpleSnackBar(
                context,
                message: "Invalid name / Must be shorter than $maxCharInName",
              );
              return;
            }
            inputListState.layer = value;
          },
          controller: controller,
          enableFilter: true,
          dropdownMenuEntries: [
            if (initialSelection == null)
              DropdownMenuEntry(value: null, label: defaultLayerName),
            ...layers.map((e) => DropdownMenuEntry(value: e, label: e.name)),
            ?addMenuEntry,
          ],
        ),
        const Text(
          "Layer",
          style: TextStyle(fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
