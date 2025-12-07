import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapify/core/services/tile_providers.dart';
import 'package:mapify/data/providers/map_tiles_provider.dart';
import 'package:mapify/features/add_map_layer/widgets/speed_dial_fab.dart';
import 'package:mapify/features/home/widgets/drawer.dart';
import 'package:mapify/features/home/widgets/floating_appbar.dart';

class HomePage extends ConsumerStatefulWidget {
  static const String route = "/";
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  List<List> entriesBack = [];
  List<List> entries = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MapDrawer(),
      extendBodyBehindAppBar: true,
      appBar: FloatingAppBar(
        borderRadius: 16,
        drawer: MapDrawer(),
        onTapSettings: () {
          Navigator.of(context).pushNamed("/settings");
        },
        onSearch: (searchText) {
          setState(() {
            if (searchText.isNotEmpty) {
              entries = List.from(
                entries.where((element) {
                  return element.first.contains(searchText);
                }),
              );
            } else {
              entries = entriesBack;
            }
          });
        },
      ),
      floatingActionButton: AddMapElementFab(),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(51.5, -0.09),
          initialZoom: 5,
        ),
        children: [
          openStreetMapTileLayer,
          ...ref
              .watch(tileEntriesProvider)
              .map((entries) => entries.toFlutterMapObject()),
        ],
      ),
    );
  }
}
