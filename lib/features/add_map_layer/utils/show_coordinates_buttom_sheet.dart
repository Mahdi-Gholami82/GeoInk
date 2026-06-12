import 'package:GeoInk/data/models/coordinates_sheet_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:GeoInk/core/ui/widgets/custom_draggable_sheet.dart';
import 'package:GeoInk/data/models/flutter_map_entry.dart';
import 'package:GeoInk/data/providers/input_list_coordinates_provider.dart';
import 'package:GeoInk/features/add_map_layer/widgets/coordinates_sheet.dart';

Future<InputCoordinatesResult?> showCoordinatesButtomSheet(
  BuildContext context,
  WidgetRef ref, {
  required String title,
  required EntryType type,
}) {
  InputListCoordinatesNotifier inputListNotifier = ref.read(
    inputListCoordinatesProvider.notifier,
  );
  inputListNotifier.initSheetListInput(initType: type);
  ref.watch(inputListCoordinatesProvider);
  return showModalBottomSheet<InputCoordinatesResult>(
    isDismissible: false,
    isScrollControlled: true,
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
