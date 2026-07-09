import 'package:flutter_map/flutter_map.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';

class FreestyleArguments {
  FreestyleArguments({
    required this.mapCamera,
    required this.initSelectedType,
  }) {}
  MapCamera mapCamera;
  EntryType initSelectedType;
}
