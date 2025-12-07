import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapify/data/providers/theme_provider.dart';
import 'package:mapify/features/home/page.dart';
import 'package:http/http.dart';
import 'package:http/retry.dart';
import 'package:mapify/features/settings/page.dart';
import 'package:window_manager/window_manager.dart';

final httpClient = RetryClient(Client());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    size: Size(1000, 700),
    minimumSize: Size(500, 700),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(ProviderScope(child: MapifyApp()));
}

class MapifyApp extends ConsumerStatefulWidget {
  const MapifyApp({super.key});

  @override
  ConsumerState<MapifyApp> createState() => _MapifyAppState();
}

class _MapifyAppState extends ConsumerState<MapifyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      theme: ref.watch(themeProvider),
      routes: {SettingsPage.route: (context) => SettingsPage()},
    );
  }
}
