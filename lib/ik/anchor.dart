import 'dart:math';
import 'dart:ui';

import 'package:flutter/animation.dart';

import 'attachable.dart';
import 'bone.dart';

const double RADIANS_PER_SECOND = 2;

const double jointRadius = 10.0;
const double anchorRadius = 15.0;
const double strokeWidth = 5.0;

class Anchor extends Attachable {
  Offset loc;
  Bone child;
  AnimationController controller;
  double firstAngleTarget;
  double secondAngleTarget;
  Duration lastProgressCall = Duration();

  Anchor({this.loc, this.controller}) {
    if (this.controller != null) {
      this.controller.addListener(_progressTowardsTarget);
    }
  }

  _progressTowardsTarget() {
    Bone bone1 = child; //<>//
    Bone bone2 = bone1.getChild();

    double elapsedSeconds =
        (controller.lastElapsedDuration - lastProgressCall).inMilliseconds /
            1000;

    if (firstAngleTarget != null && bone1.angle != firstAngleTarget) {
      double trueTarget = firstAngleTarget;
      double diff = (bone1.angle - firstAngleTarget);
      if (diff.abs() > pi) {
        trueTarget = firstAngleTarget + pi * 2 * diff.sign;
      }

      double velocity = min(
          RADIANS_PER_SECOND * ((trueTarget - bone1.angle) / pi),
          RADIANS_PER_SECOND);
      if (trueTarget > bone1.angle) {
        double proposedBoneAngle = bone1.angle + velocity * elapsedSeconds;
        if (proposedBoneAngle > trueTarget) {
          bone1.setAngle(trueTarget);
        } else {
          bone1.setAngle(proposedBoneAngle);
        }
      } else {
        double proposedBoneAngle = bone1.angle - velocity * elapsedSeconds;
        if (proposedBoneAngle < trueTarget) {
          bone1.setAngle(trueTarget);
        } else {
          bone1.setAngle(proposedBoneAngle);
        }
      }
    }

    if (secondAngleTarget != null && bone2.angle != secondAngleTarget) {
      double trueTarget = secondAngleTarget;
      double diff = (bone2.angle - secondAngleTarget);
      if (diff.abs() > pi) {
        trueTarget = secondAngleTarget + pi * 2 * diff.sign;
      }

      if (trueTarget > bone2.angle) {
        double proposedBoneAngle =
            bone2.angle + RADIANS_PER_SECOND * elapsedSeconds;
        if (proposedBoneAngle > trueTarget) {
          bone2.setAngle(trueTarget);
        } else {
          bone2.setAngle(proposedBoneAngle);
        }
      } else {
        double proposedBoneAngle =
            bone2.angle - RADIANS_PER_SECOND * elapsedSeconds;
        if (proposedBoneAngle < trueTarget) {
          bone2.setAngle(trueTarget);
        } else {
          bone2.setAngle(proposedBoneAngle);
        }
      }
    }

    lastProgressCall = controller.lastElapsedDuration;
  }

  void setChild(Bone b) {
    child = b;
  }

  Bone getChild() {
    return child;
  }

  Offset getAttachPoint() {
    return loc;
  }

  double lawOfCosines(double a, double b, double c) {
    return acos((pow(a, 2) + pow(b, 2) - pow(c, 2)) / (2 * a * b));
  }

  List<Offset> getCircleIntersection(
      Offset center1, double radius1, Offset center2, double radius2) {
    Offset distanceOffset = (center2 - center1);

    // if the distance between their centers are greater than the sum of
    // their radii, they must not intersect.
    if (distanceOffset.distance > radius1 + radius2) {
      return [];
    }

    double angle1 = lawOfCosines(radius2, distanceOffset.distance, radius1);

    if (angle1 == 0) {
      return [
        center1 + Offset.fromDirection(distanceOffset.direction, radius1)
      ];
    }

    Offset iPoint1 = center1 +
        Offset.fromDirection(distanceOffset.direction + angle1, radius1);
    Offset iPoint2 = center1 +
        Offset.fromDirection(distanceOffset.direction - angle1, radius1);
    return [iPoint1, iPoint2];
  }

  void solve(Offset target) {
    // TODO: Generalize to more than two bones;
    Bone bone1 = child; //<>//
    Bone bone2 = bone1.getChild();

    List<Offset> jointPoints =
        getCircleIntersection(loc, bone1.len, target, bone2.len);

    if (jointPoints.length < 1) {
      double newAngle = (target - loc).direction;
      if (controller != null) {
        firstAngleTarget = newAngle;
        secondAngleTarget = newAngle;
      } else {
        bone1.setAngle(newAngle);
        bone2.setAngle(newAngle);
      }
      return;
    }

    Offset closestPoint = jointPoints[0];
    double minDist = (closestPoint - bone1.getAttachPoint()).distanceSquared;
    for (Offset point in jointPoints) {
      double currDist = (point - bone1.getAttachPoint()).distance;
      if (minDist > currDist) {
        minDist = currDist;
        closestPoint = point;
      }
    }

    // what angle of bone two starting from target and being length of bone two,
    // will have an endpoint bone1 length away from a

    double firstAngle = (closestPoint - loc).direction;

    double secondAngle = (target - closestPoint).direction;

    if (controller != null) {
      firstAngleTarget = firstAngle;
      secondAngleTarget = secondAngle;
    } else {
      bone1.setAngle(firstAngle);
      bone2.setAngle(secondAngle);
    }
  }

  double _distToSegment(Offset center, Offset start, Offset end) {
    var segmentLength = (start - end).distanceSquared;
    if (segmentLength == 0) {
      return (center - start).distance;
    }
    var t = ((center.dx - start.dx) * (end.dx - start.dx) +
            (center.dy - start.dy) * (end.dy - start.dy)) /
        segmentLength;
    t = max(0, min(1, t));
    return (center -
            Offset(start.dx + t * (end.dx - start.dx),
                start.dy + t * (end.dy - start.dy)))
        .distance;
  }

  Offset _circleLineIntersection(
    Offset center,
    double radius,
    Offset start,
    Offset end,
    double lineWidth,
  ) {
    var dist = _distToSegment(center, start, end);
    if (dist < radius + lineWidth / 2) {
      return Offset.fromDirection((start - end).direction + pi / 2, dist / 4);
    }
    return null;
  }

  Offset _doBoneIntersection(Offset center, double radius, Bone bone) {
    Offset result = _circleLineIntersection(
        center, radius, bone.getLoc(), bone.getAttachPoint(), strokeWidth);
    if (result != null) {
      return result;
    }

    Offset distance = (center - bone.getAttachPoint());
    if (distance.distance < radius + jointRadius) {
      return Offset.fromDirection(
          distance.direction, distance.distance - (radius + jointRadius));
    }
    return null;
  }

  Offset overlaps(Offset center, double radius) {
    Offset distance = (center - loc);
    if (distance.distance < radius + anchorRadius) {
      return Offset.fromDirection(
          distance.direction, distance.distance - (radius + anchorRadius));
    }

    Offset result = _doBoneIntersection(center, radius, child);

    if (result != null) {
      return result;
    }

    result = _doBoneIntersection(center, radius, child.child);

    if (result != null) {
      return result;
    }

    return null;
  }
}
