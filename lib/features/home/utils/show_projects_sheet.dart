import 'package:flutter/material.dart';
import 'package:geoink/core/ui/widgets/custom_draggable_sheet.dart';
import 'package:geoink/features/home/widgets/projects_sheet.dart';

Future<String?> showProjectsSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    isDismissible: false,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    context: context,
    useSafeArea: true,
    builder: (context) {
      return CustomDraggableSheet(
        initialChildSize: 1.0,
        minChildSize: 0.8,
        builder: (context, scrollController) {
          return ProjectsSheet(scrollController: scrollController);
        },
      );
    },
  );
}
