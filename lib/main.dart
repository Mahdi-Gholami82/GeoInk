import 'package:flutter/material.dart';
import 'package:mapify/pages/home.dart';
import 'package:http/http.dart';
import 'package:http/retry.dart';
import 'package:mapify/pages/settings.dart';
import 'package:provider/provider.dart';
import 'package:mapify/misc/theme.dart' as theme;

final httpClient = RetryClient(Client());

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => theme.ThemeProvider()),
      ],
      child: MapifyApp(),
    ),
  );
}

class MapifyApp extends StatefulWidget {
  const MapifyApp({super.key});

  @override
  State<MapifyApp> createState() => _MapifyAppState();
}

class _MapifyAppState extends State<MapifyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      theme: Provider.of<theme.ThemeProvider>(context).themeData,
      routes: {SettingsPage.route: (context) => SettingsPage()},
    );
  }
}
