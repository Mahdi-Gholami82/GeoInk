import 'package:geoink/core/services/tile_providers.dart';
import 'package:geoink/core/ui/floating_decoration.dart';
import 'package:geoink/core/ui/floating_shadow.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:geoink/data/providers/map_tiles_provider.dart';
import 'package:geoink/features/freestyle/widgets/floating_tool_bar.dart';
import 'package:geoink/features/freestyle/widgets/free_style_buttons_bar.dart';
import 'package:geoink/features/freestyle/widgets/layer_selector.dart';
import 'package:geoink/features/freestyle/widgets/toolbar_button.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_math/flutter_geo_math.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

void showColorPicker() {}

class FreeStylePage extends ConsumerStatefulWidget {
  static const String route = "/freestyle";
  @override
  ConsumerState<FreeStylePage> createState() => _FreeStylePageState();
}

class _FreeStylePageState extends ConsumerState<FreeStylePage> {
  late MapLayerList oldMapLayerList;
  late MapLayerList tempMapLayerList;
  late EntryType selectedType;
  bool finishedDrawing = true;
  bool finishedMouseTrackDraw = true;
  var _focusNode = FocusNode();
  var _mousePosition = Offset.zero;
  var mapController = MapController();
  late MapLayer currentLayer;
  late Map<EntryType, MapLayer> chosenLayers;

  @override
  void initState() {
    super.initState();
    tempMapLayerList = ref.read(tileEntriesProvider);
    oldMapLayerList = tempMapLayerList.deepCopy();
    chosenLayers = Map.fromEntries(
      EntryType.values.map(
        (e) => MapEntry(e, tempMapLayerList.getDefaultLayerEntry(e)),
      ),
    );
    _focusNode.requestFocus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    selectedType = ModalRoute.of(context)!.settings.arguments as EntryType;
    currentLayer = chosenLayers[selectedType]!;
  }

  void endDrawing() {
    finishedDrawing = true;
    finishedMouseTrackDraw = true;
  }

  void confirmDrawing() {
    switch (currentLayer.entryType) {
      case EntryType.Polygon:
        (currentEntry as PolygonEntry).coordinates.removeLast();
        break;
      case EntryType.Polyline:
        (currentEntry as PolylineEntry).coordinates.removeLast();
        break;
      case EntryType.Marker:
      case EntryType.Circle:
    }
    endDrawing();
  }

  void cancelDrawing() {
    currentLayer.items.remove(currentEntry);
    endDrawing();
  }

  FlutterMapEntry get currentEntry => currentLayer.items.last;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        _mousePosition = event.position;
        if (!finishedDrawing) {
          setState(() {
            LatLng mouseCoords = mapController.camera.screenOffsetToLatLng(
              _mousePosition,
            );
            if (!currentLayer.isEmpty) {
              switch (currentLayer.entryType) {
                case EntryType.Marker:
                  break;
                case EntryType.Polygon:
                  {
                    var polygon = (currentEntry as PolygonEntry);
                    if (finishedMouseTrackDraw) {
                      polygon.coordinates.add(mouseCoords);
                      finishedMouseTrackDraw = false;
                    } else {
                      polygon.coordinates.last = mouseCoords;
                    }
                  }
                case EntryType.Polyline:
                  {
                    var polyline = (currentLayer.items.last as PolylineEntry);
                    if (finishedMouseTrackDraw) {
                      polyline.coordinates.add(mouseCoords);
                      finishedMouseTrackDraw = false;
                    } else {
                      polyline.coordinates.last = mouseCoords;
                    }
                  }
                case EntryType.Circle:
                  {
                    var circle = (currentLayer.items.last as CircleEntry);
                    circle.radius = FlutterMapMath.distanceBetween(
                      circle.center.latitude,
                      circle.center.longitude,
                      mouseCoords.latitude,
                      mouseCoords.longitude,
                      "m",
                    );
                  }
              }
            }
          });
        }
      },
      child: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: (event) {
          if (!finishedDrawing) {
            setState(() {
              switch (event.logicalKey) {
                case LogicalKeyboardKey.escape:
                  cancelDrawing();
                  break;
                case LogicalKeyboardKey.enter:
                  confirmDrawing();
                  break;
              }
            });
          }
        },
        child: Scaffold(
          appBar: FreeStyleButtonsBar(
            initSelectedType: selectedType,
            onTypeSwitch: (EntryType type) {
              setState(() {
                selectedType = type;
                currentLayer = chosenLayers[type]!;
              });
            },
            onConfirm: () {},
            onCancel: () {
              ref
                  .read(tileEntriesProvider.notifier)
                  .updateState(oldMapLayerList);
            },
          ),
          extendBodyBehindAppBar: true,
          body: Stack(
            clipBehavior: Clip.none,
            children: [
              FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  interactionOptions: InteractionOptions(
                    flags:
                        InteractiveFlag.all &
                        ~InteractiveFlag.doubleTapZoom &
                        ~InteractiveFlag.doubleTapDragZoom,
                  ),
                  onTap: (tapPosition, point) {
                    setState(() {
                      switch (selectedType) {
                        case EntryType.Marker:
                          {
                            currentLayer.add(
                              MarkerEntry.withDefaults(coordinate: point),
                            );
                            break;
                          }
                        case EntryType.Polygon:
                          {
                            if (finishedDrawing || currentLayer.isEmpty) {
                              currentLayer.add(
                                PolygonEntry.withDefaults(coordinates: [point]),
                              );
                              finishedDrawing = false;
                            } else {
                              (currentLayer.items.last as PolygonEntry)
                                  .coordinates
                                  .add(point);
                            }
                          }
                        case EntryType.Polyline:
                          {
                            if (finishedDrawing || currentLayer.isEmpty) {
                              currentLayer.add(
                                PolylineEntry.withDefaults(
                                  coordinates: [point],
                                ),
                              );
                              finishedDrawing = false;
                            } else {
                              (currentLayer.items.last as PolylineEntry)
                                  .coordinates
                                  .add(point);
                            }
                          }
                        case EntryType.Circle:
                          {
                            if (finishedDrawing || currentLayer.isEmpty) {
                              currentLayer.add(
                                CircleEntry.withDefaults(
                                  center: point,
                                  radius: 0,
                                ),
                              );
                              finishedDrawing = false;
                            } else {
                              confirmDrawing();
                            }
                          }
                      }
                    });
                  },
                  initialCenter: LatLng(51.5, -0.09),
                  initialZoom: 5,
                ),
                children: [
                  openStreetMapTileLayer,
                  ...tempMapLayerList.getMapChildren(),
                ],
              ),
              Positioned(
                bottom: 20,
                left: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 15,
                  children: [
                    Container(
                      constraints: BoxConstraints(minHeight: 40),
                      decoration: makeFloatingDecoration(context),
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Material(
                        child: ToolbarButton(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => LayerSelector(
                                entryType: selectedType,
                                initialLayer: currentLayer,
                                onConfirm: (MapLayer selection) {
                                  chosenLayers[selectedType] = selection;
                                },
                              ),
                            );
                          },
                          spacing: 10,
                          children: [
                            Icon(Icons.layers_outlined),
                            Text(
                              currentLayer.name,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    FloatingToolBar(
                      onCancel: () {
                        setState(() {
                          cancelDrawing();
                        });
                      },
                      onOk: () {
                        setState(() {
                          confirmDrawing();
                        });
                      },
                      onRedo: () {},
                      onUndo: () {},
                      enableCancel: !finishedDrawing,
                      enableOk: !finishedDrawing,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
