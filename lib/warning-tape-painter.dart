import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const int numLines = 10;

class WarningTapePainter extends CustomPainter {
  final double multiplier;
  const WarningTapePainter(this.multiplier);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.yellow);

    canvas.rotate(pi / 4);
    for (int i = 0; i < (numLines * multiplier) * 2; i++) {
      canvas.drawRect(
          Rect.fromLTWH(
              0,
              size.height / (numLines * multiplier) * i - size.width,
              size.width * 100,
              size.height / (numLines * 2 * multiplier)),
          Paint()..color = Colors.black);
    }
  }

  @override
  bool shouldRepaint(WarningTapePainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(WarningTapePainter oldDelegate) => false;
}

class WarningTapeClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width, size.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => true;
}
