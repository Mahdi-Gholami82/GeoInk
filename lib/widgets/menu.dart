import 'package:flutter/material.dart';

class AddMenu extends StatelessWidget {
  const AddMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(child: Text("Polygon")),
        MenuItemButton(child: Text("Circle")),
        MenuItemButton(child: Text("Point")),
      ],
    );
  }
}
