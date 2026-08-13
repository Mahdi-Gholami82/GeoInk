import 'dart:async';

import 'package:flutter/material.dart';

enum AutoScrollPosition { upwards, downwards }

class CustomAutoScroller {
  CustomAutoScroller({
    required this.controller,
    this.duration = const Duration(milliseconds: 10),
    this.jumpValue = 10,
    this.autoScrollStartOffset = 150,
  });
  Completer? _completer;
  double? _multiplier;
  final Duration duration;
  final double jumpValue;
  final ScrollController controller;
  final double autoScrollStartOffset;

  Future<void> _startAutoDragProcess(Function job) async {
    _completer = Completer();
    while (!_completer!.isCompleted) {
      job();
      await Future.delayed(duration);
    }
    _completer = null;
  }

  void _stopAutoDragProcess() {
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete();
    }
  }

  void performAutoDrag(
    AutoScrollPosition position, {
    required double multiplier,
  }) {
    double clampToMinMaxScroll(double value) => value.clamp(
      controller.position.minScrollExtent,
      controller.position.maxScrollExtent,
    );
    _multiplier = multiplier;
    if (_completer == null || _completer!.isCompleted) {
      switch (position) {
        case AutoScrollPosition.upwards:
          _startAutoDragProcess(() {
            controller.jumpTo(
              clampToMinMaxScroll(
                controller.offset - (jumpValue * _multiplier!),
              ),
            );
          });
        case AutoScrollPosition.downwards:
          _startAutoDragProcess(() {
            controller.jumpTo(
              clampToMinMaxScroll(
                controller.offset + (jumpValue * _multiplier!),
              ),
            );
          });
      }
    }
  }

  void stopAutoDrag() {
    _stopAutoDragProcess();
    _multiplier = null;
  }

  bool autoDragIfNeccessary(RenderBox scrollable, double draggablePoint) {
    Rect scrollableRect =
        scrollable.localToGlobal(Offset.zero) & scrollable.size;
    double scrollableHeight = scrollableRect.size.height;
    double scrollableBottom = scrollableRect.bottom;
    double scrollableTop = scrollableRect.top;
    double newAutoScrollStartOffset =
        scrollableHeight > autoScrollStartOffset * 2
        ? autoScrollStartOffset
        : scrollableHeight / 2;

    double clampToMultiplier(double value) {
      return value.clamp(0.25, 2);
    }

    if (scrollableBottom - newAutoScrollStartOffset < draggablePoint &&
        draggablePoint < scrollableBottom) {
      performAutoDrag(
        AutoScrollPosition.downwards,
        multiplier: clampToMultiplier(
          (draggablePoint - (scrollableBottom - newAutoScrollStartOffset)) *
              2 /
              newAutoScrollStartOffset,
        ),
      );
      return true;
    }
    if (scrollableTop < draggablePoint &&
        draggablePoint < scrollableTop + newAutoScrollStartOffset) {
      performAutoDrag(
        AutoScrollPosition.upwards,
        multiplier: clampToMultiplier(
          1 - ((draggablePoint - scrollableTop) * 2 / newAutoScrollStartOffset),
        ),
      );
      return true;
    }
    stopAutoDrag();
    return false;
  }
}
