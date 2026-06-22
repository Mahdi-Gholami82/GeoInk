abstract class Doable {
  Doable({required this.executeBase,required this.undoBase}) {
  }

  bool done = false;
  final Function executeBase;
  final Function undoBase;
  void doIt() {
    assert(done);
    executeBase();
    done = true;
  }

  void undoIt() {
    assert(!done);
    undoBase();
    done = false;
  }
}

class DoableHistory {
  List<Doable> _undoStack = [];
  List<Doable> _redoStack = [];

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  void undo() {
    assert(canUndo);
    Doable action = _undoStack.removeLast();
    action.undoIt();
    _redoStack.add(action);
  }

  void redo() {
    assert(canRedo);
    Doable action = _redoStack.removeLast();
    action.doIt();
    _undoStack.add(action);
  }

  void execute(Doable action) {
    action.doIt();
    _undoStack.add(action);
    _redoStack.clear();
  }
}
