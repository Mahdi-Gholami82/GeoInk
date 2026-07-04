import 'package:geoink/data/models/action_manager.dart';

class TempDoable extends ManualDoable {
  TempDoable({required super.executeBase, required super.undoBase});
}

class MapHistory extends DoableHistory {
  MapHistory({super.redoStack, super.undoStack, int? undoRestorePoint, int? redoRestorePoint}) : _redoRestorePoint = redoRestorePoint, _undoRestorePoint = undoRestorePoint {}
  int? _undoRestorePoint;
  int? _redoRestorePoint;
  bool get canRestore => _undoRestorePoint != null && _redoRestorePoint != null;
  bool get undoReachedRestore => _undoRestorePoint == undoStack.length;
  bool clearUndoAfterUndo = false;

  @override
  bool undo() {
    var result = super.undo();
    if (clearUndoAfterUndo) {
      undoStack.clear();
      clearUndoAfterUndo = false;
      redoStack.removeLast();
    }
    return result;
  }

  void setRestorePoint() {
    _undoRestorePoint = undoStack.length;
    _redoRestorePoint = redoStack.length;
  }

  void restore() {
    assert(canRestore);
    try {
      undoStack.removeRange(_undoRestorePoint!, undoStack.length);
    } on RangeError {}
    try {
      redoStack.removeRange(_redoRestorePoint!, redoStack.length);
    } on RangeError {}
    _undoRestorePoint = null;
    _redoRestorePoint = null;
  }

  List<Doable> getDoableFromRestorePoint() {
    return undoStack.sublist(_undoRestorePoint!);
  }
  MapHistory copy() => MapHistory(redoStack: redoStack,undoStack: undoStack,undoRestorePoint: _undoRestorePoint,redoRestorePoint: _redoRestorePoint);
}