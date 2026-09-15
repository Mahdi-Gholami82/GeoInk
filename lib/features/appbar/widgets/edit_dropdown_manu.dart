import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoink/core/ui/widgets/desktop_only_tooltip.dart';
import 'package:geoink/data/providers/history.dart';
import 'package:geoink/data/providers/projects.dart';
import 'package:geoink/features/appbar/widgets/appbar_menu.dart';
import 'package:geoink/features/appbar/widgets/project_edit_sheet.dart';

class EditDropdownManu extends ConsumerWidget {
  const EditDropdownManu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    HistoryNotifier historyNotifier = ref.read(historyProvider.notifier);
    return AppbarMenu(
      title: const Text("Edit"),
      menuChildren: [
        MenuItemButton(
          leadingIcon: Icon(Icons.assignment),
          child: Text("Current Project"),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isDismissible: false,
              isScrollControlled: true,
              useSafeArea: true,
              backgroundColor: Colors.transparent,
              builder: (context) {
                return ProjectEditSheet(
                  project: ref.read(projectProvider)!,
                  onSave: (value) {
                    ref.read(projectProvider.notifier).update(value);
                  },
                );
              },
            );
          },
        ),
        DesktopOnlyTooltip(
          toolTip: "Ctrl + Z",
          child: MenuItemButton(
            leadingIcon: const Icon(Icons.undo),
            onPressed: () {
              historyNotifier.undo();
            },
            child: const Text('Undo'),
          ),
        ),
        DesktopOnlyTooltip(
          toolTip: "Ctrl + Shift + Z",
          child: MenuItemButton(
            leadingIcon: const Icon(Icons.redo),
            onPressed: () {
              historyNotifier.redo();
            },
            child: const Text('Redo'),
          ),
        ),
      ],
    );
  }
}
