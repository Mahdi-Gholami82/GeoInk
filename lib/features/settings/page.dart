import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoink/data/providers/theme.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});
  static const route = "/settings";

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text('Common'),
            tiles: <SettingsTile>[
              // SettingsTile.navigation(
              //   leading: Icon(Icons.language),
              //   title: Text('Language'),
              //   value: Text('English'),
              // ),
              SettingsTile.switchTile(
                initialValue: ref.watch(themeProvider.notifier).isDark(context),
                onToggle: (value) {
                  ref.read(themeProvider.notifier).toggleMode(context);
                },
                leading: Icon(Icons.format_paint),
                title: Text('Light/Dark Theme'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
