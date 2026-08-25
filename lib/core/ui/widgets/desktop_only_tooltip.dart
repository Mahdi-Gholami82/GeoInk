import 'dart:io';

import 'package:flutter/material.dart';

class DesktopOnlyTooltip extends StatelessWidget {
  const DesktopOnlyTooltip({super.key, required this.child, this.toolTip = ""});
  final Widget child;
  final String toolTip;
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: Platform.isLinux || Platform.isMacOS || Platform.isWindows
          ? toolTip
          : "",
      child: child,
    );
  }
}
