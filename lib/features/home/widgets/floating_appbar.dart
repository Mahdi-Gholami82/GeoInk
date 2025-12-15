import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:mapify/features/home/widgets/ink_well_text_button.dart';

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
            child: FittedBox(
              fit: BoxFit.contain,
              child: Row(
                spacing: widget.height / 8,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: DefaultSelectionStyle.defaultColor,
                          spreadRadius: 3,
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.menu),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                      style: IconButton.styleFrom(
                        minimumSize: Size(widget.height, widget.height),
                        shape: CircleBorder(),
                        backgroundColor:
                            widget.backgroundColor ??
                            Theme.of(context).colorScheme.surface,
                      ),
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
                    child: Material(
                      child: Row(
                        spacing: 3,
                        children: [
                          InkWellTextButton(title: "Map Tools", onTap: () {}),
                          InkWellTextButton(title: "Free Style", onTap: () {}),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: IconButton(
                              onPressed: () {
                                widget.onTapSettings();
                              },
                              icon: Icon(Icons.settings),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
