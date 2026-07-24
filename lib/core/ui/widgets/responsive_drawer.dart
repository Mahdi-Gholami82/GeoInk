import 'package:flutter/material.dart';

class ResponsiveDrawerController {
  _ResponsiveDrawerState? state;

  void open() {
    assert(state != null);
    state!._openDrawer();
  }

  void close() {
    assert(state != null);
    state!._closeDrawer();
  }

  void toggle() {
    assert(state != null);
    state!._toggleDrawer();
  }
}

class ResponsiveDrawer extends StatefulWidget {
  ResponsiveDrawer({
    this.width,
    this.shape,
    ResponsiveDrawerController? controller,
    required this.drawer,
    required this.body,
  }) : controller = controller ?? ResponsiveDrawerController() {}

  final ResponsiveDrawerController controller;
  final Widget drawer;
  final Widget body;
  final double? width;
  final ShapeBorder? shape;
  static const double _kWidth = 304.0;

  @override
  State<ResponsiveDrawer> createState() => _ResponsiveDrawerState();
}

class _ResponsiveDrawerState extends State<ResponsiveDrawer> {
  double? width;
  late bool needsDesktopDrawer;
  bool isDrawerOpen = false;
  late DrawerController drawerController;

  final GlobalKey<DrawerControllerState> _drawerKey =
      GlobalKey<DrawerControllerState>();

  DrawerControllerState _getDrawerState() {
    var state = _drawerKey.currentState;
    assert(state != null, "Drawer controller not attached");
    return state!;
  }

  @override
  void initState() {
    super.initState();
    widget.controller.state = this;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _drawerOpenCallback(bool isOpened) {
    isDrawerOpen = isOpened;
  }

  void _openDrawer() {
    _getDrawerState().open();
  }

  void _closeDrawer() {
    _getDrawerState().close();
  }

  void _toggleDrawer() {
    var drawerState = _getDrawerState();
    if (isDrawerOpen) {
      drawerState.close();
    } else {
      drawerState.open();
    }
  }

  @override
  Widget build(BuildContext context) {
    width =
        widget.width ??
        DrawerTheme.of(context).width ??
        ResponsiveDrawer._kWidth;
    needsDesktopDrawer = width! * 100 / MediaQuery.of(context).size.width <= 40;
    drawerController = DrawerController(
      key: _drawerKey,
      isDrawerOpen: isDrawerOpen,
      drawerCallback: _drawerOpenCallback,
      alignment: DrawerAlignment.start,
      child: Drawer(width: width, shape: widget.shape, child: widget.drawer),
    );

    return needsDesktopDrawer
        ? Row(
            children: [
              drawerController,
              Expanded(child: widget.body),
            ],
          )
        : Stack(children: [widget.body, drawerController]);
  }
}
