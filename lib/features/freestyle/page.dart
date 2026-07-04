import 'package:geoink/core/services/tile_providers.dart';
import 'package:geoink/core/ui/floating_decoration.dart';
import 'package:geoink/core/ui/widgets/base_shortcuts.dart';
import 'package:geoink/data/models/action_manager.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:geoink/data/providers/history.dart';
import 'package:geoink/data/providers/map_tiles.dart';
import 'package:geoink/features/freestyle/widgets/floating_tool_bar.dart';
import 'package:geoink/features/freestyle/widgets/free_style_buttons_bar.dart';
import 'package:geoink/features/freestyle/widgets/layer_selector.dart';
import 'package:geoink/core/ui/widgets/toolbar_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_math/flutter_geo_math.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class FreeStylePage extends ConsumerStatefulWidget {
  static const String route = "/freestyle";
  @override
  ConsumerState<FreeStylePage> createState() => _FreeStylePageState();
}

class _FreeStylePageState extends ConsumerState<FreeStylePage> {
  late MapLayerList mapLayerList;
  late TileEntriesNotifier mapLayerListNotifier;
  late EntryType selectedType;
  bool finishedDrawing = true;
  bool finishedMouseTrackDraw = true;
  var _focusNode = FocusNode();
  var _mousePosition = Offset.zero;
  late LatLng lastMouseClickPoint;
  var mapController = MapController();
  MapLayer get currentLayer => chosenLayers[selectedType]!;
  late Map<EntryType, MapLayer> chosenLayers;
  late Map<MapLayer, int> oldLayerLenghts;
  late HistoryNotifier historyNotifier;

  @override
  void initState() {
    super.initState();
    mapLayerList = ref.read(tileEntriesProvider);
    mapLayerListNotifier = ref.read(tileEntriesProvider.notifier);
    chosenLayers = Map.fromEntries(
      EntryType.values.map(
        (e) => MapEntry(e, mapLayerList.getDefaultLayerEntry(e)),
      ),
    );
    oldLayerLenghts = Map.fromEntries(
      mapLayerList.items.map((e) => MapEntry(e, e.length)),
    );
    historyNotifier = ref.read(historyProvider.notifier);
    historyNotifier.setRestorePoint();
    _focusNode.requestFocus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    selectedType = ModalRoute.of(context)!.settings.arguments as EntryType;
  }

  void beginDrawing() {
    historyNotifier.setRestorePoint();
    finishedDrawing = false;
  }

  void endDrawing() {
    finishedDrawing = true;
    finishedMouseTrackDraw = true;
  }

  void confirmDrawing() {
    switch (currentLayer.entryType) {
      case EntryType.polygon:
        (currentEntry as PolygonEntry).coordinates.removeLast();
      case EntryType.polyline:
        (currentEntry as PolylineEntry).coordinates.removeLast();
      case EntryType.circle:
      case EntryType.marker:
    }
    historyNotifier.restoreFromPoints();
    endDrawing();
  }

  void cancelDrawing() {
    currentLayer.items.removeLast();
    endDrawing();
  }

  void _addToLayerWithHistory(FlutterMapEntry entry) {
    var layer = currentLayer;
    historyNotifier.addAndDo(
      ManualDoable(
        executeBase: () {
          layer.addUnique(entry);
        },
        undoBase: () {
          // If undo has reached a point when the shape isnt being drawn anymore
          // Happens in the middle of drawing
          if (!finishedDrawing && !finishedMouseTrackDraw) {
            historyNotifier.setClearRedoAfterRedo();
            endDrawing();
          }
          layer.items.removeLast();
        },
      ),
    );
  }

  FlutterMapEntry get currentEntry => currentLayer.items.last;



  LatLng mousePositionToCoords(Offset mousePosition) => mapController.camera.screenOffsetToLatLng(
        mousePosition,
      );

