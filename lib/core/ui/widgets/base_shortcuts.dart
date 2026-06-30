import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoink/data/models/map_actions.dart';
import 'package:geoink/data/providers/history.dart';

// Base
class UndoIntent extends Intent {}
class Redointent extends Intent {}

// FreeStyle
class CancelDrawIntent extends Intent {}
class ConfirmDrawIntent extends Intent {}

class BaseShortcuts extends ConsumerWidget {
  const BaseShortcuts({required this.child, this.freeStyleShortcuts = false});
  final Widget child;
  final bool freeStyleShortcuts;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    HistoryNotifier historyNotifier = ref.watch(historyProvider.notifier);

    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyZ):
            UndoIntent(),
        LogicalKeySet(
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
          LogicalKeyboardKey.keyZ,
        ): Redointent(),
        if (freeStyleShortcuts) ...{
          SingleActivator(LogicalKeyboardKey.escape):CancelDrawIntent(),
          SingleActivator(LogicalKeyboardKey.enter):ConfirmDrawIntent()
        }
      },
      child: Actions(
        actions: {
          UndoIntent: CallbackAction(onInvoke: (intent) => historyNotifier.undo()),
          Redointent: CallbackAction(onInvoke: (intent) => historyNotifier.redo()),
        },
        child: child,
      ),
    );
  }
}
