import 'dart:ui';

import 'package:flutter/cupertino.dart';

class ViewTransformation {
  Rect a;
  Rect b;

  double xm;

  double ym;

  ViewTransformation({this.a, this.b}) {
    double aXSpan = this.a.right - this.a.left;
    double bXSpan = this.b.right - this.b.left;

    xm = aXSpan / bXSpan;

    double aYSpan = this.a.top - this.a.bottom;
    double bYSpan = this.b.top - this.b.bottom;

    ym = aYSpan / bYSpan;
  }

  Offset aToB(Offset point) {
    Offset shifted = point - Offset(a.left, a.bottom);
    Offset scaled = Offset(shifted.dx / xm, shifted.dy / ym);
    return scaled + Offset(b.left, b.bottom);
  }

  Offset bToA(Offset point) {
    Offset shifted = point - Offset(b.left, b.bottom);
    Offset scaled = Offset(shifted.dx * xm, shifted.dy * ym);
    return scaled + Offset(a.left, a.bottom);
  }
}
