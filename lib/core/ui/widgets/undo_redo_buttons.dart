import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoink/core/ui/widgets/toolbar_button.dart';

class UndoRedoButtons extends ConsumerWidget {
  UndoRedoButtons({required this.onUndo, required this.onRedo});
  final Function onUndo;
  final Function onRedo;

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return Row(
      children: [
        ToolbarButton(
          onTap: () {
            onUndo();
          },
          children: [
            Icon(Icons.undo),
            Text("Undo", style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        ToolbarButton(
          onTap: () {
            onRedo();
          },
          children: [
            Text("Redo", style: TextStyle(fontWeight: FontWeight.w600)),
            Icon(Icons.redo),
          ],
        ),
      ],
    );
  }
}
