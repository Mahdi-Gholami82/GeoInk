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
    void Function(int fromIndex, int toIndex, bool isUpperHalf);

int getInsertInIndex(int fromIndex, int toIndex, bool isUpperHalf) {
  if (fromIndex < toIndex) {
    return isUpperHalf ? toIndex - 1 : toIndex;
  } else {
    return isUpperHalf ? toIndex : toIndex + 1;
  }
}
