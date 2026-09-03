import 'package:flutter/material.dart';

class OkCancelDialog extends StatelessWidget {
  const OkCancelDialog({
    super.key,
    required this.title,
    required this.message,
    this.onOk,
    this.onCancel,
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
        TextButton(onPressed: onCancel ?? () {}, child: const Text("cancel")),
        TextButton(onPressed: onOk, child: const Text("ok")),
      ],
    );
  }
}
