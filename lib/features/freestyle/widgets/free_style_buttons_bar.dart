import 'package:geoink/core/ui/floating_shadow.dart';
import 'package:geoink/core/ui/map_features_icons.dart';
import 'package:geoink/data/models/flutter_map_entry.dart';
import 'package:flutter/material.dart';

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
  late EntryType selectedType;

  @override
  void initState() {
    super.initState();
    selectedType = widget.initSelectedType;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [FloatingShadow()],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                          ),
                          onPressed: () {
                            widget.onCancel();
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.close),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Center(
                            child: SegmentedButton<EntryType>(
                              segments: EntryType.values.map((type) {
                                return ButtonSegment<EntryType>(
                                  value: type,
                                  label: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 5,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(MapIcons.fromType(type)),
                                        SizedBox(height: 8),
                                        Text(
                                          type.name,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                              selected: {selectedType},
                              onSelectionChanged: (selection) {
                                final type = selection.first;

                                setState(() {
                                  selectedType = type;
                                });

                                widget.onTypeSwitch(type);
                              },
                              showSelectedIcon: false,
                              style: SegmentedButton.styleFrom(
                                selectedBackgroundColor:
                                    theme.colorScheme.surfaceContainerHigh,
                                side: BorderSide.none,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
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
                          icon: const Icon(Icons.check),
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
