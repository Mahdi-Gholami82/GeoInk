import 'package:flutter/material.dart';

class CustomSheetDragHandle extends StatelessWidget {
  const CustomSheetDragHandle({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(10),
    child: Container(
      height: 5,
      width: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.onSurface.withAlpha(125),
      ),
    ),
  );
}
