import 'package:flutter/material.dart';
import 'package:sixam_mart/util/dimensions.dart';

class VoucherDividerBorderPainter extends CustomPainter {
  final Color? color; // Keep for backward compatibility
  final List<Color>? colors; // New gradient support
  final List<double>? stops;
  final double cutoutX;
  final double cutoutRadius;
  final double strokeWidth;
  final double borderRadius;
  final bool isLtr;

  VoucherDividerBorderPainter({
    this.color,
    this.colors,
    this.stops,
    required this.cutoutX,
    this.cutoutRadius = 10,
    this.strokeWidth = 5.0,
    this.borderRadius = Dimensions.radiusLarge,
    this.isLtr = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double actualCutoutX = isLtr ? cutoutX : size.width - cutoutX;
    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Use gradient if colors provided, otherwise use single color
    if (colors != null && colors!.isNotEmpty) {
      paint.shader = LinearGradient(
        colors: colors!,
        stops: stops,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    } else {
      paint.color = color ?? Colors.grey;
    }

    Path path = Path();
    path.moveTo(borderRadius, 0);

    // Top edge with cutout
    path.lineTo(actualCutoutX - cutoutRadius, 0);
    path.arcToPoint(
      Offset(actualCutoutX + cutoutRadius, 0),
      radius: Radius.circular(cutoutRadius),
      clockwise: false,
    );
    path.lineTo(size.width - borderRadius, 0);

    // Top right corner
    path.arcToPoint(
      Offset(size.width, borderRadius),
      radius: Radius.circular(borderRadius),
    );

    // Right edge
    path.lineTo(size.width, size.height - borderRadius);

    // Bottom right corner
    path.arcToPoint(
      Offset(size.width - borderRadius, size.height),
      radius: Radius.circular(borderRadius),
    );

    // Bottom edge with cutout
    path.lineTo(actualCutoutX + cutoutRadius, size.height);
    path.arcToPoint(
      Offset(actualCutoutX - cutoutRadius, size.height),
      radius: Radius.circular(cutoutRadius),
      clockwise: false,
    );
    path.lineTo(borderRadius, size.height);

    // Bottom left corner
    path.arcToPoint(
      Offset(0, size.height - borderRadius),
      radius: Radius.circular(borderRadius),
    );

    // Left edge
    path.lineTo(0, borderRadius);

    // Top left corner
    path.arcToPoint(
      Offset(borderRadius, 0),
      radius: Radius.circular(borderRadius),
    );

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
