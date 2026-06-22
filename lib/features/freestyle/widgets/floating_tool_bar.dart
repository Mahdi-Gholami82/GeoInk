import 'package:geoink/core/ui/floating_decoration.dart';
import 'package:geoink/core/ui/floating_shadow.dart';
import 'package:geoink/features/freestyle/widgets/toolbar_button.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    switchColor = color;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 50),
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: makeFloatingDecoration(context),
      child: Material(
        child: Row(
          children: [
            // TODO: implement undo redo
            // ToolbarButton(
            //   onTap: () {
            //     widget.onUndo();
            //   },
            //   children: [
            //     Icon(Icons.undo),
            //     Text("Undo", style: TextStyle(fontWeight: FontWeight.w600)),
            //   ],
            // ),
            // ToolbarButton(
            //   onTap: () {
            //     widget.onRedo();
            //   },
            //   children: [
            //     Text("Redo", style: TextStyle(fontWeight: FontWeight.w600)),
            //     Icon(Icons.redo),
            //   ],
            // ),
            // Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 10)),
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
