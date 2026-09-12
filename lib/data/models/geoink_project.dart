import 'dart:convert';
import 'dart:io';

import 'package:geoink/core/utils/process_file_path.dart';

String getDefaultFileNameWhenFileSaving(GeoinkProject? project) {
  String fileName = "Untitled.geojson";
  if (project != null) {
    if (project.path != null) {
      fileName = getFileNameFromPath(project.path!);
    } else {
      if (project.title != null) {
        fileName = "${project.title!}.geojson";
      }
    }
  }
  return fileName;
}

class GeoinkProject {
  GeoinkProject(
    this.path, {
    required this.title,
    String? description,
    required this.lastModified,
  }) : description = description ?? "";

  GeoinkProject.empty(DateTime lastModified)
    : this("", title: "", description: "", lastModified: lastModified);

  GeoinkProject copyWith({
    String? path,
    String? title,
    String? description,
    DateTime? lastModified,
  }) {
    return GeoinkProject(
      path ?? this.path,
      title: title ?? this.title,
      description: description ?? this.description,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  @override
  int get hashCode => Object.hash(title, path);

  @override
  bool operator ==(Object other) {
    if (other case GeoinkProject otherProject) {
      return title == otherProject.title && path == otherProject.path;
    }
    return false;
  }

  static Future<GeoinkProject> fromFile(File file) async {
    var decoded = jsonDecode(file.readAsStringSync());
    if (decoded is! Map) {
      throw FormatException;
    }
    var properties = decoded["properties"];
    DateTime lastModified = await file.lastModified();
    if (properties == null) {
      return GeoinkProject.empty(lastModified);
    }
    String? title = properties["title"];
    return GeoinkProject(
      file.path,
      title: title == null || title.trim().isEmpty
          ? getNameFromPath(file.path)
          : title,
      description: properties["description"] ?? "",
      lastModified: lastModified,
    );
  }

  String? title;
  String? description;
  DateTime lastModified;
  String? path;
}
