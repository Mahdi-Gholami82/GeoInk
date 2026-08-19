import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoink/core/utils/standard_name.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:geoink/data/providers/history.dart';
import 'package:geoink/data/providers/map_layer_list.dart';
import 'package:geoink/features/home/widgets/layer_name_form_field.dart';

class NewLayerDialogue extends ConsumerStatefulWidget {
  @override
  ConsumerState<NewLayerDialogue> createState() => _NewLayerDialogueState();
}

class _NewLayerDialogueState extends ConsumerState<NewLayerDialogue> {
  final formKey = GlobalKey<FormState>();
  var controller = TextEditingController();
  EntryType selectedType = EntryType.circle;
  late final MapLayerList mapLayerList;

  @override
  void initState() {
    super.initState();
    mapLayerList = ref.read(mapLayerListProvider);
  }

  void doIfValid(String text) {
    ref
        .read(historyProvider.notifier)
        .actionAddLayer(
          MapLayer(name: controller.text, entryType: selectedType),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: AlertDialog(
        title: Text("Add a layer"),
        content: Column(
          spacing: 10,
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<EntryType>(
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                selectedForegroundColor: Theme.of(context).colorScheme.primary,
              ),
              selected: {selectedType},
              segments: EntryType.values
                  .map((e) => ButtonSegment(value: e, label: Text(e.name)))
                  .toList(),
              onSelectionChanged: (value) {
                setState(() {
                  selectedType = value.first;
                });
              },
            ),
            NameFormField(
              formKey: formKey,
              controller: controller,
              onSubmitIfValid: doIfValid,
              validator: (value) =>
                  standarNameValidatorForLayers(value, mapLayerList.items),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final bool isValid = formKey.currentState?.validate() ?? false;
              if (isValid) {
                doIfValid(controller.text);
              }
            },
            child: Text("ok"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("cancel"),
          ),
        ],
      ),
    );
  }
}
