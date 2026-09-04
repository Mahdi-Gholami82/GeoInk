import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoink/core/ui/widgets/base_shortcuts.dart';
import 'package:geoink/core/ui/widgets/custom_map_attributions.dart';
import 'package:geoink/core/ui/widgets/responsive_drawer.dart';
import 'package:geoink/data/models/action_manager.dart';
import 'package:geoink/data/models/geoink_project.dart';
import 'package:geoink/data/models/prefs_state.dart';
import 'package:geoink/data/providers/history.dart';
import 'package:geoink/data/providers/map_camera.dart';
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
  ConsumerState<HomePage> createState() => HomePageState();
}

class HomePageState extends ConsumerState<HomePage> {
  late DoableHistory history;
  final MapController mapController = MapController();
  final ResponsiveDrawerController drawerController =
      ResponsiveDrawerController();
  late Future<GeoinkProject?> loadProjectFuture;
  late ProjectNotifier projectNotifier;
  late Function openRichAttributionWidget;
  late ThemeNotifier themeNotifier;
  late final customMapAttributionsController =
      CustomMapAttributionsController();
  bool showMapAttribution = true;
  bool shouldShowProjectsSheet = false;
  bool loading = false;

  static HomePageState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<HomePageState>();
  }

  static HomePageState of(BuildContext context) {
    final HomePageState? result = maybeOf(context);
    assert(result != null, 'No HomePageState found in context');
    return result!;
  }

  Future<GeoinkProject?> _loadRecentProject() async {
    var selectedProject = await PrefsState.loadSelectedProject();
    if (selectedProject == null) {
      showMapAttribution = false;
      shouldShowProjectsSheet = true;
    } else {
      ref.read(projectProvider.notifier).importFromProject(selectedProject);
    }
    return selectedProject;
  }

  @override
  void initState() {
    super.initState();
    history = ref.read(historyProvider);
    projectNotifier = ref.read(projectProvider.notifier);
    themeNotifier = ref.read(themeProvider.notifier);
    loading = true;
    loadProjectFuture = _loadRecentProject();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var freeStyleMapcamera = ref.read(mapCameraProvider);
    if (freeStyleMapcamera != null) {
      mapController.move(freeStyleMapcamera.center, freeStyleMapcamera.zoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    Iterable<Widget> mapChildren = ref
        .watch(mapLayerListProvider)
        .getMapChildren();
    ref.watch(historyProvider);
    ref.watch(projectProvider);
    ref.watch(themeProvider);
    ref.watch(mapCameraProvider);

    return BaseShortcuts(
      child: ResponsiveDrawer(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        controller: drawerController,
        drawer: MapDrawer(),
        body: FutureBuilder(
          future: loadProjectFuture,
          builder: (context, asyncSnapshot) {
            if (shouldShowProjectsSheet) {
              shouldShowProjectsSheet = false;
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                showProjectsSheet(context).then((_) async {
                  await Future.delayed(Duration(milliseconds: 200));
                  customMapAttributionsController.open(Duration(seconds: 3));
                });
              });
            }
            return Stack(
              children: [
                Scaffold(
                  extendBodyBehindAppBar: true,
                  resizeToAvoidBottomInset: false,
                  appBar: CustomAppBar(
                    mapController: mapController,
                    borderRadius: 16,
                    drawer: MapDrawer(),
                    onTapSettings: () async {
                      Navigator.of(context).pushNamed(SettingsPage.route);
                    },
                    onTapDrawer: (context) {
                      drawerController.toggle();
                    },
                  ),
                  floatingActionButton: AddMapElementFab(),
                  body: FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: LatLng(51.5, -0.09),
                      initialZoom: 5,
                    ),
                    children: [
                      getOpenStreetMapTileLayer(
                        darkMode: ref.read(themeProvider).isDark(context),
                      ),
                      ...mapChildren,
                      Align(
                        alignment: AlignmentGeometry.bottomLeft,
                        child: CustomMapAttributions(
                          initialyOpened: showMapAttribution,
                          controller: customMapAttributionsController,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: "© OSM Contributors",
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => launchUrl(
                                    Uri.parse(
                                      "https://www.openstreetmap.org/about/",
                                    ),
                                  ),
                              ),
                            ),
                            const Text(
                              "This attribution is the same throughout this app, except where otherwise specified",
                            ),
                          ],
                        ),
                      ),
                    ],
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
        ),
      ),
    );
  }
}
