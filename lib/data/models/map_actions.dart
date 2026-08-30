import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:geoink/data/models/action_manager.dart';

typedef RestorePoint = ({int undoRestorePoint, int redoRestorePoint});

class TempDoable extends ManualDoable {
  TempDoable({required super.executeBase, required super.undoBase});
}

class MapHistory extends DoableHistory {
  MapHistory({
    super.redoStack,
    super.undoStack,
    List<RestorePoint>? restorePoints,
  }) : _restorePoints = restorePoints ?? [] {}
  List<RestorePoint> _restorePoints;
  bool get canRestore => _restorePoints.isNotEmpty;
  bool clearRedoAfterUndo = false;

  // will be changeable in setting
  final int historyLimit = 50;
  bool get needsToRemoveOnAdd {
    return (_restorePoints.isEmpty
            ? undoStack.length
            : _restorePoints.map((e) => e.undoRestorePoint).min) >
        historyLimit;
  }

  @override
  bool undo() {
    var result = super.undo();
    if (clearRedoAfterUndo) {
      redoStack.clear();
      clearRedoAfterUndo = false;
    }
    return result;
  }

  @override
  void add(Doable action) {
    super.add(action);
    if (needsToRemoveOnAdd) {
      undoStack.removeAt(0);
      debugPrint("Removed the oldest undoable for limit");
    }
  }

  void setRestorePoint() {
    _restorePoints.add((
      undoRestorePoint: undoStack.length,
      redoRestorePoint: redoStack.length,
    ));
  }

  void restore() {
    assert(canRestore);
    var points = _restorePoints.removeLast();
    undoStack.removeRange(points.undoRestorePoint, undoStack.length);
    redoStack.removeRange(points.redoRestorePoint, redoStack.length);
    debugPrint("restored\n_restorePoints lenght : ${_restorePoints.length}");
  }

  List<Doable> getDoableFromRestorePoint() {
    return undoStack.sublist(_restorePoints.last.undoRestorePoint);
  }

  MapHistory copy() => MapHistory(
    redoStack: redoStack,
    undoStack: undoStack,
    restorePoints: _restorePoints,
  );
}
