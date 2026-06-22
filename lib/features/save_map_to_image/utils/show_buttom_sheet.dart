import 'package:flutter/material.dart';
import 'package:geoink/core/ui/widgets/custom_draggable_sheet.dart';
import 'package:geoink/features/save_map_to_image/buttom_sheet.dart';

Future showSaveToImageButtomSheet(BuildContext context) {
  return showModalBottomSheet(
    isDismissible: false,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    context: context,
    builder: (context) => CustomDraggableSheet(
      initialChildSize: 0.7,
      builder: (context, scrollController) {
        return SaveToImageButtomSheet(scrollController: scrollController);
      },
    ),
  );
}
