import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'ik/bone.dart';
import 'ik/anchor.dart';

const double jointRadius = 10;

class ArmPainter extends CustomPainter {
  final Anchor anchor;
  ArmPainter(this.anchor);

  @override
  void paint(Canvas canvas, Size size) {
    Paint blackFill = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    Paint blackStroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    canvas.drawCircle(anchor.loc, jointRadius, blackFill);

    Bone child = anchor.child;
    while (child != null) {
      canvas.drawCircle(child.getAttachPoint(), jointRadius, blackFill);
      canvas.drawLine(child.getLoc(), child.getAttachPoint(), blackStroke);
      child = child.child;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Arm extends StatelessWidget {
  final Anchor anchor;
  const Arm({Key key, this.anchor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ArmPainter(anchor),
    );
  }
}
