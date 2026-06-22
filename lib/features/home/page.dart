import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:geoink/core/services/tile_providers.dart';
import 'package:geoink/data/providers/map_tiles_provider.dart';
import 'package:geoink/features/add_map_layer/widgets/speed_dial_fab.dart';
import 'package:geoink/features/home/widgets/drawer.dart';
import 'package:geoink/features/appbar/floating_appbar.dart';

class HomePage extends ConsumerStatefulWidget {
  static const String route = "/";
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    Iterable<Widget> mapChildren = ref
        .watch(tileEntriesProvider).getMapChildren();

    return Scaffold(
      drawer: MapDrawer(),
      extendBodyBehindAppBar: true,
      appBar: FloatingAppBar(
        borderRadius: 16,
        drawer: MapDrawer(),
        onTapSettings: () {
          Navigator.of(context).pushNamed("/settings");
        },
      ),
      floatingActionButton: AddMapElementFab(),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(51.5, -0.09),
          initialZoom: 5,
        ),
        children: [openStreetMapTileLayer, ...mapChildren],
      ),
    );
  }
}
