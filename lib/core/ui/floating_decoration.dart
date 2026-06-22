import 'package:geoink/core/ui/floating_shadow.dart';
import 'package:flutter/material.dart';

BoxDecoration makeFloatingDecoration(BuildContext context) {
 return BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [FloatingShadow()],
      );
}