  void updateHover(Offset mousePosition) {
    var mouseCoords = mousePositionToCoords(mousePosition);
    setState(() {
      if (!currentLayer.isEmpty) {
        switch (currentLayer.entryType) {
          case EntryType.marker:
            break;
          case EntryType.polygon:
            {
              var polygon = (currentEntry as PolygonEntry);
              if (finishedMouseTrackDraw) {
                polygon.coordinates.add(mouseCoords);
                finishedMouseTrackDraw = false;
              } else {
                polygon.coordinates.last = mouseCoords;
              }
            }
          case EntryType.polyline:
            {
              var polyline = (currentEntry as PolylineEntry);
              if (finishedMouseTrackDraw) {
                polyline.coordinates.add(mouseCoords);
                finishedMouseTrackDraw = false;
              } else {
                polyline.coordinates.last = mouseCoords;
              }
            }
          case EntryType.circle:
            {
              var circle = (currentEntry as CircleEntry);
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

  @override
  Widget build(BuildContext context) {
    ref.watch(historyProvider);

    return Listener(
      onPointerHover: (event) {
        _mousePosition = event.position;
        if (!finishedDrawing) {
          updateHover(_mousePosition);
        }
      },
      child: Scaffold(
        appBar: FreeStyleButtonsBar(
          initSelectedType: selectedType,
          onTypeSwitch: (EntryType type) {
            setState(() {
              selectedType = type;
            });
          },
          onConfirm: () {
            historyNotifier.applyFromPoints();
          },
          onCancel: () {
            for (var layer in mapLayerList.items) {
              int start = oldLayerLenghts[layer]!;
              int end = layer.items.length;
              layer.items.removeRange(start, end);
            }
            historyNotifier.restoreFromPoints();
          },
        ),
        extendBodyBehindAppBar: true,
        body: BaseShortcuts(
          freeStyleShortcuts: true,
          child: Actions(
            actions: {
              CancelDrawIntent: CallbackAction(
                onInvoke: (_) {
                  setState(() {
                    if (!finishedDrawing) cancelDrawing();
                  });
                  return true;
                },
              ),
              ConfirmDrawIntent: CallbackAction(
                onInvoke: (_) {
                  setState(() {
                    if (!finishedDrawing) confirmDrawing();
                  });
                  return true;
                },
              ),
            },
            child: Stack(
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
                      lastMouseClickPoint = point;
                      setState(() {
                        switch (selectedType) {
                          case EntryType.marker:
                            {
                              _addToLayerWithHistory(
                                MarkerEntry.withDefaults(coordinate: point),
                              );
                              break;
                            }
                          case EntryType.polygon:
                            {
                              if (finishedDrawing || currentLayer.isEmpty) {
                                _addToLayerWithHistory(
                                  PolygonEntry.withDefaults(
                                    coordinates: [point],
                                  ),
                                );
                                beginDrawing();
                              } else {
                                var polygon =
                                    (currentLayer.items.last as PolygonEntry);
                                historyNotifier.addAndDo(
                                  ManualDoable(
                                    executeBase: () {
                                      polygon.coordinates.add(point);
                                    },
                                    undoBase: () {
                                      polygon.coordinates.removeLast();
                                      updateHover(_mousePosition);
                                    },
                                  ),
                                );
                              }
                            }
                          case EntryType.polyline:
                            {
                              if (finishedDrawing || currentLayer.isEmpty) {
                                _addToLayerWithHistory(
                                  PolylineEntry.withDefaults(
                                    coordinates: [point],
                                  ),
                                );
                                beginDrawing();
                              } else {
                                var polyline = (currentLayer.items.last as PolylineEntry);
                                historyNotifier.addAndDo(
                                  ManualDoable(
                                    executeBase: () {
                                      polyline.coordinates.add(point);
                                    },
                                    undoBase: () {
                                      polyline.coordinates.removeLast();
                                      updateHover(_mousePosition);
                                    },
                                  ),
                                );
                              }
                            }
                          case EntryType.circle:
                            {
                              if (finishedDrawing || currentLayer.isEmpty) {
                                _addToLayerWithHistory(
                                  CircleEntry.withDefaults(
                                    center: point,
                                    radius: 0,
                                  ),
                                );
                                beginDrawing();
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
                    ...mapLayerList.getMapChildren(),
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
                              FittedBox(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(minWidth: 0,maxWidth: 100),
                                  child: Text(
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    currentLayer.name,
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
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
                        onRedo: () {
                          historyNotifier.redo();
                        },
                        onUndo: () {
                          historyNotifier.undo();
                        },
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
      ),
    );
  }
}
