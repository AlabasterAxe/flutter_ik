import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'ik/bone.dart';
import 'ik/anchor.dart';

const double jointRadius = 10;

class ArmPainter extends CustomPainter {
  final Anchor anchor;
  final double scaleFactor;
  ArmPainter(this.anchor, this.scaleFactor);

  @override
  void paint(Canvas canvas, Size size) {
    Paint blueFill = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    Paint blackFill = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    Paint blackStroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = (jointRadius / 2) * scaleFactor;

    Bone child = anchor.child;
    while (child != null) {
      canvas.drawCircle(child.getAttachPoint() * scaleFactor,
          jointRadius * scaleFactor, blackFill);
      canvas.drawLine(child.getLoc() * scaleFactor,
          child.getAttachPoint() * scaleFactor, blackStroke);
      child = child.child;
    }

    canvas.drawCircle(
        anchor.loc * scaleFactor, jointRadius * scaleFactor * 1.5, blueFill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Arm extends StatelessWidget {
  final Anchor anchor;
  final double scaleFactor;
  const Arm({Key key, this.anchor, this.scaleFactor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ArmPainter(anchor, scaleFactor),
    );
  }
}
