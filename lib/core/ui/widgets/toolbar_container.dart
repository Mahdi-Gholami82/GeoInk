import 'package:flutter/material.dart';
import 'package:geoink/core/ui/floating_decoration.dart';

class ToolbarContainer extends StatelessWidget {
  const ToolbarContainer({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: makeFloatingDecoration(context),
      constraints: BoxConstraints(minHeight: 50),
      child: Material(child: child),
    );
  }
}
