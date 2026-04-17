import 'package:flutter/material.dart';

class VoucherDividerClipper extends CustomClipper<Path> {
  final double cutoutX;
  final double cutoutRadius;
  final double borderRadius;

  VoucherDividerClipper({
    required this.cutoutX,
    this.cutoutRadius = 10,
    this.borderRadius = 12,
  });

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(borderRadius, 0);

    // Top edge with cutout
    path.lineTo(cutoutX - cutoutRadius, 0);
    path.arcToPoint(
      Offset(cutoutX + cutoutRadius, 0),
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
    path.lineTo(cutoutX + cutoutRadius, size.height);
    path.arcToPoint(
      Offset(cutoutX - cutoutRadius, size.height),
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
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
