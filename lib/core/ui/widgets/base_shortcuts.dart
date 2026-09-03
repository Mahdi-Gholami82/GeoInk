import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoink/data/providers/history.dart';

// Base
class UndoIntent extends Intent {}

class RedoIntent extends Intent {}

// FreeStyle
class CancelDrawIntent extends Intent {}

class ConfirmDrawIntent extends Intent {}

class BaseShortcuts extends ConsumerWidget {
  const BaseShortcuts({
    super.key,
    required this.child,
    this.freeStyleEnable = false,
  });
  final Widget child;
  final bool freeStyleEnable;
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
        ): RedoIntent(),
        // not enabled in free style page
        // if (!freeStyleEnable) ...{},
        // enabled in freestyle page
        if (freeStyleEnable) ...{
          SingleActivator(LogicalKeyboardKey.escape): CancelDrawIntent(),
          SingleActivator(LogicalKeyboardKey.enter): ConfirmDrawIntent(),
        },
      },
      child: Actions(
        actions: {
          UndoIntent: CallbackAction(onInvoke: (_) => historyNotifier.undo()),
          RedoIntent: CallbackAction(onInvoke: (_) => historyNotifier.redo()),
        },
        child: child,
      ),
    );
  }
}
