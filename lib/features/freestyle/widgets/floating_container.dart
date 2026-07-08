import 'package:flutter/material.dart';
import 'package:geoink/core/ui/floating_decoration.dart';

class FloatingContainer extends StatelessWidget {
  FloatingContainer({required this.child}) {}
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: makeFloatingDecoration(context),
      child: child,
    );
  }
}
