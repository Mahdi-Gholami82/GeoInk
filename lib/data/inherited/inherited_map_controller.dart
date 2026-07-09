import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class InheritedMapController extends InheritedWidget {
  InheritedMapController({required super.child, required this.mapController});
  final MapController mapController;

  static InheritedMapController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedMapController>();
  }

  static InheritedMapController of(BuildContext context) {
    final InheritedMapController? result = maybeOf(context);
    assert(result != null, 'No InheritedMapController found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
