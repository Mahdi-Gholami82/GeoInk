import 'package:flutter/material.dart';
import 'package:geoink/core/ui/exiver/drags.dart';
import 'package:geoink/core/ui/exiver/etc.dart';
import 'package:geoink/core/ui/exiver/exiver.dart';

class NestedChild extends StatefulWidget {
  NestedChild(
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

  copyWithIndex(int newIndex) => NestedChild(
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
      int movingIndex = switch (targetType) {
        DragTargetType.header => widget.index,
        DragTargetType.child => builderIndex,
      };
      EdgeInsetsGeometry getPadding() => switch (targetType) {
        DragTargetType.header => const EdgeInsetsGeometry.all(0),
        DragTargetType.child => ExiverList.of(context).childPadding,
      };

      return NestedDragTarget(
        index: movingIndex,
        targetType: targetType,
        child: NestedDragListener(
          index: builderIndex,
          child: Padding(padding: getPadding(), child: childWidget),
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
                        color: targetType == DragTargetType.child
                            ? _exiverListState.widget.childDraggingColor
                            : Colors.transparent,
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

                if (rect.contains(details.globalPosition)) {
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
                if (mousePositionY > _startDragY) {
                  int maxIndex =
                      switch (targetType) {
                        DragTargetType.header =>
                          _exiverListState.widget.children.length,
                        DragTargetType.child => widget.childCount,
                      } -
                      1;
                  var maxTarget = targets[maxIndex];
                  if (maxTarget == null) {
                    return;
                  }
                  final rect = getRenderRect(
                    maxTarget.context.findRenderObject() as RenderBox,
                  );
                  if (mousePositionY > rect.top) {
                    updateDragIndicatorMarkDirty(
                      DragIndicatorState(index: maxIndex, isUpperHalf: false),
                    );
                  }
                } else {
                  var minIndex = 0;
                  var minTarget = targets[minIndex];
                  if (minTarget == null) {
                    return;
                  }
                  final rect = getRenderRect(
                    minTarget.context.findRenderObject() as RenderBox,
                  );
                  if (mousePositionY < rect.bottom) {
                    updateDragIndicatorMarkDirty(
                      DragIndicatorState(index: minIndex, isUpperHalf: true),
                    );
                  }
                }
              }
            }

            void handleDragEnd(LongPressEndDetails details) {
              if (currentDragIndicator != null) {
                onReorder(
                  movingIndex,
                  currentDragIndicator!.index,
                  currentDragIndicator!.isUpperHalf,
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
    var _exiverList = ExiverList.of(context);
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
        onReorder: _exiverList.onReorder,
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
