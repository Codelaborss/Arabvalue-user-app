import 'package:flutter/material.dart';

class ScallopedEdgeClipper extends CustomClipper<Path> {
  final double cutoutY;
  ScallopedEdgeClipper({this.cutoutY = 186});

  @override
  Path getClip(Size size) {
    Path path = Path();
    double cornerRadius = 16;
    double cutoutRadius = 10;

    path.moveTo(cornerRadius, 0);
    // Top Edge
    path.lineTo(size.width - cornerRadius, 0);
    path.arcToPoint(Offset(size.width, cornerRadius),
        radius: Radius.circular(cornerRadius));

    // Right Side with Cutout
    path.lineTo(size.width, cutoutY - cutoutRadius);
    path.arcToPoint(
      Offset(size.width, cutoutY + cutoutRadius),
      radius: Radius.circular(cutoutRadius),
      clockwise: false,
    );
    path.lineTo(size.width, size.height - cornerRadius);
    path.arcToPoint(Offset(size.width - cornerRadius, size.height),
        radius: Radius.circular(cornerRadius));

    // Bottom Edge
    path.lineTo(cornerRadius, size.height);
    path.arcToPoint(Offset(0, size.height - cornerRadius),
        radius: Radius.circular(cornerRadius));

    // Left Side with Cutout
    path.lineTo(0, cutoutY + cutoutRadius);
    path.arcToPoint(
      Offset(0, cutoutY - cutoutRadius),
      radius: Radius.circular(cutoutRadius),
      clockwise: false,
    );
    path.lineTo(0, cornerRadius);
    path.arcToPoint(Offset(cornerRadius, 0),
        radius: Radius.circular(cornerRadius));

    path.close();
    return path;
  }

  @override
  bool shouldReclip(ScallopedEdgeClipper oldClipper) =>
      cutoutY != oldClipper.cutoutY;
}
