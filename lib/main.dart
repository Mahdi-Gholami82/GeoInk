import 'package:flutter/material.dart';
import 'package:mapify/pages/home.dart';
import 'package:http/http.dart';
import 'package:http/retry.dart';

final httpClient = RetryClient(Client());

void main() {
  runApp(MaterialApp(home: HomePage()));
}

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(children: [ListTile(title: Text("yo"))]),
    );
  }
}
