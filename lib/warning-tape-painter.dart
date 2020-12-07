import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class WarningTapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.yellow);
  }

  @override
  bool shouldRepaint(WarningTapePainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(WarningTapePainter oldDelegate) => false;
}
