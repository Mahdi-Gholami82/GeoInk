import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';

Future<Uint8List> mapToImageWaiter(
  FlutterMap map, {
  Size imageSize = const Size(1920, 1080),
  double ratio = 1.0,
  required Future<List> Function() tilesLoadedGenerator,
}) async {
  final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();
  final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
  final rootView = platformDispatcher.views.first;
  final RenderView renderView = RenderView(
    view: rootView,
    child: RenderPositionedBox(child: repaintBoundary),
    configuration: ViewConfiguration(
      devicePixelRatio: ratio,
      logicalConstraints: BoxConstraints(
        maxWidth: imageSize.width,
        maxHeight: imageSize.height,
      ),
    ),
  );
  final PipelineOwner pipelineOwner = PipelineOwner();
  final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());
  pipelineOwner.rootNode = renderView;
  renderView.prepareInitialFrame();

  final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
    container: repaintBoundary,
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(
        width: imageSize.width,
        height: imageSize.height,
        child: MediaQuery(
          data: MediaQueryData(size: imageSize),
          child: map,
        ),
      ),
    ),
  ).attachToRenderTree(buildOwner);

  void buildFrame() {
    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();
    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();
  }

  ui.Image? image;
  buildFrame();
  await tilesLoadedGenerator();
  buildFrame();
  image = await repaintBoundary.toImage();
  ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}
