import 'package:flutter/material.dart';

class MapDrawer extends StatelessWidget {
  const MapDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(children: [ListTile(title: Text("yo"))]),
    );
  }
}
