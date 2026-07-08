import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

Future<Color?> showSimpleColorPicker({
  required BuildContext context,
  required Color initialColor,
}) {
  Color chosenColor = initialColor;
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: AlertDialog(
          title: const Text('Select a color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: initialColor,
              onColorChanged: (Color value) {
                chosenColor = value;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(chosenColor);
              },
              child: Text("ok"),
            ),
          ],
        ),
      );
    },
  );
}
