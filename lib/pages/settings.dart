import 'package:flutter/material.dart';
import 'package:mapify/misc/theme.dart' as theme;
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  static const route = "/settings";

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
              SettingsTile.navigation(
                leading: Icon(Icons.language),
                title: Text('Language'),
                value: Text('English'),
              ),
              SettingsTile.switchTile(
                initialValue:
                    Provider.of<theme.ThemeProvider>(
                      context,
                      listen: false,
                    ).themeData ==
                    theme.darkMode,
                onToggle: (value) {
                  Provider.of<theme.ThemeProvider>(
                    context,
                    listen: false,
                  ).toggleMode();
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
