import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoink/core/utils/standard_name_regex.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:geoink/data/providers/history.dart';
import 'package:geoink/data/providers/map_tiles.dart';

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
    mapLayerList = ref.read(tileEntriesProvider);
  }

  void validateAndPop() {
    final bool isValid = formKey.currentState?.validate() ?? false;
    if (isValid) {
      ref
          .read(historyProvider.notifier)
          .actionAddLayer(
            MapLayer(name: controller.text, entryType: selectedType),
          );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: AlertDialog(
        title: Text("Add a layer"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<EntryType>(
              showSelectedIcon: false,
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
            Form(
              key: formKey,
              child: TextFormField(
                decoration: InputDecoration(hintText: "Name"),
                controller: controller,
                onFieldSubmitted: (Text) {
                  validateAndPop();
                },
                validator: (value) {
                  if (value == null) {
                    return "Please enter a name";
                  }
                  RegExpMatch? match = standardNameRegex.firstMatch(value);
                  String? name = match?.group(1);
                  if (match == null || name == null) {
                    return "Invalid name / Must be shorter than $maxCharInName";
                  }
                  if (mapLayerList.items.any((e) => e.name == name)) {
                    return "Duplicate name";
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              validateAndPop();
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
