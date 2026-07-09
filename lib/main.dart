import 'dart:io';

import 'package:geoink/core/theme/theme.dart';
import 'package:geoink/data/models/prefs_state.dart';
import 'package:geoink/features/freestyle/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoink/data/providers/theme.dart';
import 'package:geoink/features/home/page.dart';
import 'package:http/http.dart';
import 'package:http/retry.dart';
import 'package:geoink/features/settings/page.dart';
import 'package:window_manager/window_manager.dart';

final httpClient = RetryClient(Client());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PrefsState.init();
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = WindowOptions(
      size: Size(1000, 700),
      // minimumSize: Size(500, 700),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(ProviderScope(child: GeoInkApp()));
}

class GeoInkApp extends ConsumerStatefulWidget {
  const GeoInkApp({super.key});

  @override
  ConsumerState<GeoInkApp> createState() => _GeoInkAppState();
}

class _GeoInkAppState extends ConsumerState<GeoInkApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      darkTheme: darkMode,
      theme: lightMode,
      themeMode: ref.watch(themeProvider),
      routes: {
        SettingsPage.route: (context) => SettingsPage(),
        FreeStylePage.route: (context) => FreeStylePage(),
      },
    );
  }
}
