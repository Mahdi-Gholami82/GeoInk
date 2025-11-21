import 'package:flutter/material.dart';
import 'package:mapify/data/providers/input_list_coordinates_provider.dart';
import 'package:mapify/features/add_map_layer/custom_color_picker.dart';
import 'package:mapify/features/add_map_layer/input_list_view.dart';
import 'package:provider/provider.dart';

class CoordinatesSheet extends StatefulWidget {
  const CoordinatesSheet({
    super.key,
    required this.scrollController,
    required this.title,
  });
  final ScrollController scrollController;
  final String title;

  @override
  State<CoordinatesSheet> createState() => _CoordinatesSheetState();
}

class _CoordinatesSheetState extends State<CoordinatesSheet> {
  Color chosenColor = Colors.red;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                height: 5,
                width: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(125),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 15)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        spacing: 15,
                        children: [
                          CustomColorPicker(
                            onColorChanged: (Color value) {
                              setState(() {
                                chosenColor = value;
                              });
                            },
                            initialColor: chosenColor,
                          ),
                          Text(
                            "Change layer color",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: widget.scrollController,
                        child: InputListView(),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        minimumSize: Size(80, 45),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(
                          context
                              .read<InputListCoordinatesProvider>()
                              .takeFinalCoordinates(),
                        );
                      },
                      child: Text(
                        "Apply",
                        style: TextStyle(
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
