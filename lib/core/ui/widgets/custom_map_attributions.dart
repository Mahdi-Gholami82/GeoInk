import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

enum CustomMapAttributionsAlignment {
  bottomLeft,
  bottomRight;

  Alignment get widgetAlignment => switch (this) {
    CustomMapAttributionsAlignment.bottomLeft => Alignment.bottomLeft,
    CustomMapAttributionsAlignment.bottomRight => Alignment.bottomRight,
  };
}

class CustomMapAttributionsController {
  void Function()? _open;
  void Function()? _close;
  bool isOpen = false;

  void open() {
    assert(_open != null, "controller not attached on open");
    _open!();
  }

  void close() {
    assert(_close != null, "controller not attached on close");
    _close!();
  }

  void toggle() {
    if (isOpen) {
      close();
    } else {
      open();
    }
  }
}

class CustomMapAttributions extends StatefulWidget {
  CustomMapAttributions({
    super.key,
    this.buttonHeight = 24,
    this.width = 400,
    this.alignment = CustomMapAttributionsAlignment.bottomLeft,
    this.initialyOpened = true,
    required this.controller,
    required this.children,
    this.duration = const Duration(milliseconds: 200),
  });
  final double buttonHeight;
  final double width;
  final CustomMapAttributionsController controller;
  final CustomMapAttributionsAlignment alignment;
  final List<Widget> children;
  final bool initialyOpened;
  final Duration duration;
  @override
  State<CustomMapAttributions> createState() => _CustomMapAttributionsState();
}

class _CustomMapAttributionsState extends State<CustomMapAttributions> {
  StreamSubscription<MapEvent>? mapEvent;
  bool get isOpen => widget.controller.isOpen;
  set isOpen(bool value) => widget.controller.isOpen = value;
  bool initialized = false;

  @override
  void initState() {
    super.initState();
    isOpen = widget.initialyOpened;
    if (isOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(Duration(seconds: 3)).then((_) {
          widget.controller.close();
        });
      });
    }
    void subscribeToMap() {
      mapEvent = MapController.of(context).mapEventStream.listen((e) async {
        setState(() => widget.controller.close());
        await mapEvent?.cancel();
      });
    }

    widget.controller._open = () {
      setState(() {
        isOpen = true;
        subscribeToMap();
      });
    };
    widget.controller._close = () {
      setState(() {
        isOpen = false;
      });
    };
  }

  @override
  void dispose() {
    unawaited(mapEvent?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var button = AnimatedSwitcher(
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: isOpen
          ? IconButton(
              key: ValueKey("close"),
              onPressed: widget.controller.close,
              icon: Icon(
                Icons.cancel_outlined,
                color:
                    Theme.of(context).textTheme.titleSmall?.color ??
                    Colors.black,
                size: widget.buttonHeight,
              ),
            )
          : IconButton(
              key: ValueKey("open"),
              onPressed: widget.controller.open,
              tooltip: "Attributions",
              icon: Icon(
                Icons.info_outlined,
                color: Colors.black,
                size: widget.buttonHeight,
              ),
            ),
      duration: Duration(milliseconds: 200),
    );
    return SafeArea(
      child: Align(
        alignment: widget.alignment.widgetAlignment,
        child: Stack(
          alignment: widget.alignment.widgetAlignment,
          children: [
            AnimatedScale(
              alignment: widget.alignment.widgetAlignment,
              scale: isOpen ? 1 : 0.01,
              duration: widget.duration,
              child: AnimatedOpacity(
                opacity: isOpen ? 1 : 0,
                duration: widget.duration,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border.all(width: 0, style: BorderStyle.none),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: widget.width,
                  padding: const EdgeInsets.all(8),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...widget.children,
                        SizedBox(height: widget.buttonHeight + 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            button,
          ],
        ),
      ),
    );
  }
}
