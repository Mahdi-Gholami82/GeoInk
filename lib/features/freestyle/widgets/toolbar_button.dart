import 'package:flutter/material.dart';

class ToolbarButton extends StatelessWidget {
  const ToolbarButton({required this.onTap,required this.children});
  final GestureTapCallback onTap;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: 55),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        alignment: Alignment.center,
        child: Row(
          spacing: 4,
          children: children,
        ),
      ),
    );
  }
}
