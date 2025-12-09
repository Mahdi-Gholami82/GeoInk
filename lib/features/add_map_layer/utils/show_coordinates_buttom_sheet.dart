import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapify/data/models/flutter_map_entry.dart';
import 'package:mapify/data/providers/input_list_coordinates_provider.dart';
import 'package:mapify/features/add_map_layer/widgets/draggable_coordinates_sheet.dart';

void showCoordinatesButtomSheet(
  BuildContext context,
  WidgetRef ref, {
  required Function(dynamic) then,
  required String title,
  required EntryType type,
}) {
  InputListCoordinatesNotifier inputListNotifier = ref.read(
    inputListCoordinatesProvider.notifier,
  );
  inputListNotifier.initSheetListInput(initType: type);
  ref.watch(inputListCoordinatesProvider);
  showModalBottomSheet(
    isDismissible: false,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    context: context,
    builder: (context) =>
        DraggableCoordinatesSheet(title, initialChildSize: 0.6),
  ).then((value) {
    ref.invalidate(inputListCoordinatesProvider);
    then(value);
  });
}
