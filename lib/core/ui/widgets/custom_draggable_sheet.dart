import 'package:flutter/material.dart';

class CustomDraggableSheet extends StatefulWidget {
  const CustomDraggableSheet({
    super.key,
    this.initialChildSize = 0.5,
    this.maxChildSize = 1.0,
    this.minChildSize = 0.15,
    this.pullDownOffset = 0.15,
    required this.builder,
  });

  final double initialChildSize;
  final double maxChildSize;
  final double minChildSize;
  final double pullDownOffset;
  final ScrollableWidgetBuilder builder;

  @override
  State<CustomDraggableSheet> createState() => _CustomDraggableSheetState();
}

class _CustomDraggableSheetState extends State<CustomDraggableSheet> {
  final double _dragSensitivity = 1;
  late double pixelsMoved;
  late double initDragPosition;
  bool get isGoingUp => pixelsMoved.isNegative;
  bool get isGoingDown => !isGoingUp;
  double get sheetNextPosition => controller.size + pixelsMoved;
  double get minMaxAverage =>
      (widget.initialChildSize + widget.maxChildSize) / 2;
  bool get needsMaxSizeForKeyboard =>
      MediaQuery.sizeOf(context).height /
          MediaQuery.of(context).viewInsets.bottom >
      0.10;
  late DraggableScrollableController controller;

  @override
  void initState() {
    super.initState();
    initDragPosition = widget.initialChildSize;
    pixelsMoved = 0;
    controller = DraggableScrollableController();
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: DraggableScrollableSheet(
        controller: controller,
        shouldCloseOnMinExtent: false,
        initialChildSize: needsMaxSizeForKeyboard
            ? widget.maxChildSize
            : widget.initialChildSize,
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
              if ((widget.initialChildSize - widget.pullDownOffset <
                          sheetNextPosition ||
                      isGoingDown) &&
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
              } else if (controller.size > minMaxAverage &&
                  controller.size < 1) {
                _animateSheetTo(widget.maxChildSize);
              } else {
                _animateSheetTo(initDragPosition);
              }
            },
            child: Material(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              child: widget.builder(context, scrollController),
            ),
          );
        },
      ),
    );
  }
}
