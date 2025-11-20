import 'package:flutter/material.dart';
import 'package:mapify/features/add_map_layer/coordinates_sheet.dart';

class DraggableCoordinatesSheet extends StatefulWidget {
  const DraggableCoordinatesSheet(this.title, {super.key});
  final String title;

  @override
  State<DraggableCoordinatesSheet> createState() =>
      _DraggableCoordinatesSheetState();
}

class _DraggableCoordinatesSheetState extends State<DraggableCoordinatesSheet> {
  final double _dragSensitivity = 1;
  double pixelsMoved = 0;
  double initDragPosition = 0.5;
  bool get isGoingUp => pixelsMoved.isNegative;
  bool get isGoingDown => !isGoingUp;
  double get sheetNextPosition => controller.size + pixelsMoved;

  DraggableScrollableController controller = DraggableScrollableController();

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
      initialChildSize: 0.5,
      minChildSize: 0.15,
      builder: (BuildContext context, ScrollController scrollController) {
        return GestureDetector(
          onVerticalDragStart: (details) {
            initDragPosition = controller.size;
          },
          onVerticalDragUpdate: (details) {
            pixelsMoved = -controller.pixelsToSize(
              details.delta.dy / _dragSensitivity,
            );
            if ((0.45 < sheetNextPosition || isGoingDown) &&
                (sheetNextPosition < 1 || isGoingUp)) {
              if (sheetNextPosition < 1 && sheetNextPosition > 0) {
                controller.jumpTo(sheetNextPosition);
              }
            }
          },
          onVerticalDragEnd: (details) {
            if (controller.size < 0.70 && controller.size > 0) {
              _animateSheetTo(0.5);
              return;
            }
            if (controller.size > 0.70 && controller.size < 1) {
              _animateSheetTo(1);
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
