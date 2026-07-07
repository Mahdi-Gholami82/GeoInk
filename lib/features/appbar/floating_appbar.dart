import 'package:geoink/core/ui/floating_shadow.dart';
import 'package:flutter/material.dart';
import 'package:geoink/features/appbar/widgets/free_style_dropdown_menu.dart';
import 'package:geoink/features/appbar/widgets/map_dropdown_menu.dart';

class FloatingAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Widget drawer;
  final Function onTapSettings;
  final Color? backgroundColor;
  final double borderRadius;
  final double height;
  const FloatingAppBar({
    super.key,
    required this.drawer,
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
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: AlignmentGeometry.topStart,
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsetsGeometry.only(
              top: 15,
              left: 15,
              right: 15,
            ),
            child: Row(
              spacing: widget.height / 8,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [FloatingShadow()],
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
                    boxShadow: [FloatingShadow()],
                  ),
                  child: Material(
                    child: Row(
                      spacing: 3,
                      children: [
                        MapDropdownMenu(),
                        FreeStyleDropdownMenu(),
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
    );
  }
}
