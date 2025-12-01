import 'package:flutter/material.dart';
import 'package:mapify/data/providers/input_list_coordinates_provider.dart';
import 'package:mapify/data/providers/map_tiles_provider.dart';
import 'package:mapify/data/providers/theme_provider.dart';
import 'package:mapify/features/home/page.dart';
import 'package:http/http.dart';
import 'package:http/retry.dart';
import 'package:mapify/features/settings/page.dart';
import 'package:provider/provider.dart';

final httpClient = RetryClient(Client());

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => TileEntriesProvider()),
        ChangeNotifierProvider(
          create: (context) => InputListCoordinatesProvider(),
        ),
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
      theme: context.watch<ThemeProvider>().themeData,
      routes: {SettingsPage.route: (context) => SettingsPage()},
    );
  }
}
