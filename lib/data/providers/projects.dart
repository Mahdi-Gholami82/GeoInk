import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geoink/core/utils/process_file_path.dart';
import 'package:geoink/core/utils/project_storage.dart';
import 'package:geoink/core/utils/save_geojson.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:geoink/data/models/geoink_project.dart';
import 'package:geoink/data/models/prefs_state.dart';
import 'package:geoink/data/providers/history.dart';
import 'package:geoink/data/providers/map_layer_list.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'projects.g.dart';

@Riverpod(keepAlive: true)
class ProjectNotifier extends _$ProjectNotifier {
  @override
  GeoinkProject? build() {
    return null;
  }

  MapLayerListNotifier get _mapLayerListNotifier =>
      ref.read(mapLayerListProvider.notifier);

  void update(GeoinkProject newProject) {
    if (Platform.isAndroid &&
        newProject.title != state?.title &&
        newProject.path == state?.path) {
      if (state?.path != null) {
        PrefsState.deletedProjectsAndroidPaths =
            PrefsState.deletedProjectsAndroidPaths..add(state!.path!);
      }
      state = newProject;
      saveToPathAuto();
      return;
    }
    state = newProject;
  }

  void switchProject(GeoinkProject project) {
    PrefsState.setSelectedProject(project);
    PrefsState.addToRecentProjectsIfNotExists(project);
    state = project;
  }

  void updatePath(String? newPath) {
    state = state?.copyWith(path: newPath);
    PrefsState.setSelectedProject(state!);
  }

  String export() {
    assert(state != null);
    Map projectJson = jsonDecode(
      ref.read(mapLayerListProvider).toGeoJsonFeatureCollection().toJSON(),
    );
    projectJson["properties"] = {
      "title": state!.title,
      "description": state!.description,
    };
    return jsonEncode(projectJson);
  }

  void import(String fileText) {
    var featureCollection = GeoJSONFeatureCollection.fromJSON(fileText);
    var mapLayerListNotifier = _mapLayerListNotifier;
    mapLayerListNotifier.reset();
    var localLayerList = EntryType.values
        .map((e) => MapLayer(name: "${e.name} import", entryType: e))
        .toSet();
    List<LayerEntryMap> layerEntryMaps = mapLayerListNotifier
        .fromGeoJSONFeatureCollection(
          featureCollection,
          localLayerList: localLayerList,
        );
    ref
        .read(historyProvider.notifier)
        .actionListAddAllToAllLayer(
          layerEntryMaps,
          createdLayers: localLayerList,
        );
  }

  Future<void> importProjectFromFile(File projectFile) async {
    importFromProject(await GeoinkProject.fromFile(projectFile));
  }

  void importFromProject(GeoinkProject project) {
    if (!File(project.path!).existsSync()) {
      throw PathNotFoundException;
    }
    _mapLayerListNotifier.reset();
    import(File(project.path!).readAsStringSync());
    switchProject(project);
  }

  Future<void> saveToPathAuto() async {
    assert(state != null);
    if (!Platform.isAndroid) {
      assert(state!.path != null && state!.title != null);
      File file = File(state!.path!);
      if (!await file.exists()) {
        file.create(recursive: true);
      }
      await file.writeAsString(export());
    } else {
      var result = await AndroidProjectStore.save(
        fileName: state!.title ?? GeoinkProject.defaultName,
        content: export(),
        overWrite: state!.path != null,
      );

      state = state!.copyWith(title: result.savedName);
    }
  }

  void initNewUnsaved(String? title) {
    title = title?.trim();
    if (title != null && title.isEmpty) {
      title = null;
    }
    if (state != null) {
      _mapLayerListNotifier.reset();
    }
    state = GeoinkProject(
      null,
      title: title,
      description: "",
      lastModified: DateTime.now(),
    );
  }

  Future<void> handleSaveAs() async {
    if (state == null) {
      initNewUnsaved(null);
    }
    GeoinkProject project = state!;
    String exportResult = export();
    var savedPath = await saveGeoJSONFilePicker(
      dialogTitle: "Save Project",
      fileName: getDefaultFileNameWhenFileSaving(project),
      result: exportResult,
    );

    if (Platform.isAndroid) {
      savedPath = project.path!;
    }

    if (savedPath != null) {
      if (project.title == null) {
        Map decoded = jsonDecode(exportResult);
        String name = getNameFromPath(savedPath);
        decoded["properties"]["title"] = name;
        File(savedPath).writeAsString(jsonEncode(decoded));
        switchProject(project.copyWith(title: name, path: savedPath));
      } else {
        updatePath(savedPath);
      }
      PrefsState.addToRecentProjectsIfNotExists(state!);
    }
  }

  Future<bool> handleSave(BuildContext context) async {
    GeoinkProject? project = state;
    assert(project != null);
    String? path = project?.path;
    if (path == null) {
      if (!Platform.isAndroid) {
        await handleSaveAs();
        return false;
      } else {
        await saveToPathAuto();
      }
    } else {
      await saveToPathAuto();
    }
    return true;
  }
}
