import 'package:flutter/material.dart';

class AppbarMenu extends StatelessWidget {
  AppbarMenu({required this.menuChildren, required this.title}) {}
  final List<Widget> menuChildren;
  final Widget title;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: [
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: 150),
          child: Column(children: menuChildren),
        ),
      ],
      style: MenuStyle(
        shape: WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
      ),
      alignmentOffset: Offset(0, 12),
      builder: (context, controller, child) {
        return TextButton(
          child: title,
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        );
      },
    );
  }
}
