import 'package:flutter/material.dart';
import 'package:mapify/core/utils/coordinates_reformatter.dart';
import 'package:mapify/data/models/coordinates_sheet_data_models.dart';
import 'package:mapify/data/providers/input_list_coordinates_provider.dart';
import 'package:provider/provider.dart';

class InputListView extends StatefulWidget {
  const InputListView({super.key, required this.formGlobalKey});
  final GlobalKey formGlobalKey;

  @override
  State<InputListView> createState() => _InputListViewState();
}

class _InputListViewState extends State<InputListView> {
  List<SheetListInput> get inputs =>
      context.read<InputListCoordinatesProvider>().inputs;

  set inputs(value) {
    context.read<InputListCoordinatesProvider>().inputs = value;
  }

  late final bool needsRadiusField;
  final CoordinatesParser parser = CoordinatesParser();

  @override
  void initState() {
    super.initState();
    context.read<InputListCoordinatesProvider>().initCoordinatesProvider();
    needsRadiusField = context
        .read<InputListCoordinatesProvider>()
        .needsRadiusField;
    context.read<InputListCoordinatesProvider>().initSheetListInput();
  }

  String? Function(String?) getFieldValidator(SheetInputFieldType type) {
    switch (type) {
      case SheetInputFieldType.coordinate:
        return (value) {
          if (value == null || value.isEmpty) {
            return "The coordinate field cannot be empty.";
          }
          return parser.hasMatchField(value)
              ? null
              : "The input does not match any supported coordinate formats.";
        };
      case SheetInputFieldType.name:
        return (value) {
          if (value == null || value.isEmpty) {
            return "The name field cannot be empty.";
          }
          return null;
        };
      case SheetInputFieldType.radius:
        return (value) {
          double? radius = double.tryParse(value ?? "");
          if (value == null || value.isEmpty) {
            return "The radius field cannot be empty.";
          } else if (radius == null) {
            return "Please enter a valid number.";
          } else if (radius <= 0) {
            return "Radius must be greater than zero.";
          }
          return null;
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final providerWatch = context.watch<InputListCoordinatesProvider>();
    final providerRead = context.read<InputListCoordinatesProvider>();

    void onSubmit(SheetListInput currentInput) {}

    return Form(
      key: widget.formGlobalKey,
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: inputs.length,
        itemBuilder: (context, index) {
          SheetListInput input = inputs[index];

          return ListTile(
            leading: input.icon,
            title: TextFormField(
              controller: input.controller,
              autofocus: true,
              onChanged: (value) {},
              validator: getFieldValidator(input.type),
              onFieldSubmitted: (value) {
                onSubmit(input);
              },
              decoration: InputDecoration(
                labelText: input.type.name,
                border: OutlineInputBorder(),
              ),
            ),
          );
        },
      ),
    );
  }
}
