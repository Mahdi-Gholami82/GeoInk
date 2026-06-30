import 'package:geoink/data/models/action_manager.dart';

class MapHistory extends DoableHistory {
  MapHistory({super.redoStack, super.undoStack, this.undoRestorePoint, this.redoRestorePoint}) {}
  int? undoRestorePoint;
  int? redoRestorePoint;
  void setRestorePoint() {
    undoRestorePoint = undoStack.length;
    redoRestorePoint = redoStack.length;
  }

  void restore() {
    assert(undoRestorePoint != null && redoRestorePoint != null);
    undoStack.removeRange(undoRestorePoint!, undoStack.length);
    redoStack.removeRange(redoRestorePoint!, redoStack.length);
    undoRestorePoint = null;
    redoRestorePoint = null;
  }

  List<Doable> getDoableFromRestorePoint() {
    return undoStack.sublist(undoRestorePoint!);
  }
  MapHistory copy() => MapHistory(redoStack: redoStack,undoStack: undoStack,undoRestorePoint: undoRestorePoint,redoRestorePoint: redoRestorePoint);
}