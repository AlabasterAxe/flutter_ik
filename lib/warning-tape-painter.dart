import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class WarningTapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.yellow);

    canvas.rotate(pi / 4);
    for (int i = 0; i < 20; i++) {
      canvas.drawRect(
          Rect.fromLTWH(0, size.height / 20 * i, size.width, size.height / 40),
          Paint()..color = Colors.black);
    }
  }

  @override
  bool shouldRepaint(WarningTapePainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(WarningTapePainter oldDelegate) => false;
}
