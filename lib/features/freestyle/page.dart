import 'package:geoink/core/services/tile_providers.dart';
import 'package:geoink/core/ui/floating_decoration.dart';
import 'package:geoink/core/ui/widgets/base_shortcuts.dart';
import 'package:geoink/core/utils/map_colors.dart';
import 'package:geoink/core/ui/show_color_picker.dart';
import 'package:geoink/data/models/action_manager.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:geoink/data/models/freestyle_arguments.dart';
import 'package:geoink/data/providers/history.dart';
import 'package:geoink/data/providers/map_layer_list.dart';
import 'package:geoink/data/providers/theme.dart';
import 'package:geoink/features/freestyle/widgets/floating_container.dart';
import 'package:geoink/features/freestyle/widgets/floating_tool_bar.dart';
import 'package:geoink/features/freestyle/widgets/free_style_buttons_bar.dart';
import 'package:geoink/features/freestyle/widgets/layer_selector.dart';
import 'package:geoink/features/freestyle/widgets/toolbar_button.dart';
import 'package:geoink/core/utils/color_tools.dart';
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
  bool _isInitialized = false;
  late MapLayerList mapLayerList;
  late MapLayerListNotifier mapLayerListNotifier;
  late EntryType selectedType;
  bool finishedDrawing = true;
  bool finishedMouseTrackDraw = true;
  bool addedTempPoint = false;
  var _focusNode = FocusNode();
  var _mousePosition = Offset.zero;
  late LatLng lastMouseClickPoint;
  late MapCamera homeMapCamera;
  MapLayer? get currentLayer => chosenLayers[selectedType];
  bool mouseEntered = false;
  set currentLayer(MapLayer? newLayer) {
    chosenLayers[selectedType] = newLayer;
  }

  late Map<EntryType, MapLayer?> chosenLayers;
  late Map<MapLayer, int> oldLayerLenghts;
  late HistoryNotifier historyNotifier;
  Map<EntryType, Color> chosenColors = Map.fromEntries(
    EntryType.values.map((e) => MapEntry(e, MapDefaultColors.fromType(e))),
  );
  Color get currentColor => chosenColors[selectedType]!;
  bool get canAddNewFlutterMapEntry =>
      finishedDrawing || currentLayer == null || currentLayer!.isEmpty;

  @override
  void initState() {
    super.initState();
    mapLayerList = ref.read(mapLayerListProvider);
    mapLayerListNotifier = ref.read(mapLayerListProvider.notifier);
    chosenLayers = Map.fromEntries(
      EntryType.values.map(
        (e) => MapEntry(e, mapLayerList.getDefaultLayerEntryOrNull(e)),
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
    if (!_isInitialized) {
      FreestyleArguments arguments =
          ModalRoute.of(context)!.settings.arguments as FreestyleArguments;
      selectedType = arguments.initSelectedType;
      homeMapCamera = arguments.mapCamera;
      _isInitialized = true;
    }
  }

  void beginDrawing() {
    historyNotifier.setRestorePoint();
    finishedDrawing = false;
  }

  void endDrawing() {
    finishedDrawing = true;
    finishedMouseTrackDraw = true;
    addedTempPoint = false;
  }

  void confirmDrawing() {
    if (addedTempPoint) {
      switch (currentLayer!.entryType) {
        case EntryType.polygon:
          (currentEntry as PolygonEntry).points.removeLast();
        case EntryType.polyline:
          (currentEntry as PolylineEntry).points.removeLast();
        case EntryType.circle:
        case EntryType.marker:
      }
    }
    historyNotifier.restoreFromPoints();
    endDrawing();
  }

  void cancelDrawing() {
    historyNotifier.restoreFromPoints();
    historyNotifier.undo();
    endDrawing();
  }

  void _addToLayerWithHistory(FlutterMapEntry entry) {
    bool createdLayer = false;

    MapLayer? layer = currentLayer;
    EntryType type = selectedType;
    historyNotifier.addAndDo(
      ManualDoable(
        executeBase: () {
          debugPrint(
            "Executing _addToLayerWithHistory with {\nentry : ${entry.name}, type : $type\n}",
          );
          // if no layer is selected or layer is invalid (deleted) default to main layer
          if (layer == null) {
            currentLayer = mapLayerList.createNewDefaultLayer(type);
            layer = currentLayer;
            createdLayer = true;
          } else if (layer!.isInvalid) {
            currentLayer = mapLayerList.getDefaultLayerEntryOrNull(type)!;
            layer = currentLayer;
          }
          layer!.addUnique(entry);
        },
        undoBase: () {
          debugPrint(
            "Undoing _addToLayerWithHistory with {\nentry : ${entry.name}, type : $type}",
          );
          // If undo has reached a point when the shape isnt being drawn anymore
          // Happens in the middle of drawing
          if (!finishedDrawing && !finishedMouseTrackDraw) {
            historyNotifier.setClearRedoAfterRedo();
            endDrawing();
          }
          if (createdLayer) {
            mapLayerList.items.remove(layer);
            if (currentLayer != null && currentLayer!.isMain) {
              currentLayer = null;
            }
            // Mark invalid to notify other entries on redo
            layer!.isInvalid = true;
            layer = null;
          } else {
            layer!.items.removeLast();
          }
        },
      ),
    );
  }

  FlutterMapEntry get currentEntry => currentLayer!.items.last;

  LatLng mousePositionToCoords(Offset mousePosition) =>
      homeMapCamera.screenOffsetToLatLng(mousePosition);

  void updateOnMousePosition(LatLng mouseCoords) {
    setState(() {
      if (!currentLayer!.isEmpty) {
        switch (currentLayer!.entryType) {
          case EntryType.marker:
            break;
          case EntryType.polygon:
            {
              var polygon = (currentEntry as PolygonEntry);
              if (finishedMouseTrackDraw) {
                polygon.points.add(mouseCoords);
                finishedMouseTrackDraw = false;
                addedTempPoint = true;
              } else {
                polygon.points.last = mouseCoords;
              }
            }
          case EntryType.polyline:
            {
              var polyline = (currentEntry as PolylineEntry);
              if (finishedMouseTrackDraw) {
                polyline.points.add(mouseCoords);
                finishedMouseTrackDraw = false;
                addedTempPoint = true;
              } else {
                polyline.points.last = mouseCoords;
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

    return MouseRegion(
      onEnter: (event) {
        mouseEntered = true;
      },
      onExit: (event) {
        mouseEntered = false;
      },
      onHover: (event) {
        _mousePosition = event.position;
        if (!finishedDrawing) {
          updateOnMousePosition(mousePositionToCoords(_mousePosition));
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
              int? start = oldLayerLenghts[layer];
              if (start == null) {
                mapLayerList.items.remove(layer);
                return;
              }
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
                  options: MapOptions(
                    initialZoom: homeMapCamera.zoom,
                    initialCenter: homeMapCamera.center,
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
                                MarkerEntry.withDefaults(
                                  color: currentColor,
                                  point: point,
                                ),
                              );
                              break;
                            }
                          case EntryType.polygon:
                            {
                              if (canAddNewFlutterMapEntry) {
                                _addToLayerWithHistory(
                                  PolygonEntry.withDefaults(
                                    borderColor: currentColor,
                                    points: [point],
                                  ),
                                );
                                beginDrawing();
                              } else {
                                var polygon =
                                    (currentLayer!.items.last as PolygonEntry);
                                historyNotifier.addAndDo(
                                  ManualDoable(
                                    executeBase: () {
                                      polygon.points.add(point);
                                    },
                                    undoBase: () {
                                      polygon.points.removeLast();
                                      if (mouseEntered) {
                                        updateOnMousePosition(
                                          mousePositionToCoords(_mousePosition),
                                        );
                                      }
                                    },
                                  ),
                                );
                              }
                            }
                          case EntryType.polyline:
                            {
                              if (canAddNewFlutterMapEntry) {
                                _addToLayerWithHistory(
                                  PolylineEntry.withDefaults(
                                    color: currentColor,
                                    points: [point],
                                  ),
                                );
                                beginDrawing();
                              } else {
                                var polyline =
                                    (currentLayer!.items.last as PolylineEntry);
                                historyNotifier.addAndDo(
                                  ManualDoable(
                                    executeBase: () {
                                      polyline.points.add(point);
                                    },
                                    undoBase: () {
                                      polyline.points.removeLast();
                                      if (mouseEntered) {
                                        updateOnMousePosition(
                                          mousePositionToCoords(_mousePosition),
                                        );
                                      }
                                    },
                                  ),
                                );
                              }
                            }
                          case EntryType.circle:
                            {
                              if (canAddNewFlutterMapEntry) {
                                _addToLayerWithHistory(
                                  CircleEntry.withDefaults(
                                    borderColor: currentColor,
                                    center: point,
                                    radius: 0,
                                  ),
                                );
                                beginDrawing();
                              } else {
                                updateOnMousePosition(point);
                                confirmDrawing();
                              }
                            }
                        }
                      });
                    },
                  ),
                  children: [
                    getOpenStreetMapTileLayer(
                      darkMode: ref
                          .watch(themeProvider.notifier)
                          .isDark(context),
                    ),
                    ...mapLayerList.getMapChildren(),
                  ],
                ),
                Align(
                  alignment: AlignmentGeometry.bottomStart,
                  child: Padding(
                    padding: const EdgeInsetsGeometry.only(
                      left: 20,
                      right: 20,
                      bottom: 20,
                    ),
                    child: SafeArea(
                      child: FittedBox(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 15,
                          children: [
                            Row(
                              spacing: 10,
                              children: [
                                Container(
                                  decoration: makeFloatingDecoration(context),
                                  padding: EdgeInsets.all(2),
                                  child: IconButton(
                                    color: currentColor.onColor(),
                                    style: IconButton.styleFrom(
                                      iconSize: 18,
                                      backgroundColor: currentColor,
                                      fixedSize: Size.square(40),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadiusGeometry.circular(15),
                                      ),
                                    ),
                                    onPressed: () {
                                      showSimpleColorPicker(
                                        context: context,
                                        initialColor: currentColor,
                                      ).then((chosenColor) {
                                        if (chosenColor != null) {
                                          chosenColors[selectedType] =
                                              chosenColor;
                                        }
                                      });
                                    },
                                    icon: Icon(Icons.colorize),
                                  ),
                                ),
                                FloatingContainer(
                                  child: Material(
                                    child: ToolbarButton(
                                      constraints: BoxConstraints.tightFor(
                                        height: 42,
                                      ),
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => LayerSelector(
                                            entryType: selectedType,
                                            initialLayer: currentLayer,
                                            onConfirm: (MapLayer? selection) {
                                              currentLayer = selection;
                                            },
                                          ),
                                        );
                                      },
                                      spacing: 10,
                                      children: [
                                        Icon(Icons.layers_outlined),
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                            minWidth: 0,
                                            maxWidth: 100,
                                          ),
                                          child: Text(
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            currentLayer?.name ??
                                                selectedType.mainLayerName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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
                    ),
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
