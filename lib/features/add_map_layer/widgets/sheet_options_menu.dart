import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapify/core/utils/coordinates_reformatter.dart';
import 'package:mapify/data/providers/input_list_coordinates_provider.dart';

class SheetOptionsMenu extends ConsumerStatefulWidget {
  SheetOptionsMenu({super.key});
  final MenuController menuController = MenuController();
  @override
  ConsumerState<SheetOptionsMenu> createState() => _SheetOptionsMenuState();
}

class _SheetOptionsMenuState extends ConsumerState<SheetOptionsMenu> {
  late InputListCoordinatesNotifier inputListNotifier;
  late InputListCoordinatesState inputListState;

  String parseResultToText(CoordinatesParseResult result) {
    return "${result.latValue}, ${result.longValue}";
  }

  @override
  void initState() {
    inputListNotifier = ref.read(inputListCoordinatesProvider.notifier);
    inputListState = ref.read(inputListCoordinatesProvider);
    super.initState();
  }

  void toggleMenu() {
    if (widget.menuController.isOpen) {
      widget.menuController.close();
    } else {
      widget.menuController.open();
    }
  }

  Future<String?> getTextFromClipboard() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);

    return data?.text;
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: widget.menuController,
      menuChildren: [
        MenuItemButton(
          onPressed: () async {
            String? clipboardText = await getTextFromClipboard();
            if (clipboardText != null) {
              if (InputListCoordinatesState
                      .minNumberOfCoordinatesFields[inputListState.type]! >
                  1) {
                Iterable<CoordinatesParseResult> results = parseAll(
                  clipboardText,
                );
                inputListNotifier.addMultipleCoordinates(
                  results.map((e) => parseResultToText(e)),
                );
              } else {
                CoordinatesParseResult? result = tryParseSingle(clipboardText);
                if (result != null) {
                  inputListNotifier.addCoordinatesField(
                    input: parseResultToText(result),
                  );
                }
              }
              inputListNotifier.clearEmptyFields();
            }
          },
          child: const Text('Parse From Clipboard'),
        ),
        MenuItemButton(
          onPressed: () {},
          child: const Text('Parse From Text Input'),
        ),
        MenuItemButton(
          onPressed: () {
            inputListNotifier.clearEmptyFields();
          },
          child: const Text('Clear Empty'),
        ),
      ],
      child: IconButton(
        onPressed: () {
          toggleMenu();
        },
        icon: Icon(Icons.more_vert),
      ),
    );
  }
}
