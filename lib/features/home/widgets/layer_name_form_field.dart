import 'package:flutter/material.dart';
import 'package:geoink/core/utils/standard_name.dart';

class NameFormField extends StatelessWidget {
  const NameFormField({
    super.key,
    required this.formKey,
    required this.onSubmitIfValid,
    required this.validator,
    required this.controller,
  });
  final GlobalKey<FormState> formKey;
  final void Function(String text) onSubmitIfValid;
  final String? Function(String? text) validator;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: TextFormField(
        decoration: InputDecoration(hintText: "Name"),
        controller: controller,
        maxLength: maxCharInName,
        onFieldSubmitted: (text) {
          final bool isValid = formKey.currentState?.validate() ?? false;
          if (isValid) {
            onSubmitIfValid(controller.text);
          }
        },
        validator: validator,
      ),
    );
  }
}
