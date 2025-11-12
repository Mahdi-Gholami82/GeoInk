import 'package:flutter/material.dart';

class InputTextDialogue extends StatefulWidget {
  final Function onCancel;
  final Function onSave;

  const InputTextDialogue({
    super.key,
    required this.onCancel,
    required this.onSave,
  });

  @override
  State<InputTextDialogue> createState() => _InputTextDialogueState();
}

class _InputTextDialogueState extends State<InputTextDialogue> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Insert Text"),
      titleTextStyle: TextStyle(fontSize: 18, color: Colors.black),
      content: TextField(
        keyboardType: TextInputType.multiline,
        controller: controller,
        maxLines: null,
        decoration: const InputDecoration(hintText: 'Enter your message...'),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onCancel();
          },
          child: Text("cancel"),
        ),
        TextButton(
          onPressed: () {
            widget.onSave(controller.text);
          },
          child: Text("save"),
        ),
      ],
    );
  }
}
