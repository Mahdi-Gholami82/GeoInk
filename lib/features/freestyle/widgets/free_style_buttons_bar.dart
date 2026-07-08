import 'package:geoink/core/ui/floating_shadow.dart';
import 'package:geoink/core/ui/map_features_icons.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class Togglebutton extends StatelessWidget {
  const Togglebutton({super.key, required this.icon, required this.label});
  final Icon icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class FreeStyleButtonsBar extends StatefulWidget
    implements PreferredSizeWidget {
  const FreeStyleButtonsBar({
    super.key,
    required this.initSelectedType,
    required this.onTypeSwitch,
    required this.onConfirm,
    required this.onCancel,
  });
  final EntryType initSelectedType;
  final void Function(EntryType type) onTypeSwitch;
  final void Function() onConfirm;
  final void Function() onCancel;

  @override
  State<FreeStyleButtonsBar> createState() => _FreeStyleButtonsBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 100);
}

class _FreeStyleButtonsBarState extends State<FreeStyleButtonsBar> {
  late List<Togglebutton> buttons;
  late List<bool> selected;
  late EntryType selectedType;

  @override
  void initState() {
    super.initState();
    buttons = EntryType.values
        .map(
          (e) => Togglebutton(label: e.name, icon: Icon(MapIcons.fromType(e))),
        )
        .toList();
    selected = List.filled(buttons.length, false);
    selectedType = widget.initSelectedType;
    buttons.firstWhereIndexedOrNull((index, e) {
      if (e.label == selectedType.name) {
        updateSelectedType(index);
        return true;
      }
      return false;
    });
  }

  void updateSelectedType(int index) {
    selected = List.filled(selected.length, false);
    selected[index] = true;
    selectedType = EntryType.values.firstWhere(
      (element) => element.name == buttons[index].label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned(
          top: 30,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Center(
              child: FittedBox(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [FloatingShadow()],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                          ),
                          onPressed: () {
                            widget.onCancel();
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.close),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Center(
                            child: ToggleButtons(
                              children: buttons,
                              isSelected: selected,
                              onPressed: (index) {
                                setState(() {
                                  updateSelectedType(index);
                                  widget.onTypeSwitch(selectedType);
                                });
                              },
                            ),
                          ),
                        ),
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                          ),
                          onPressed: () {
                            widget.onConfirm();
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.check),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
