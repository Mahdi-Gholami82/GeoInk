import 'package:flutter/material.dart';
import 'package:geoink/core/ui/exiver/drags.dart';
import 'package:geoink/core/ui/exiver/etc.dart';
import 'package:geoink/core/ui/exiver/exiver.dart';

class NestedChild extends StatefulWidget {
  const NestedChild(
    this.builder, {
    super.key,
    required this.headerBuilder,
    required this.childCount,
    required this.index,
    required this.onReorder,
  });
  final Widget Function(
    BuildContext context,
    void Function() doExpand,
    bool expanded,
  )
  headerBuilder;
  final Widget? Function(BuildContext context, int index) builder;
  final NestedReorderCallback onReorder;
  final int childCount;
  final int index;

  NestedChild copyWithIndex(int newIndex) => NestedChild(
    builder,
    key: key,
    headerBuilder: headerBuilder,
    childCount: childCount,
    index: newIndex,
    onReorder: onReorder,
  );

  @override
  State<NestedChild> createState() => NestedChildState();
}

class NestedChildState extends State<NestedChild> with TargetHolder {
  bool expanded = false;
  OverlayEntry? overlayEntry;
  double mousePositionY = 0;
  double _selectOffset = 0;
  double _startDragY = 0;
  bool isMoving = false;
  DragTargetType? draggingTargetType;
  late ExiverListState _exiverListState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _exiverListState = ExiverListState.of(context);
  }

  static NestedChildState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<NestedChildState>();
  }

  static NestedChildState of(BuildContext context) {
    NestedChildState? result = maybeOf(context);
    assert(result != null, "No NestedChildState found in context");
    return result!;
  }

  Rect getRenderRect(RenderBox box) {
    return box.localToGlobal(Offset.zero) & box.size;
  }

  void resetDrag() {
    setState(() {
      isMoving = false;
      overlayEntry?.remove();
      overlayEntry = null;
      updateDragIndicator(null);
      draggingTargetType = null;
      _exiverListState.autoScroller.stopAutoDrag();
    });
  }

  void updateDragIndicator(DragIndicatorState? value) {
    if (draggingTargetType != null) {
      switch (draggingTargetType!) {
        case DragTargetType.header:
          _exiverListState.updateDragIndicator(value);
        case DragTargetType.child:
          holderDragIndicator = value;
          break;
      }
    }
  }

  void updateDragIndicatorMarkDirty(DragIndicatorState value) {
    setState(() {
      updateDragIndicator(value);
    });
  }

  DragIndicatorState? get currentDragIndicator => switch (draggingTargetType!) {
    DragTargetType.header => _exiverListState.holderDragIndicator,
    DragTargetType.child => holderDragIndicator,
  };

  NullableIndexedWidgetBuilder _wrapWithDragWidgets(
    NullableIndexedWidgetBuilder builder, {
    required Map<int, NestedDragTargetState> targets,
    required NestedReorderCallback onReorder,
    required DragTargetType targetType,
  }) {
    return (context, builderIndex) {
      var childWidget = builder(context, builderIndex);
      if (childWidget == null) {
        return null;
      }
      final isHeader = targetType == DragTargetType.header;

      final reverse = isHeader ? _exiverListState.widget.reverse : false;

      final movingIndex = isHeader ? widget.index : builderIndex;

      final padding = isHeader
          ? EdgeInsets.zero
          : ExiverList.of(context).childPadding;

      final length = isHeader
          ? _exiverListState.widget.children.length
          : widget.childCount;

      return NestedDragTarget(
        index: movingIndex,
        targetType: targetType,
        child: NestedDragListener(
          index: builderIndex,
          child: Padding(padding: padding, child: childWidget),
          onDragDown: (context, event) {
            void handleDragStart(LongPressStartDetails details) {
              draggingTargetType = targetType;
              var renderObject = context.findRenderObject() as RenderBox;
              var widgetPosition = renderObject.localToGlobal(Offset.zero);
              _startDragY = details.globalPosition.dy;
              overlayEntry = OverlayEntry(
                builder: (context) {
                  if (!isMoving) {
                    mousePositionY = widgetPosition.dy;
                    _selectOffset = details.localPosition.dy;
                  }
                  return Positioned(
                    top: !isMoving
                        ? mousePositionY
                        : mousePositionY - _selectOffset,
                    child: Padding(
                      padding: const EdgeInsetsGeometry.only(left: 15),
                      child: Material(
                        color: isHeader
                            ? Colors.transparent
                            : _exiverListState.widget.childDraggingColor,
                        elevation: 10,
                        child: IntrinsicHeight(
                          child: SizedBox(
                            width: renderObject.size.width,
                            child: childWidget,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
              Overlay.of(context).insert(overlayEntry!);
            }

            void handleDragUpdate(LongPressMoveUpdateDetails details) {
              _exiverListState.autoScroller.autoDragIfNeccessary(
                (_exiverListState.context.findRenderObject() as RenderBox),
                mousePositionY,
              );
              isMoving = true;
              mousePositionY = details.globalPosition.dy;
              overlayEntry?.markNeedsBuild();
              for (final entry in targets.entries) {
                if (!entry.value.mounted) continue;
                final context = entry.value.context;
                final box = context.findRenderObject() as RenderBox;
                final rect = box.localToGlobal(Offset.zero) & box.size;

                if (rect.top <= mousePositionY &&
                    mousePositionY <= rect.bottom) {
                  final targetIndex = entry.key;
                  final double targetStart = rect.top;
                  final double targetEnd = rect.bottom;
                  final double targetMiddle = (targetStart + targetEnd) / 2;
                  bool isUpperHalf = false;
                  if (targetStart <= mousePositionY &&
                      mousePositionY <= targetMiddle) {
                    isUpperHalf = true;
                  }
                  DragIndicatorState newDragIndicator = DragIndicatorState(
                    index: targetIndex,
                    isUpperHalf: isUpperHalf,
                  );
                  if (newDragIndicator == currentDragIndicator) {
                    return;
                  }
                  updateDragIndicatorMarkDirty(newDragIndicator);
                  return;
                }
              }
              if (currentDragIndicator != null) {
                if ((mousePositionY > _startDragY) ^ reverse) {
                  int maxIndex = length - 1;
                  var maxTarget = targets[maxIndex];
                  if (maxTarget == null) {
                    return;
                  }
                  updateDragIndicatorMarkDirty(
                    DragIndicatorState(index: maxIndex, isUpperHalf: reverse),
                  );
                } else {
                  var minIndex = 0;
                  var minTarget = targets[minIndex];
                  if (minTarget == null) {
                    return;
                  }
                  updateDragIndicatorMarkDirty(
                    DragIndicatorState(index: minIndex, isUpperHalf: !reverse),
                  );
                }
              }
            }

            void handleDragEnd(LongPressEndDetails details) {
              if (currentDragIndicator != null) {
                var fromIndex = movingIndex;
                var toIndex = currentDragIndicator!.index;
                var isUpperHalf = currentDragIndicator!.isUpperHalf;
                int insertIndex = getInsertIndex(
                  fromIndex,
                  toIndex,
                  isUpperHalf,
                  reverse: false,
                );
                onReorder(
                  fromIndex,
                  toIndex,
                  insertIndex.clamp(0, length - 1),
                  isUpperHalf,
                );
              }
              resetDrag();
            }

            _exiverListState.recognizer
              ..onLongPressStart = handleDragStart
              ..onLongPressMoveUpdate = handleDragUpdate
              ..onLongPressEnd = handleDragEnd
              ..onLongPressCancel = resetDrag
              ..addPointer(event);
          },
        ),
      );
    };
  }

  Widget? builder(BuildContext context, int index) {
    var exiverList = ExiverList.of(context);
    var localIndex = index - 1;
    if (localIndex == -1) {
      return _wrapWithDragWidgets(
        (BuildContext context, int index) {
          return widget.headerBuilder(context, () {
            setState(() {
              expanded = !expanded;
            });
          }, expanded);
        },
        targets: _exiverListState.targets,
        onReorder: exiverList.onReorder,
        targetType: DragTargetType.header,
      )(context, localIndex);
    } else if (!expanded) {
      return null;
    }
    return _wrapWithDragWidgets(
      widget.builder,
      targets: targets,
      onReorder: widget.onReorder,
      targetType: DragTargetType.child,
    )(context, localIndex);
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        builder,
        childCount: widget.childCount + 1,
      ),
    );
  }
}

class NestedSliverChildDelegate extends SliverChildBuilderDelegate {
  NestedSliverChildDelegate(
    super.builder, {
    required this.headerBuilder,
    super.addAutomaticKeepAlives,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
    required int childCount,
    super.findChildIndexCallback,
    super.semanticIndexCallback,
    super.semanticIndexOffset,
    this.expanded = false,
  }) : super(childCount: childCount);
  bool expanded = false;
  Widget Function() headerBuilder;
}
