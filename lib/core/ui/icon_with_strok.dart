import 'package:flutter/material.dart';

class IconStrokPainter extends CustomPainter {
  const IconStrokPainter(
    this.icon, {
    required this.color,
    this.strokeWidth = 4,
  });
  final Icon icon;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final iconData = icon.icon!;
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          fontFamily: iconData.fontFamily,
          package: iconData.fontPackage,
          fontSize: 40,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..color = color,
        ),
      ),
      textDirection: TextDirection.rtl,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset.zero);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class IconWithStrok extends StatelessWidget {
  IconWithStrok(
    IconData icon, {
    required this.color,
    double? size,
    this.strokWidth = 4,
    required this.strokColor,
  }) : this.icon = Icon(icon, size: size, color: color) {}
  final Icon icon;
  final Color color;
  final Color strokColor;
  final double strokWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: IconStrokPainter(
        icon,
        color: strokColor,
        strokeWidth: strokWidth,
      ),
      child: icon,
    );
  }
}
