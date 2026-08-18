import 'package:flutter/material.dart';

class OkCancelDialog extends StatelessWidget {
  OkCancelDialog({
    super.key,
    this.onOk,
    this.onCancel,
    required this.message,
    required this.title,
  });
  final void Function()? onOk;
  final void Function()? onCancel;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: onCancel ?? () {}, child: Text("cancel")),
        TextButton(onPressed: onOk, child: Text("ok")),
      ],
    );
  }
}
