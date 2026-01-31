import 'package:flutter/material.dart';
import 'package:mapify/core/services/tile_providers.dart';
import 'package:mapify/data/providers/map_tiles_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'flutter_map_children_provider.g.dart';

@riverpod
List<Widget> mapChildren(Ref ref) {
  return [
    openStreetMapTileLayer,
    ...ref
        .watch(tileEntriesProvider)
        .map((entries) => entries.toFlutterMapObject()),
  ];
}
