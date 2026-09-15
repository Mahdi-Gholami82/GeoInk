import 'dart:convert';
import 'dart:io';

import 'package:geoink/core/utils/process_file_path.dart';
import 'package:geoink/data/models/prefs_state.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:geoink/core/utils/unique_name_in_list.dart';

class SaveProjectResult {
  SaveProjectResult({required this.savedName, required this.file});

  final String savedName;
  final File file;
}

class AndroidProjectStore {
  AndroidProjectStore._();

  static late Directory directory;

  static Future<void> processDeletedProjects() async {
    await Future.wait(
      PrefsState.deletedProjectsAndroidPaths.map(
        (e) => AndroidProjectStore.delete(getFileNameFromPath(e)),
      ),
    );

    PrefsState.deletedProjectsAndroidPaths = [];
  }

  static Future<void> ensureInitialized() async {
    final appDirectory = await getApplicationSupportDirectory();

    directory = Directory(path.join(appDirectory.path, "GeoInk"));

    await directory.create(recursive: true);
  }

  static Future<SaveProjectResult> save({
    required String fileName,
    required String content,
    bool overWrite = true,
  }) async {
    assert(fileName.isNotEmpty, "fileName must not be empty");

    String savedName = fileName;

    if (!overWrite) {
      final existingNames = await directory
          .list()
          .where((entity) => entity is File)
          .map((entity) => path.basename(entity.path))
          .toList();

      savedName = getUniqueNameFromTargets(fileName, existingNames);
    }

    final file = File(path.join(directory.path, savedName));

    await file.writeAsString(content, encoding: utf8, flush: true);

    return SaveProjectResult(savedName: savedName, file: file);
  }

  static Future<String> read(String fileName) async {
    final file = File(path.join(directory.path, fileName));

    return file.readAsString(encoding: utf8);
  }

  static Future<File> getFile(String fileName) async {
    return File(path.join(directory.path, fileName));
  }

  static Future<bool> exists(String fileName) async {
    final file = File(path.join(directory.path, fileName));

    return file.exists();
  }

  static Future<List<File>> getProjectFiles() async {
    return directory
        .list()
        .where((entity) => entity is File)
        .cast<File>()
        .toList();
  }

  static Future<List<String>> getProjectNames() async {
    return directory
        .list()
        .where((entity) => entity is File)
        .map((entity) => path.basename(entity.path))
        .toList();
  }

  static Future<void> delete(String fileName) async {
    final file = File(path.join(directory.path, fileName));

    if (await file.exists()) {
      await file.delete();
    }
  }
}
