import 'package:flutter/material.dart';

const Size _minSize = Size(110, 50);

class BottomSheetOutlinedBotton extends StatelessWidget {
  const BottomSheetOutlinedBotton({
    super.key,
    required this.onPressed,
    required this.child,
  });
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return OutlinedButton(
      style: TextButton.styleFrom(
        backgroundColor: theme.colorScheme.surface,
        minimumSize: _minSize,
        shape: const StadiumBorder(),
      ),
      onPressed: onPressed,
      child: DefaultTextStyle(
        style: TextStyle(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 15,
        ),
        child: child,
      ),
    );
  }
}

class BottomSheetElevatedButton extends StatelessWidget {
  const BottomSheetElevatedButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        minimumSize: _minSize,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: onPressed,
      child: DefaultTextStyle(
        style: TextStyle(
          fontSize: 15,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        child: child,
      ),
    );
  }
}
