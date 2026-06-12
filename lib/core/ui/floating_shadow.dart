import 'package:flutter/material.dart';

class FloatingShadow extends BoxShadow {
  FloatingShadow({Offset offset = Offset.zero})
    : super(
        offset: offset,
        color: DefaultSelectionStyle.defaultColor,
        spreadRadius: 2,
        blurRadius: 3,
      ) {}
}
