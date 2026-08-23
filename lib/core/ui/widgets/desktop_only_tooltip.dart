import 'dart:io';

import 'package:flutter/material.dart';

class DesktopOnlyTooltip extends StatelessWidget {
  DesktopOnlyTooltip({super.key, required this.child, this.toolTip = ""});
  Widget child;
  String toolTip;
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
