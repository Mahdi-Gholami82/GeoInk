import 'dart:io';

import 'package:geoink/core/utils/project_storage.dart';
import 'package:geoink/data/models/geoink_project.dart';
import 'package:geoink/data/models/prefs_state.dart';

Future<List<GeoinkProject>> loadProjectsList() async {
  if (!Platform.isAndroid) {
    return PrefsState.loadRecentProjects();
  } else {
    var files = await AndroidProjectStore.getProjectFiles();
    List<String> deleted = PrefsState.deletedProjectsAndroidPaths;
    return Future.wait(
      files
          .where((e) => !deleted.contains(e.path))
          .map((e) => GeoinkProject.fromFile(e)),
    );
  }
}
