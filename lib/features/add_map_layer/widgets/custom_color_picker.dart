import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CustomColorPicker extends StatefulWidget {
  const CustomColorPicker({
    super.key,
    required this.onColorChanged,
    required this.initialColor,
  });
  final Function(Color value) onColorChanged;
  final Color initialColor;

  @override
  State<CustomColorPicker> createState() => _CustomColorPickerState();
}

class _CustomColorPickerState extends State<CustomColorPicker> {
  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 15,
      children: [
        FloatingActionButton.small(
          backgroundColor: widget.initialColor,
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Select a color',),
                  content: SingleChildScrollView(
                    child: BlockPicker(
                      pickerColor: widget.initialColor,
                      onColorChanged: (Color value) {
                        widget.onColorChanged(value);
                      },
                    ),
                  ),
                );
              },
            );
          },
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Icon(Icons.colorize, color: Colors.white, size: 18),
        ),
        Text("Color", style: TextStyle(fontWeight: FontWeight.w500),overflow: TextOverflow.ellipsis,),
      ],
    );
  }
}
