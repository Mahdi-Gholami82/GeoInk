import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoink/core/ui/lock_screen_on_future.dart';
import 'package:geoink/data/providers/projects.dart';
import 'package:geoink/features/appbar/widgets/appbar_menu.dart';

class FileMenu extends ConsumerWidget {
  const FileMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(projectProvider);
    var projectNotifier = ref.read(projectProvider.notifier);

    return AppbarMenu(
      title: const Text("File"),
      menuChildren: [
        MenuItemButton(
          leadingIcon: const Icon(Icons.file_open),
          onPressed: () {
            lockScreenOnFuture(
              Overlay.of(context),
              job: () async {
                var files = await FilePicker.pickFiles(
                  dialogTitle: "Open Project",
                );
                if (files.isNotEmpty) {
                  var file = File(files.first.path!);
                  await projectNotifier.importProjectFromFile(file);
                }
              },
              onError: () {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to load project")),
                  );
                }
              },
            );
          },
          child: const Text("Open"),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.save),
          onPressed: () {
            projectNotifier.handleSave(context);
          },
          child: const Text("Save"),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.save_as),
          onPressed: () {
            lockScreenOnFuture(
              Overlay.of(context),
              job: projectNotifier.handleSaveAs,
            );
          },
          child: const Text("Save as"),
        ),
      ],
    );
  }
}
