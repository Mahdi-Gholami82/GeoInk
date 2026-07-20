import 'dart:convert';
import 'dart:io';

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

  MapLayerListNotifier get mapLayerListNotifier =>
      ref.read(mapLayerListProvider.notifier);

  void update(GeoinkProject project) {
    PrefsState.setSelectedProject(project);
    state = project;
  }

  void updatePath(String? newPath) {
    state = state?.copyWith(path: newPath);
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
    var mapLayerListNotifier = ref.read(mapLayerListProvider.notifier);
    mapLayerListNotifier.reset();
    List<LayerEntryMap> layerEntryMaps = mapLayerListNotifier
        .fromGeoJSONFeatureCollection(featureCollection);
    ref
        .read(historyProvider.notifier)
        .actionListAddAllToAllLayer(layerEntryMaps);
  }

  Future<void> importProjectFromFile(File projectFile) async {
    importFromProject(await GeoinkProject.fromFile(projectFile));
  }

  void importFromProject(GeoinkProject project) {
    if (!File(project.path!).existsSync()) {
      throw PathNotFoundException;
    }
    mapLayerListNotifier.reset();
    import(File(project.path!).readAsStringSync());
    update(project);
  }

  Future<void> saveToPath() async {
    assert(state != null && state!.path != null && state!.title != null);
    File file = File(state!.path!);
    if (!await file.exists()) {
      file.create(recursive: true);
    }
    await file.writeAsString(export());
  }

  void initNewUnsaved(String? title) {
    if (title != null && title.trim().isEmpty) {
      title = null;
    }
    if (state != null) {
      mapLayerListNotifier.reset();
    }
    state = GeoinkProject(
      null,
      title: title,
      description: "",
      lastModified: DateTime.now(),
    );
  }
}
