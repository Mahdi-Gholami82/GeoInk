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

  @override
  void initState() {
    super.initState();
    tempMapLayerList = ref.read(tileEntriesProvider);
    oldMapLayerList = tempMapLayerList.deepCopy();
    _focusNode.requestFocus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    selectedType = ModalRoute.of(context)!.settings.arguments as EntryType;
    currentLayer = tempMapLayerList.getDefaultLayerEntry(selectedType);
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
              selectedType = type;
              currentLayer = tempMapLayerList.getDefaultLayerEntry(type);
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

                            tempMapLayerList.addWithLayer(
                              MarkerEntry.withDefaults(
                                coordinate: point,
                              ),
                            );
                            break;
                          }
                        case EntryType.Polygon:
                          {
                            MapLayer layer = tempMapLayerList
                                .getDefaultLayerEntry(EntryType.Polygon);
                            if (finishedDrawing || layer.isEmpty) {
                              tempMapLayerList.addWithLayer(
                                PolygonEntry.withDefaults(
                                  coordinates: [point],
                                ),
                                layer: layer,
                              );
                              finishedDrawing = false;
                            } else {
                              (layer.items.last as PolygonEntry).coordinates
                                  .add(point);
                            }
                          }
                        case EntryType.Polyline:
                          {
                            MapLayer layer = tempMapLayerList
                                .getDefaultLayerEntry(EntryType.Polyline);
                            if (finishedDrawing || layer.isEmpty) {
                              tempMapLayerList.addWithLayer(
                                PolylineEntry.withDefaults(
                                  coordinates: [point],
                                ),
                                layer: layer,
                              );
                              finishedDrawing = false;
                            } else {
                              (layer.items.last as PolylineEntry).coordinates
                                  .add(point);
                            }
                          }
                        case EntryType.Circle:
                          {
                            MapLayer layer = tempMapLayerList
                                .getDefaultLayerEntry(EntryType.Circle);
                            if (finishedDrawing || layer.isEmpty) {
                              tempMapLayerList.addWithLayer(
                                CircleEntry.withDefaults(
                                  center: point,
                                  radius: 0,
                                ),
                                layer: layer,
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
                    // TODO: implement layer selector
                    // Container(
                    //   decoration: makeFloatingDecoration(context),
                    //   padding: EdgeInsets.symmetric(horizontal: 15),
                    //   child: Material(
                    //     child: ToolbarButton(
                    //       onTap: () {
                    //         showDialog(
                    //           context: context,
                    //           builder: (context) =>
                    //               LayerSelector(entryType: selectedType,),
                    //         );
                    //       },
                    //       spacing: 10,
                    //       children: [
                    //         Icon(Icons.layers_outlined),
                    //         Text(
                    //           "main",
                    //           style: TextStyle(fontWeight: FontWeight.w600),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
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
