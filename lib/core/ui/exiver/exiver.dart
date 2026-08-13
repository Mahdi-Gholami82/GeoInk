import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geoink/core/ui/exiver/custom_auto_scroller.dart';
import 'package:geoink/core/ui/exiver/drags.dart';
import 'package:geoink/core/ui/exiver/etc.dart';
import 'package:geoink/core/ui/exiver/nested_child.dart';

class ExiverList extends StatefulWidget {
  const ExiverList({
    super.key,
    required this.children,
    this.headerColor,
    this.headerLeading,
    this.headerShape,
    this.headerPadding,
    required this.onReorder,
    this.childPadding = const EdgeInsetsGeometry.symmetric(horizontal: 20),
    this.childDraggingColor,
  });
  final List<NestedChild> children;
  final Color? headerColor;
  final Widget? headerLeading;
  final ShapeBorder? headerShape;
  final EdgeInsetsGeometry childPadding;
  final Color? childDraggingColor;
  final EdgeInsetsGeometry? headerPadding;
  final NestedReorderCallback onReorder;

  static ExiverList? maybeOf(BuildContext context) {
    return context.findAncestorWidgetOfExactType<ExiverList>();
  }

  static ExiverList of(BuildContext context) {
    final ExiverList? result = maybeOf(context);
    assert(result != null, 'No ExiverList found in context');
    return result!;
  }

  @override
  State<ExiverList> createState() => ExiverListState();
}

class ExiverListState extends State<ExiverList> with TargetHolder {
  final ScrollController _scrollController = ScrollController();
  late final CustomAutoScroller autoScroller = CustomAutoScroller(
    controller: _scrollController,
  );
  LongPressGestureRecognizer? _recognizer;

  LongPressGestureRecognizer get recognizer {
    _recognizer = LongPressGestureRecognizer();
    return _recognizer!;
  }

  @override
  void initState() {
    super.initState();
  }

  static ExiverListState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<ExiverListState>();
  }

  static ExiverListState of(BuildContext context) {
    final ExiverListState? result = maybeOf(context);
    assert(result != null, 'No ExiverListState found in context');
    return result!;
  }

  void markTargetDirty() {
    if (holderDragIndicator != null) {
      targets[holderDragIndicator!.index]!.setState(() {});
    }
  }

  void updateDragIndicator(DragIndicatorState? value) {
    markTargetDirty();
    holderDragIndicator = value;
    markTargetDirty();
  }

  @override
  void dispose() {
    super.dispose();
    _recognizer?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: widget.children,
    );
  }
}
