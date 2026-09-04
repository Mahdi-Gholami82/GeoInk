import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoink/data/models/color_theme.dart';
import 'package:geoink/data/models/prefs_state.dart';
import 'package:geoink/data/providers/theme.dart';
import 'package:geoink/features/settings/widgets/title.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});
  static const route = "/settings";

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    ColorTheme selectedColorTheme = PrefsState.colorTheme;
    var themeNotifier = ref.read(themeProvider.notifier);
    var appTheme = ref.read(themeProvider);
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      ),
      body: CustomScrollView(
        slivers: [
          SliverList.list(
            children: [
              SettingsTitle(title: Text("Common")),
              ListTile(
                leading: const Icon(Icons.format_paint),
                title: Text("Light/Dark Theme"),
                trailing: Switch(
                  value: ref.watch(themeProvider).isDark(context),
                  onChanged: (value) {
                    themeNotifier.toggleMode(context);
                  },
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(child: SettingsTitle(title: Text("Color theme"))),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            sliver: SliverGrid.builder(
              itemCount: ColorTheme.values.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 60,
                crossAxisSpacing: 9,
                mainAxisSpacing: 9,
                childAspectRatio: 1.4,
              ),
              itemBuilder: (context, index) {
                final colorTheme = ColorTheme.values[index];

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        themeNotifier.changeColor(colorTheme);
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        Ink(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color:
                                (appTheme.isDark(context)
                                        ? colorTheme.scheme.data.dark
                                        : colorTheme.scheme.data.light)
                                    .primary,
                          ),
                        ),
                        if (colorTheme == selectedColorTheme)
                          const Center(child: Icon(Icons.check)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
