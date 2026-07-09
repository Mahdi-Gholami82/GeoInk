import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoink/core/ui/widgets/base_shortcuts.dart';
import 'package:geoink/data/models/action_manager.dart';
import 'package:geoink/data/providers/history.dart';
import 'package:geoink/features/settings/page.dart';
import 'package:latlong2/latlong.dart';
import 'package:geoink/core/services/tile_providers.dart';
import 'package:geoink/data/providers/map_tiles.dart';
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
  late DoableHistory history;
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    history = ref.read(historyProvider);
  }

  @override
  Widget build(BuildContext context) {
    Iterable<Widget> mapChildren = ref
        .watch(tileEntriesProvider)
        .getMapChildren();
    ref.watch(historyProvider);

    return Scaffold(
      drawer: MapDrawer(),
      extendBodyBehindAppBar: true,
      appBar: FloatingAppBar(
        mapController: mapController,
        borderRadius: 16,
        drawer: MapDrawer(),
        onTapSettings: () {
          Navigator.of(context).pushNamed(SettingsPage.route);
        },
      ),
      floatingActionButton: AddMapElementFab(),
      body: BaseShortcuts(
        child: FlutterMap(
          mapController: mapController,
          options: const MapOptions(
            initialCenter: LatLng(51.5, -0.09),
            initialZoom: 5,
          ),
          children: [openStreetMapTileLayer, ...mapChildren],
        ),
      ),
    );
  }
}
