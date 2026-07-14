import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoink/core/utils/handle_save.dart';
import 'package:geoink/data/providers/projects.dart';
import 'package:geoink/features/appbar/widgets/appbar_menu.dart';

class FileMenu extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ProjectNotifier projectNotifier = ref.read(projectProvider.notifier);
    ref.watch(projectProvider);

    return AppbarMenu(
      title: Text("File"),
      menuChildren: [
        MenuItemButton(
          leadingIcon: Icon(Icons.file_open),
          onPressed: () async {
            var result = await FilePicker.platform.pickFiles(
              dialogTitle: "Open Project",
            );
            if (result != null) {
              var file = File(result.files.single.path!);
              try {
                projectNotifier.import(file.readAsStringSync());
              } on Exception {
                // TODO: message to user
              }
            }
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
