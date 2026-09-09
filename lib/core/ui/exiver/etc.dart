import 'package:geoink/core/ui/exiver/drags.dart';

mixin TargetHolder {
  final Map<int, NestedDragTargetState> targets = {};
  DragIndicatorState? holderDragIndicator;

  void registerTarget(int index, NestedDragTargetState target) {
    targets[index] = target;
  }

  void unregisterTarget(int oldIndex, NestedDragTargetState target) {
    final NestedDragTargetState? currentTarget = targets[oldIndex];
    if (currentTarget == target) {
      targets.remove(oldIndex);
    }
  }
}

typedef NestedReorderCallback =
    void Function(
      int fromIndex,
      int toIndex,
      int insertIndex,
      bool isUpperHalf,
    );

int getInsertIndex(
  int fromIndex,
  int toIndex,
  bool isUpperHalf, {
  bool reverse = false,
}) {
  if (reverse) {
    isUpperHalf = !isUpperHalf;
  }
  if (fromIndex == toIndex) {
    return fromIndex;
  } else if (fromIndex < toIndex) {
    return isUpperHalf ? toIndex - 1 : toIndex;
  } else {
    return isUpperHalf ? toIndex : toIndex + 1;
  }
}
