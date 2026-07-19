import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoink/core/ui/widgets/base_shortcuts.dart';
import 'package:geoink/data/models/action_manager.dart';
import 'package:geoink/data/models/geoink_project.dart';
import 'package:geoink/data/models/prefs_state.dart';
import 'package:geoink/data/providers/history.dart';
import 'package:geoink/data/providers/projects.dart';
import 'package:geoink/data/providers/theme.dart';
import 'package:geoink/features/home/utils/show_projects_sheet.dart';
import 'package:geoink/features/settings/page.dart';
import 'package:latlong2/latlong.dart';
import 'package:geoink/core/services/tile_providers.dart';
import 'package:geoink/data/providers/map_layer_list.dart';
import 'package:geoink/features/add_map_layer/widgets/speed_dial_fab.dart';
import 'package:geoink/features/home/widgets/drawer.dart';
import 'package:geoink/features/appbar/custom_appbar.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends ConsumerStatefulWidget {
  static const String route = "/";
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late DoableHistory history;
  final MapController mapController = MapController();
  late Future<GeoinkProject?> loadProjectFuture;
  late ProjectNotifier projectNotifier;
  late Function openRichAttributionWidget;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    history = ref.read(historyProvider);
    projectNotifier = ref.read(projectProvider.notifier);
    loading = true;
    loadProjectFuture = PrefsState.loadSelectedProject().then((value) {
      if (value == null) {
        showProjectsSheet(context).then((_) async {
          await Future.delayed(Duration(milliseconds: 200));
          openRichAttributionWidget();
        });
      } else {
        ref.watch(projectProvider.notifier).update(value);
      }
      return value;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Iterable<Widget> mapChildren = ref
        .watch(mapLayerListProvider)
        .getMapChildren();
    ref.watch(historyProvider);
    ref.watch(projectProvider);

    return FutureBuilder(
      future: loadProjectFuture,
      builder: (context, asyncSnapshot) {
        return Stack(
          children: [
            Scaffold(
              drawer: MapDrawer(),
              extendBodyBehindAppBar: true,
              resizeToAvoidBottomInset: false,
              appBar: CustomAppBar(
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
                  children: [
                    getOpenStreetMapTileLayer(
                      darkMode: ref
                          .watch(themeProvider.notifier)
                          .isDark(context),
                    ),
                    ...mapChildren,
                    RichAttributionWidget(
                      openButton: (context, open) {
                        openRichAttributionWidget = open;
                        return IconButton(
                          onPressed: open,
                          tooltip: 'Attributions',
                          icon: Icon(
                            Icons.info_outlined,
                            color: Colors.black,
                            size: 24,
                          ),
                        );
                      },
                      alignment: AttributionAlignment.bottomLeft,
                      showFlutterMapAttribution: false,
                      attributions: [
                        TextSourceAttribution(
                          "OSM Contributors",
                          onTap: () => launchUrl(
                            Uri.parse("https://www.openstreetmap.org/about/"),
                          ),
                          prependCopyright: true,
                        ),

                        TextSourceAttribution(
                          "This attribution is the same throughout this app, except where otherwise specified",
                          prependCopyright: false,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (asyncSnapshot.connectionState != ConnectionState.done)
              Container(
                color: Colors.black.withAlpha(40),
                child: const Center(
                  child: SizedBox(
                    height: 40,
                    width: 40,
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
