import 'package:flutter/material.dart';
import 'package:geoink/features/freestyle/widgets/floating_container.dart';
import 'package:geoink/features/freestyle/widgets/toolbar_button.dart';

class FloatingToolBar extends StatefulWidget {
  const FloatingToolBar({
    required this.onOk,
    required this.onCancel,
    required this.onRedo,
    required this.onUndo,
    this.enableOk = true,
    this.enableCancel = true,
    this.enableRedo = true,
    this.enableUndo = true,
  });
  final Function onOk;
  final Function onCancel;
  final Function onRedo;
  final Function onUndo;
  final bool enableOk;
  final bool enableCancel;
  final bool enableRedo;
  final bool enableUndo;

  @override
  State<FloatingToolBar> createState() => _FloatingToolBarState();
}

class _FloatingToolBarState extends State<FloatingToolBar> {
  Color color = Colors.red;
  late Color switchColor;
  final BoxConstraints buttonConstraints = BoxConstraints(minHeight: 50);

  @override
  void initState() {
    super.initState();
    switchColor = color;
  }

  @override
  Widget build(BuildContext context) {
    return FloatingContainer(
      child: Material(
        child: Row(
          children: [
            ToolbarButton(
              constraints: buttonConstraints,
              onTap: () {
                widget.onUndo();
              },
              children: [
                Icon(Icons.undo),
                Text("Undo", style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            ToolbarButton(
              constraints: buttonConstraints,
              onTap: () {
                widget.onRedo();
              },
              children: [
                Text("Redo", style: TextStyle(fontWeight: FontWeight.w600)),
                Icon(Icons.redo),
              ],
            ),
            Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 10)),
            Row(
              spacing: 8,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(10),
                    ),
                  ),
                  onPressed: widget.enableCancel
                      ? () {
                          widget.onCancel();
                        }
                      : null,
                  child: Text("Cancel"),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(10),
                    ),
                  ),
                  onPressed: widget.enableOk
                      ? () {
                          widget.onOk();
                        }
                      : null,
                  child: Text("Ok"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
