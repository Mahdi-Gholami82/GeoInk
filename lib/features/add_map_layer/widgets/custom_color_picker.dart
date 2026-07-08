import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:geoink/core/utils/color_tools.dart';
import 'package:geoink/core/utils/show_color_picker.dart';

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
            showSimpleColorPicker(
              context: context,
              initialColor: widget.initialColor,
            ).then((chosenColor) {
              if (chosenColor != null) {
                widget.onColorChanged(chosenColor);
              }
            });
          },
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Icon(
            Icons.colorize,
            color: widget.initialColor.onColor(),
            size: 18,
          ),
        ),
        Text(
          "Color",
          style: TextStyle(fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
