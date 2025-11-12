import 'package:flutter/material.dart';

class FloatingAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Widget drawer;
  final Function(String searchText) onSearch;
  final Color backgroundColor;
  final double borderRadius;
  const FloatingAppBar({
    super.key,
    required this.drawer,
    required this.onSearch,
    this.backgroundColor = Colors.white,
    this.borderRadius = 6,
  });

  @override
  State<FloatingAppBar> createState() => _FloatingAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);
}

class _FloatingAppBarState extends State<FloatingAppBar> {
  bool menuTapped = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: 15,
          left: 15,
          right: 15,
          child: SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 13),
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                color: widget.backgroundColor,
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
                  IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                  VerticalDivider(),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: TextField(
                        onChanged: (searchText) {
                          widget.onSearch(searchText);
                        },
                        style: TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: "Search...",
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
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
