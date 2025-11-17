import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapify/misc/tile_providers.dart';
import 'package:mapify/providers/map_tiles_provider.dart';
import 'package:mapify/widgets/drawer.dart';
import 'package:mapify/widgets/floating_appbar.dart';
import 'package:mapify/widgets/speed_dial_fab.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  static const String route = "/";
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
          ...context.watch<TileEntriesProvider>().mapEntriesCollection.map(
            (entries) => entries.toFlutterMapObject(),
          ),
        ],
      ),
    );
  }
}
