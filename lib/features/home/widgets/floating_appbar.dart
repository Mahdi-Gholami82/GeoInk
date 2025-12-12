import 'package:flutter/material.dart';

class FloatingAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Widget drawer;
  final Function(String searchText) onSearch;
  final Function onTapSettings;
  final Color? backgroundColor;
  final double borderRadius;
  final double height;
  const FloatingAppBar({
    super.key,
    required this.drawer,
    required this.onSearch,
    required this.onTapSettings,
    this.backgroundColor,
    this.borderRadius = 6,
    this.height = 50,
  });

  @override
  State<FloatingAppBar> createState() => _FloatingAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);
}

class _FloatingAppBarState extends State<FloatingAppBar> {
  late bool freeStyleEnabled;

  @override
  void initState() {
    freeStyleEnabled = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: 15,
          left: 15,
          child: SafeArea(
            child: Row(
              spacing: widget.height / 8,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 13),
                  height: widget.height,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        widget.backgroundColor ??
                        Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: DefaultSelectionStyle.defaultColor,
                        spreadRadius: 2,
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 13),
                  height: widget.height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    color:
                        widget.backgroundColor ??
                        Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: DefaultSelectionStyle.defaultColor,
                        spreadRadius: 2,
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  child: Row(
                    spacing: 3,
                    children: [
                      SizedBox(
                        width: 300,
                        child: Row(
                          spacing: 4,
                          children: [
                            Text(
                              "Free Style",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Transform.scale(
                              scale: 0.85,
                              alignment: Alignment.centerLeft,
                              child: Switch(
                                value: freeStyleEnabled,
                                onChanged: (bool value) {
                                  setState(() {});
                                  {
                                    freeStyleEnabled = value;
                                  }
                                },
                              ),
                            ),
                            VerticalDivider(thickness: 1),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          widget.onTapSettings();
                        },
                        icon: Icon(Icons.settings),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
