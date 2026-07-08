import 'package:flutter/material.dart';

class ToolbarButton extends StatelessWidget {
  const ToolbarButton({
    required this.onTap,
    required this.children,
    this.spacing = 4,
    this.constraints,
  });
  final GestureTapCallback onTap;
  final List<Widget> children;
  final double spacing;
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: constraints,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        alignment: Alignment.center,
        child: Row(spacing: spacing, children: children),
      ),
    );
  }
}
