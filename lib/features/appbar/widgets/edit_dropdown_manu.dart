import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoink/data/providers/history.dart';
import 'package:geoink/features/appbar/widgets/appbar_menu.dart';

class EditDropdownManu extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    HistoryNotifier historyNotifier = ref.read(historyProvider.notifier);
    return AppbarMenu(
      title: Text("Edit"),
      menuChildren: [
        MenuItemButton(
          leadingIcon: Icon(Icons.undo),
          onPressed: () {
            historyNotifier.undo();
          },
          child: const Text('Undo'),
        ),
        MenuItemButton(
          leadingIcon: Icon(Icons.redo),
          onPressed: () {
            historyNotifier.redo();
          },
          child: const Text('Redo'),
        ),
      ],
    );
  }
}
