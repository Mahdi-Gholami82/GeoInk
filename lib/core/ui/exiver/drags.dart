import 'package:flutter/material.dart';
import 'package:geoink/core/ui/exiver/etc.dart';
import 'package:geoink/core/ui/exiver/exiver.dart';
import 'package:geoink/core/ui/exiver/nested_child.dart';

enum DragTargetType { header, child }

class DragIndicatorState {
  final int index;
  final bool isUpperHalf;

  const DragIndicatorState({required this.index, required this.isUpperHalf});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DragIndicatorState &&
        other.index == index &&
        other.isUpperHalf == isUpperHalf;
  }

  @override
  int get hashCode => Object.hash(index, isUpperHalf);

  @override
  String toString() {
    return "DragIndicatorState(index: $index, inUpperHalf: $isUpperHalf)";
  }
}

class NestedDragListener extends StatelessWidget {
  const NestedDragListener({
    super.key,
    required this.index,
    required this.child,
    required this.onDragDown,
  });
  final Widget child;
  final int index;
  final Function(BuildContext context, PointerDownEvent event) onDragDown;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        onDragDown(context, event);
      },
      child: child,
    );
  }
}

class NestedDragTarget extends StatefulWidget {
  const NestedDragTarget({
    super.key,
    required this.index,
    required this.child,
    required this.targetType,
  });
  final Widget child;
  final int index;
  final DragTargetType targetType;

  @override
  State<NestedDragTarget> createState() => NestedDragTargetState();
}

class NestedDragTargetState extends State<NestedDragTarget> {
  late TargetHolder _targetHolder;

  @override
  void initState() {
    super.initState();
    _targetHolder = switch (widget.targetType) {
      DragTargetType.header => ExiverListState.of(context),
      DragTargetType.child => NestedChildState.of(context),
    };
    _targetHolder.registerTarget(widget.index, this);
  }

  @override
  void dispose() {
    _targetHolder.unregisterTarget(widget.index, this);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant NestedDragTarget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _targetHolder.unregisterTarget(oldWidget.index, this);
      _targetHolder.registerTarget(widget.index, this);
    }
  }

  @override
  Widget build(BuildContext context) {
    var dragIndicator = _targetHolder.holderDragIndicator;
    Widget dragIndicatorwidget = Container(
      height: 5,
      color: Theme.of(context).colorScheme.primary,
    );

    return Stack(
      children: [
        widget.child,
        if (dragIndicator != null && widget.index == dragIndicator.index)
          dragIndicator.isUpperHalf
              ? Positioned.fill(bottom: null, child: dragIndicatorwidget)
              : Positioned.fill(top: null, child: dragIndicatorwidget),
      ],
    );
  }
}
