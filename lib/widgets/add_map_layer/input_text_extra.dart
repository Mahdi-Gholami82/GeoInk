import 'package:flutter/material.dart';

class InputTextExtra extends StatelessWidget {
  const InputTextExtra({
    super.key,
    required this.isBeingEdited,
    required this.controller,
    required this.onSubmit,
    required this.title,
  });

  final bool isBeingEdited;
  final TextEditingController controller;
  final Function(String) onSubmit;
  final String title;
  @override
  Widget build(BuildContext context) {
    if (isBeingEdited) {
      return TextFormField(
        controller: controller,
        autofocus: true,
        onChanged: (value) {},
        onFieldSubmitted: (value) {
          onSubmit(value);
        },
      );
    }
    return Text(title);
  }
}
