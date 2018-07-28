import 'package:flutter/material.dart';
import 'dart:math';

class NmbrzLogo extends StatelessWidget {
  static const aspectRatio = 21.0 / 32.0;

  NmbrzLogo({this.height = 28.0, this.strokeWidth = 6.0})
      : width = height * aspectRatio;

  final double width;
  final double height;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LogoPainter(strokeWidth),
      size: Size(width, height),
    );
  }
}

class _LogoPainter extends CustomPainter {
  _LogoPainter(this.strokeWidth);

  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();
    var yOffset = tan(pi / 4) * size.width / 2.0;
    path.moveTo(0.0, yOffset);
    path.lineTo(size.width / 2.0, 0.0);
    path.lineTo(size.width / 2.0, size.height);
    path.lineTo(size.width, size.height - yOffset);

    var paint = Paint();
    paint.color = Colors.white;
    paint.strokeWidth = strokeWidth;
    paint.style = PaintingStyle.stroke;
    paint.strokeCap = StrokeCap.round;
    paint.strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
