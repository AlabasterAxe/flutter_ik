import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'ik/bone.dart';
import 'ik/anchor.dart';
import 'view-transformation.dart';

const double jointRadius = 30;

class ArmPainter extends CustomPainter {
  final Anchor anchor;
  final ViewTransformation vt;
  ArmPainter(this.anchor, this.vt);

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
      ..strokeWidth = (jointRadius / 2) / vt.xm;

    Bone child = anchor.child;
    while (child != null) {
      canvas.drawCircle(
          vt.forward(child.getAttachPoint()), jointRadius / vt.xm, blackFill);
      canvas.drawLine(vt.forward(child.getLoc()),
          vt.forward(child.getAttachPoint()), blackStroke);
      child = child.child;
    }

    canvas.drawCircle(vt.forward(anchor.loc), jointRadius / vt.xm, blueFill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Arm extends StatelessWidget {
  final Anchor anchor;
  final ViewTransformation vt;
  const Arm({Key key, this.anchor, this.vt}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ArmPainter(anchor, vt),
    );
  }
}
