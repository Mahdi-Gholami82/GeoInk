import 'package:flutter/material.dart';
import 'package:geoink/core/ui/widgets/desktop_only_tooltip.dart';

class ToolbarButton extends StatelessWidget {
  const ToolbarButton({
    super.key,
    required this.onTap,
    required this.children,
    this.spacing = 4,
    this.constraints,
    this.desktopOnlyToolTip = "",
  });
  final GestureTapCallback onTap;
  final List<Widget> children;
  final double spacing;
  final BoxConstraints? constraints;
  final String desktopOnlyToolTip;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: DesktopOnlyTooltip(
        toolTip: desktopOnlyToolTip,
        child: Container(
          constraints: constraints,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          alignment: Alignment.center,
          child: Row(spacing: spacing, children: children),
        ),
      ),
    );
  }
}
