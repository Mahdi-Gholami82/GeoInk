import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class AddMapElementFab extends StatelessWidget {
  const AddMapElementFab({super.key});

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      spacing: 3,
      children: [
        SpeedDialChild(
          child: Icon(Icons.polyline),
          label: 'Polyline',
          onTap: null,
        ),
        SpeedDialChild(
          child: Icon(Icons.adjust),
          label: 'Circular',
          onTap: null,
        ),
      ],
    );
  }
}
