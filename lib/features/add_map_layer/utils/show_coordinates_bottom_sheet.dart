import 'package:geoink/data/models/coordinates_sheet_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoink/core/ui/widgets/custom_draggable_sheet.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:geoink/data/providers/input_list_coordinates.dart';
import 'package:geoink/features/add_map_layer/widgets/coordinates_sheet.dart';

Future<InputCoordinatesResult?> showCoordinatesButtomSheet(
  BuildContext context,
  WidgetRef ref, {
  required String title,
  required EntryType type,
  bool isBulk = false,
}) {
  InputListCoordinatesNotifier inputListNotifier = ref.read(
    inputListCoordinatesProvider.notifier,
  );
  inputListNotifier.initSheetListInput(initType: type, isBulk: isBulk);
  ref.watch(inputListCoordinatesProvider);
  return showModalBottomSheet<InputCoordinatesResult>(
    isDismissible: false,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    context: context,
    builder: (context) => CustomDraggableSheet(
      initialChildSize: 0.6,
      builder: (context, scrollController) {
        return CoordinatesSheet(
          scrollController: scrollController,
          title: title,
        );
      },
    ),
  );
}
