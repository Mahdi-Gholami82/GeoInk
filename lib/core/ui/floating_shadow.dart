import 'package:flutter/material.dart';

class FloatingShadow extends BoxShadow {
  const FloatingShadow({
    super.offset = const Offset(0, 6),
    super.blurRadius = 8,
    super.spreadRadius = 2,
    super.color = Colors.black26,
  });
}
