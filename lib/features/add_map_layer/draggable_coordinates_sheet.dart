import 'package:flutter/material.dart';
import 'package:mapify/features/add_map_layer/coordinates_sheet.dart';

class DraggableCoordinatesSheet extends StatefulWidget {
  const DraggableCoordinatesSheet(
    this.title, {
    super.key,
    this.initialChildSize = 0.5,
    this.maxChildSize = 1.0,
    this.minChildSize = 0.15,
  });
  final String title;

  final double initialChildSize;
  final double maxChildSize;
  final double minChildSize;

  @override
  State<DraggableCoordinatesSheet> createState() =>
      _DraggableCoordinatesSheetState();
}

class _DraggableCoordinatesSheetState extends State<DraggableCoordinatesSheet> {
  final double _dragSensitivity = 1;
  late double pixelsMoved;
  late double initDragPosition;
  bool get isGoingUp => pixelsMoved.isNegative;
  bool get isGoingDown => !isGoingUp;
  double get sheetNextPosition => controller.size + pixelsMoved;
  double get minMaxAverage =>
      (widget.initialChildSize + widget.maxChildSize) / 2;

  DraggableScrollableController controller = DraggableScrollableController();

  @override
  void initState() {
    initDragPosition = widget.initialChildSize;
    pixelsMoved = 0;
    super.initState();
  }

  void _animateSheetTo(double size) {
    controller.animateTo(
      size,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: controller,
      shouldCloseOnMinExtent: false,
      initialChildSize: widget.initialChildSize,
      minChildSize: widget.minChildSize,
      builder: (BuildContext context, ScrollController scrollController) {
        return GestureDetector(
          onVerticalDragStart: (details) {
            initDragPosition = controller.size;
          },
          onVerticalDragUpdate: (details) {
            pixelsMoved = -controller.pixelsToSize(
              details.delta.dy / _dragSensitivity,
            );
            if ((widget.initialChildSize < sheetNextPosition || isGoingDown) &&
                (sheetNextPosition < widget.maxChildSize || isGoingUp)) {
              if (sheetNextPosition < widget.maxChildSize &&
                  sheetNextPosition > 0) {
                controller.jumpTo(sheetNextPosition);
              }
            }
          },
          onVerticalDragEnd: (details) {
            if (controller.size < minMaxAverage && controller.size > 0) {
              _animateSheetTo(widget.initialChildSize);
              return;
            }
            if (controller.size > minMaxAverage && controller.size < 1) {
              _animateSheetTo(widget.maxChildSize);
              return;
            }
            _animateSheetTo(initDragPosition);
          },
          child: Material(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            child: CoordinatesSheet(
              scrollController: scrollController,
              title: widget.title,
            ),
          ),
        );
      },
    );
  }
}
