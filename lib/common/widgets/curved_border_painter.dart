import 'package:flutter/material.dart';

class CurvedBorderPainter extends CustomPainter {
  final List<Color> colors;
  final List<double>? stops;
  final double strokeWidth;
  final double cutoutY;
  final double cutoutRadius;

  CurvedBorderPainter({
    required this.colors,
    this.stops,
    this.strokeWidth = 3.5,
    this.cutoutY = 186,
    this.cutoutRadius = 10,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
              colors: colors,
              stops: stops,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight)
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double halfStroke = strokeWidth / 2;
    double cornerRadius = 16;

    Path path = Path();
    path.moveTo(cornerRadius, halfStroke);

    // Top Edge
    path.lineTo(size.width - cornerRadius, halfStroke);
    path.arcToPoint(Offset(size.width - halfStroke, cornerRadius),
        radius: Radius.circular(cornerRadius - halfStroke));

    // Right Side with Cutout
    path.lineTo(size.width - halfStroke, cutoutY - cutoutRadius);
    path.arcToPoint(
      Offset(size.width - halfStroke, cutoutY + cutoutRadius),
      radius: Radius.circular(cutoutRadius),
      clockwise: false,
    );
    path.lineTo(size.width - halfStroke, size.height - cornerRadius);
    path.arcToPoint(Offset(size.width - cornerRadius, size.height - halfStroke),
        radius: Radius.circular(cornerRadius - halfStroke));

    // Bottom Edge
    path.lineTo(cornerRadius, size.height - halfStroke);
    path.arcToPoint(Offset(halfStroke, size.height - cornerRadius),
        radius: Radius.circular(cornerRadius - halfStroke));

    // Left Side with Cutout
    path.lineTo(halfStroke, cutoutY + cutoutRadius);
    path.arcToPoint(
      Offset(halfStroke, cutoutY - cutoutRadius),
      radius: Radius.circular(cutoutRadius),
      clockwise: false,
    );
    path.lineTo(halfStroke, cornerRadius);
    path.arcToPoint(Offset(cornerRadius, halfStroke),
        radius: Radius.circular(cornerRadius - halfStroke));

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CurvedBorderPainter oldDelegate) =>
      cutoutY != oldDelegate.cutoutY ||
      colors != oldDelegate.colors ||
      stops != oldDelegate.stops;
}
