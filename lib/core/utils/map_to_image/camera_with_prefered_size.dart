import 'dart:ui';

import 'package:flutter_map/flutter_map.dart';

class CameraWithPreferedSize extends MapCamera {
  CameraWithPreferedSize({
    required this.preferedSize,
    required MapOptions options,
  }) : super.initialCamera(options);

  Size preferedSize;

  @override
  Size get size {
    return preferedSize;
  }
}
