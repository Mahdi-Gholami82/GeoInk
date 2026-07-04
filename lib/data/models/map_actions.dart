import 'package:geoink/data/models/action_manager.dart';

class TempDoable extends ManualDoable {
  TempDoable({required super.executeBase, required super.undoBase});
}

class MapHistory extends DoableHistory {
  MapHistory({
    super.redoStack,
    super.undoStack,
    List<int>? undoRestorePoint,
    List<int>? redoRestorePoint,
  }) : _redoRestorePoints = redoRestorePoint ?? [],
       _undoRestorePoints = undoRestorePoint ?? [] {}
  List<int> _undoRestorePoints;
  List<int> _redoRestorePoints;
  bool get canRestore => _undoRestorePoints.isNotEmpty && _redoRestorePoints.isNotEmpty && _undoRestorePoints.length == _redoRestorePoints.length;
  bool get undoReachedRestore => _undoRestorePoints == undoStack.length;
  bool clearRedoAfterUndo = false;

  @override
  bool undo() {
    var result = super.undo();
    if (clearRedoAfterUndo) {
      redoStack.clear();
      clearRedoAfterUndo = false;
    }
    return result;
  }

  void setRestorePoint() {
    _undoRestorePoints.add(undoStack.length);
    _redoRestorePoints.add(redoStack.length);
  }

  void restore() {
    assert(canRestore);
    undoStack.removeRange(_undoRestorePoints.removeLast(), undoStack.length);
    redoStack.removeRange(_redoRestorePoints.removeLast(), redoStack.length);
  }

  List<Doable> getDoableFromRestorePoint() {
    return undoStack.sublist(_undoRestorePoints.last);
  }
  MapHistory copy() => MapHistory(redoStack: redoStack,undoStack: undoStack,undoRestorePoint: _undoRestorePoints,redoRestorePoint: _redoRestorePoints);
}