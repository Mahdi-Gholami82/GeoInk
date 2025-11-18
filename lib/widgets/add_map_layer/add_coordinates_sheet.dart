import 'package:flutter/material.dart';
import 'package:mapify/providers/input_list_coordinates_provider.dart';
import 'package:mapify/widgets/add_map_layer/input_list_view.dart';
import 'package:provider/provider.dart';

class AddCoordinatesSheet extends StatefulWidget {
  const AddCoordinatesSheet({super.key, required this.title});
  final String title;

  @override
  State<AddCoordinatesSheet> createState() => _AddCoordinatesSheetState();
}

class _AddCoordinatesSheetState extends State<AddCoordinatesSheet> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(20),
          child: Column(
            spacing: 20,
            children: [
              Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(child: InputListView()),
            ],
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: ElevatedButton(
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
