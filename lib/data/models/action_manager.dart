
abstract class Doable {
  Doable({Function? executeBase,Function? undoBase}) {
    if (executeBase != null) this.executeBase = executeBase;
    if (undoBase != null) this.undoBase = undoBase;
  }

  bool done = false;
  late final Function executeBase;
  late final Function undoBase;
  void doIt() {
    assert(!done);
    executeBase();
    done = true;
  }

  void undoIt() {
    assert(done);
    undoBase();
    done = false;
  }
}

class ManualDoable extends Doable {
  ManualDoable({required super.executeBase, required super.undoBase});
}

class ContainerDoable<T> extends Doable {
  ContainerDoable({required super.executeBase, required super.undoBase});
  T? data;
}

class BatchDoable extends Doable {
  BatchDoable({required List<Doable> batch}) :
      super(
        executeBase: () {
          for (var action in batch) {
            action.doIt();
          }
        },
        undoBase: () {
          for (var action in batch) {
            action.undoIt();
          }
        },
      );
}

class DoableHistory {
  DoableHistory({List<Doable>? undoStack,List<Doable>? redoStack}) {
    if(undoStack != null) _undoStack = undoStack;
    if(redoStack != null) _redoStack = redoStack;
  }

  List<Doable> _undoStack = [];
  List<Doable> _redoStack = [];

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
  List<Doable> get undoStack => _undoStack;
  List<Doable> get redoStack => _redoStack; 

  bool undo() {
    if (canUndo) {
      Doable action = _undoStack.removeLast();
      action.undoIt();
      _redoStack.add(action);
      return true;
    }
    return false;
  }

  bool redo() {
    if (canRedo) {
      Doable action = _redoStack.removeLast();
      action.doIt();
      _undoStack.add(action);
      return true;
    }
    return false;
  }

  void add(Doable action) {
    _undoStack.add(action);

  }

  void addAndDo(Doable action) {
    action.doIt();
    _undoStack.add(action);
    _redoStack.clear();
  }

  void clearAfterIndex(int index) {
    _undoStack.removeRange(index, _undoStack.length);
    _redoStack.clear();
  }

}
