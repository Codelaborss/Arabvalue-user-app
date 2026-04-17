import 'package:flutter/material.dart';

class HorizontalDashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double startXOffset;
  HorizontalDashedLinePainter({required this.color, this.strokeWidth = 4.5, this.dashWidth = 5, this.dashSpace = 3, this.startXOffset = 10});

  @override
  void paint(Canvas canvas, Size size) {
    double startX = startXOffset;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    while (startX < size.width - startXOffset) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
