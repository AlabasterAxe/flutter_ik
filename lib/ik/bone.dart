import 'dart:math';
import 'dart:ui';

import 'attachable.dart';

class Bone implements Attachable {
  double len;

  // in radians
  double angle;

  Attachable parent;
  Bone child;

  Bone(double len, Attachable parent) {
    this.len = len;
    this.angle = Random().nextDouble() * pi * 2;
    this.parent = parent;
  }

  Offset getLoc() {
    return parent.getAttachPoint();
  }

  Offset getAttachPoint() {
    return getLoc() + Offset.fromDirection(angle, len);
  }
}
