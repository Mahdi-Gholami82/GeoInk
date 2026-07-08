import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoink/core/utils/coordinates_reformatter.dart';
import 'package:geoink/data/models/coordinates_sheet_data.dart';
import 'package:geoink/data/providers/input_list_coordinates.dart';

class InputListView extends ConsumerStatefulWidget {
  const InputListView({
    super.key,
    required this.formGlobalKey,
    required this.scrollController,
  });
  final GlobalKey formGlobalKey;
  final ScrollController scrollController;

  @override
  ConsumerState<InputListView> createState() => _InputListViewState();
}

class _InputListViewState extends ConsumerState<InputListView> {
  late final bool needsRadiusField;
  late InputListCoordinatesNotifier inputListNotifier;

  @override
  void initState() {
    super.initState();
    inputListNotifier = ref.read(inputListCoordinatesProvider.notifier);
  }

  String? Function(String?) getFieldValidator(SheetInputFieldType type) {
    switch (type) {
      case SheetInputFieldType.coordinates:
        return (value) {
          if (value == null || value.isEmpty) {
            return "The coordinates field cannot be empty.";
          }
          if (tryParseSingle(value) == null) {
            return "Unable to parse data.";
          }
          return hasMatchField(value)
              ? null
              : "The input does not match any supported coordinates formats.";
        };
      case SheetInputFieldType.name:
        return (value) {
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
    List<SheetListInput> inputs = ref
        .watch(inputListCoordinatesProvider)
        .fields;
    void onSubmit(SheetListInput currentInput) {}

    return Form(
      key: widget.formGlobalKey,
      child: ListView.builder(
        controller: widget.scrollController,
        itemCount: inputs.length,
        itemBuilder: (context, index) {
          SheetListInput input = inputs[index];

          return ListTile(
            leading: input.icon,
            title: TextFormField(
              maxLines: 1,
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
                suffixIcon: input.type == SheetInputFieldType.coordinates
                    ? IconButton(
                        onPressed: () {
                          inputListNotifier.removeField(input);
                        },
                        icon: Icon(Icons.delete_outline),
                      )
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
