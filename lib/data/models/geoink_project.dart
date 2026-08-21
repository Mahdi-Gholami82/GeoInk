import 'dart:convert';
import 'dart:io';

import 'package:geoink/core/utils/process_file_path.dart';

// Future<List<GeoinkProject>> projectsFromFilesUnique(List<File> files) async {
//   List<GeoinkProject> projects = [];
//   for (var file in files) {
//     var decoded = jsonDecode(file.readAsStringSync());
//     var properties = decoded["properties"];
//     DateTime lastModified = await file.lastModified();
//     if (properties == null) {
//       GeoinkProject.empty(lastModified);
//     }
//     projects.add(
//       GeoinkProject(
//         file.path,
//         title: properties["title"] ?? "",
//         description: properties["description"] ?? "",
//         lastModified: lastModified,
//       ),
//     );
//   }

//   Map<String, int> preNamesMax = {};
//   List<String> namesList = projects.map((e) => e.title).toList();
//   for (var project in projects) {
//     if (project.title.trim().isEmpty) {
//       project.title = "Untitiled";
//       int? preMax = preNamesMax[project.title];
//       int maxNum = 0;
//       String title = project.title;
//       if (preMax == null) {
//         maxNum = getUniqueMaxNum(title, namesList);
//       } else {
//         maxNum = preMax;
//       }
//       maxNum++;
//       preNamesMax[title] = maxNum;
//       title = "${title} (${maxNum})";
//       project.title = title;
//     }
//   }
//   return projects;
// }

String getDefaultFileNameWhenFileSaving(GeoinkProject? project) {
  String fileName = "Untitled.geojson";
  if (project != null) {
    if (project.path != null) {
      fileName = getFileNameFromPath(project.path!);
    } else {
      if (project.title != null) {
        fileName = project.title! + ".geojson";
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
  }) : this.description = description ?? "" {}

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
  int get hashCode => Object.hash(this.title, this.path);

  @override
  bool operator ==(Object other) {
    if (other case GeoinkProject otherProject) {
      return this.title == otherProject.title && this.path == otherProject.path;
    }
    return false;
  }

  static Future<GeoinkProject> fromFile(File file) async {
    var decoded = jsonDecode(file.readAsStringSync());
    if (!(decoded is Map)) {
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
