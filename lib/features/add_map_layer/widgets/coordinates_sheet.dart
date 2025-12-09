import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapify/data/models/flutter_map_entry.dart';
import 'package:mapify/data/providers/input_list_coordinates_provider.dart';
import 'package:mapify/features/add_map_layer/widgets/custom_color_picker.dart';
import 'package:mapify/features/add_map_layer/widgets/input_list_view.dart';
import 'package:mapify/features/add_map_layer/widgets/map_layer_picker.dart';

class CoordinatesSheet extends ConsumerStatefulWidget {
  const CoordinatesSheet({
    super.key,
    required this.scrollController,
    required this.title,
  });
  final ScrollController scrollController;
  final String title;

  @override
  ConsumerState<CoordinatesSheet> createState() => _CoordinatesSheetState();
}

class _CoordinatesSheetState extends ConsumerState<CoordinatesSheet> {
  Color chosenColor = Colors.red;
  final formGlobalKey = GlobalKey<FormState>();
  late InputListCoordinatesNotifier inputListNotifier;

  @override
  void initState() {
    super.initState();
    inputListNotifier = ref.read(inputListCoordinatesProvider.notifier);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                height: 5,
                width: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(125),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 15)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        spacing: 30,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomColorPicker(
                            onColorChanged: (Color value) {
                              setState(() {
                                chosenColor = value;
                              });
                            },
                            initialColor: chosenColor,
                          ),
                          MapLayerPicker(type: inputListNotifier.type),
                        ],
                      ),
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: widget.scrollController,
                        child: InputListView(formGlobalKey: formGlobalKey),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 20,
                      children: [
                        if (inputListNotifier.type == EntryType.polygon ||
                            inputListNotifier.type == EntryType.polyline)
                          OutlinedButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.surface,
                              minimumSize: const Size(110, 50),
                              shape: const StadiumBorder(),
                            ),
                            onPressed: () {
                              inputListNotifier.addCoordinatesField();
                            },
                            child: Text(
                              "Add Coordinates",
                              style: TextStyle(
                                fontSize: 15,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            minimumSize: Size(110, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            if (formGlobalKey.currentState!.validate()) {
                              inputListNotifier.color = chosenColor;
                              Navigator.of(
                                context,
                              ).pop(inputListNotifier.takeFinalResult());
                            }
                          },
                          child: Text(
                            "Apply",
                            style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: 10,
          right: 10,
          child: IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
        ),
        Positioned(
          top: 10,
          left: 10,
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.close),
          ),
        ),
      ],
    );
  }
}
