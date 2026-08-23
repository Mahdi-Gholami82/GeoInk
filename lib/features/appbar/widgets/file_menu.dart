import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoink/core/ui/widgets/desktop_only_tooltip.dart';
import 'package:geoink/core/utils/handle_project_files.dart';
import 'package:geoink/data/providers/projects.dart';
import 'package:geoink/features/appbar/widgets/appbar_menu.dart';

class FileMenu extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(projectProvider);

    return AppbarMenu(
      title: Text("File"),
      menuChildren: [
        MenuItemButton(
          leadingIcon: Icon(Icons.file_open),
          onPressed: () async {
            handleOpen(context, ref);
          },
          child: const Text("Open"),
        ),
        MenuItemButton(
          leadingIcon: Icon(Icons.save),
          onPressed: () {
            handleSave(context, ref);
          },
          child: const Text("Save"),
        ),
        MenuItemButton(
          leadingIcon: Icon(Icons.save_as),
          onPressed: () {
            handleSaveAs(context, ref);
          },
          child: const Text("Save as"),
        ),
      ],
    );
  }
}
