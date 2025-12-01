import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class AddCoordinatesSheet extends StatefulWidget {
  const AddCoordinatesSheet({super.key, required this.title});
  final String title;

  @override
  State<AddCoordinatesSheet> createState() => _AddCoordinatesSheetState();
}

class _AddCoordinatesSheetState extends State<AddCoordinatesSheet> {
  Color chosenColor = Colors.red;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  spacing: 15,
                  children: [
                    FloatingActionButton.small(
                      backgroundColor: chosenColor,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Select a color'),
                              content: SingleChildScrollView(
                                child: BlockPicker(
                                  pickerColor: chosenColor,
                                  onColorChanged: (Color value) {
                                    setState(() {
                                      chosenColor = value;
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.colorize,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    Text(
                      "Change layer color",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
        ),
        Positioned(
          top: 10,
          left: 10,
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.close),
          ),
        ),
      ],
    );
  }
}
