import 'package:flutter/material.dart';

class FloatingShadow extends BoxShadow {
  const FloatingShadow({
    Offset offset = const Offset(0, 6),
    double blurRadius = 8,
    double spreadRadius = 2,
    Color color = Colors.black26,
  }) : super(
         offset: offset,
         blurRadius: blurRadius,
         spreadRadius: spreadRadius,
         color: color,
       );
}
