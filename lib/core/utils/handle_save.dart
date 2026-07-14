import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoink/core/ui/lock_screen_on_future.dart';
import 'package:geoink/core/utils/process_file_path.dart';
import 'package:geoink/data/models/geoink_project.dart';
import 'package:geoink/data/models/prefs_state.dart';
import 'package:geoink/data/providers/projects.dart';

Future<void> _doHandleSaveAs(WidgetRef ref) async {
  ProjectNotifier projectNotifier = ref.read(projectProvider.notifier);
  GeoinkProject? project = ref.read(projectProvider);
  String exportResult = projectNotifier.export();
  var savedPath = await FilePicker.platform.saveFile(
    lockParentWindow: true,
    dialogTitle: "Save Project",
    bytes: utf8.encode(exportResult),
  );
  if (savedPath != null) {
    if (project!.title == null) {
      Map decoded = jsonDecode(exportResult);
      String name = getNameFromPath(savedPath);
      decoded["properties"]["title"] = name;
      File(savedPath).writeAsString(jsonEncode(decoded));
      projectNotifier.update(project.copyWith(title: name, path: savedPath));
    } else {
      projectNotifier.updatePath(savedPath);
    }
    PrefsState.addToRecentProjects(ref.read(projectProvider)!);
  }
}

Future<void> handleSaveAs(BuildContext context, WidgetRef ref) async {
  return lockScreenOnFuture(context, _doHandleSaveAs(ref));
}

Future<void> handleSave(BuildContext context, WidgetRef ref) async {
  ProjectNotifier projectNotifier = ref.read(projectProvider.notifier);
  GeoinkProject? project = ref.read(projectProvider);
  assert(project != null);
  String? path = project?.path;
  if (path == null) {
    await handleSaveAs(context, ref);
  } else {
    await projectNotifier.saveToPath();
  }
}
