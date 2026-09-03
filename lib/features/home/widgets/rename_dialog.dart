import 'package:flutter/material.dart';
import 'package:geoink/features/home/widgets/layer_name_form_field.dart';

class RenameDialog extends StatefulWidget {
  const RenameDialog({
    super.key,
    required this.initialName,
    required this.onRename,
    required this.validator,
  });
  final String initialName;
  final void Function(String newName) onRename;
  final String? Function(String? value) validator;

  @override
  State<RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<RenameDialog> {
  final GlobalKey<FormState> formKey = GlobalKey();

  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialName);
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.text.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    void doIfValid(String text) {
      widget.onRename(text);
      Navigator.of(context).pop();
    }

    return AlertDialog(
      title: const Text("Rename"),
      content: NameFormField(
        formKey: formKey,
        controller: controller,
        onSubmitIfValid: doIfValid,
        validator: widget.validator,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("cancel"),
        ),
        TextButton(
          onPressed: () {
            final bool isValid = formKey.currentState?.validate() ?? false;
            if (isValid) {
              doIfValid(controller.text);
            }
          },
          child: const Text("ok"),
        ),
      ],
    );
  }
}
