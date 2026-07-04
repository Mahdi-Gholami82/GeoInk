import 'package:flutter/material.dart';
import 'package:geoink/core/ui/widgets/custom_draggable_sheet.dart';
import 'package:geoink/features/save_map_to_image/bottom_sheet.dart';

Future showSaveToImageBottomSheet(BuildContext context) {
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
