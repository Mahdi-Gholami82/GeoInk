import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geoink/core/ui/theme_tools.dart';
import 'package:geoink/data/models/color_theme.dart';
import 'package:geoink/data/models/geoink_project.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsState {
  static late final SharedPreferences instance;
  static const recentProjectsCountLimit = 15;

  static ColorTheme get colorTheme {
    var result = instance.getString("colorTheme");
    return result != null ? ColorTheme.fromString(result) : ColorTheme.orange;
  }

  static set colorTheme(ColorTheme newTheme) {
    instance.setString("colorTheme", newTheme.name);
  }

  static Future<void> init() async {
    instance = await SharedPreferences.getInstance();
  }

  static ThemeMode get themeMode =>
      themeModeFromString(instance.getString("themeMode")) ?? ThemeMode.system;

  static set themeMode(ThemeMode value) {
    instance.setString("themeMode", value.name);
  }

  static Future<GeoinkProject?> loadSelectedProject() async {
    String? path = instance.getString("selectedProject");
    if (path != null) {
      var projectFile = File(path);
      if (await projectFile.exists()) {
        return GeoinkProject.fromFile(projectFile);
      }
    }
    return Future.value(null);
  }

  static void setSelectedProject(GeoinkProject project) {
    instance.setString("selectedProject", project.path!);
  }

  static Future<List<GeoinkProject>> loadRecentProjects() async {
    List<String>? recentProjectsPaths = instance.getStringList(
      "recentProjectsPaths",
    );
    if (recentProjectsPaths == null) {
      return [];
    }
    List<File> recentProjectsFiles = recentProjectsPaths
        .map((e) => File(e))
        .where((e) => e.existsSync())
        .toList();

    List<GeoinkProject> projects = (await Future.wait(
      recentProjectsFiles.map((e) => GeoinkProject.fromFile(e)),
    )).nonNulls.toList();
    if (recentProjectsFiles.length != projects.length) {
      setRecentProjects(projects);
    }
    return projects;
  }

  static void setRecentProjects(List<GeoinkProject> newProjects) {
    instance.setStringList(
      "recentProjectsPaths",
      newProjects.map((e) => e.path!).toList(),
    );
  }

  static void addToRecentProjectsIfNotExists(GeoinkProject project) {
    assert(project.path != null);
    List<String>? recentProjectsPaths = instance.getStringList(
      "recentProjectsPaths",
    );
    if (!(recentProjectsPaths?.contains(project.path) ?? false)) {
      recentProjectsPaths?.add(project.path!);
      if (recentProjectsPaths != null &&
          recentProjectsPaths.length > recentProjectsCountLimit) {
        recentProjectsPaths.removeRange(
          0,
          recentProjectsPaths.length - recentProjectsCountLimit,
        );
      }
      instance.setStringList(
        "recentProjectsPaths",
        recentProjectsPaths ?? [project.path!],
      );
    }
  }
}
