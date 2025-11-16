import 'package:flutter/material.dart';
import 'package:mapify/widgets/add_map_layer/input_list_view.dart';

class AddMarkerDialogue extends StatefulWidget {
  const AddMarkerDialogue({super.key});

  @override
  State<AddMarkerDialogue> createState() => _AddMarkerDialogueState();
}

class _AddMarkerDialogueState extends State<AddMarkerDialogue> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        spacing: 15,
        children: [
          Text("Add Marker", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: InputListView()),
        ],
      ),
    );
  }
}
