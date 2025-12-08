import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapify/data/providers/input_list_coordinates_provider.dart';
import 'package:mapify/features/add_map_layer/widgets/draggable_coordinates_sheet.dart';

void showCoordinatesButtomSheet(
  BuildContext context,
  WidgetRef ref, {
  required Function(dynamic) then,

  /// Whether to be able to input radius in [DraggableCoordinatesSheet]
  ///
  /// if set to true, only one coordinate input field will be shown.
  bool needsRadiusField = false,
  int minNumberOfCoordinatesFields = 1,
  int? maxNumberOfCoordinatesFields,
  required String title,
}) {
  assert(
    (maxNumberOfCoordinatesFields ?? 1) >= 1,
    "maxNumberOfCoordinatesFields cant be less than one.",
  );
  assert(
    minNumberOfCoordinatesFields >= 1,
    "minNumberOfCoordinatesFields cant be less than one.",
  );
  assert(
    minNumberOfCoordinatesFields <=
        (maxNumberOfCoordinatesFields ?? double.infinity),
    "minNumberOfCoordinatesFields cant be more than maxNumberOfCoordinatesFields",
  );
  InputListCoordinates inputListNotifier = ref.read(
    inputListCoordinatesProvider.notifier,
  );
  ref.watch(inputListCoordinatesProvider);
  inputListNotifier.needsRadiusField = needsRadiusField;
  inputListNotifier.minNumberOfCoordinatesFields = minNumberOfCoordinatesFields;
  inputListNotifier.maxNumberOfCoordinatesFields = maxNumberOfCoordinatesFields;
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
