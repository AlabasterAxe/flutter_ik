import 'dart:math';
import 'dart:ui';

import 'attachable.dart';
import 'bone.dart';

class Anchor extends Attachable {
  Offset loc;
  Bone child;

  Anchor({this.loc});

  void setChild(Bone b) {
    child = b;
  }

  Bone getChild() {
    return child;
  }

  Offset getAttachPoint() {
    return loc;
  }

  List<Offset> getCircleIntersection(
      Offset center1, double radius1, Offset center2, double radius2) {
    List<Offset> intersectionPoints = new List<Offset>();
    if (center1.dy - center2.dy != 0.0) {
      double ySlope = -(center1.dx - center2.dx) / (center1.dy - center2.dy);
      double yIntercept = (pow(center1.dy, 2) -
              pow(center2.dy, 2) +
              pow(center1.dx, 2) -
              pow(center2.dx, 2) -
              (pow(radius1, 2) - pow(radius2, 2))) /
          (2 * (center1.dy - center2.dy));

      double a = 1 + pow(ySlope, 2);
      double b =
          2 * yIntercept * ySlope - 2 * center1.dx - 2 * ySlope * center1.dy;
      double c = pow(center1.dx, 2) +
          pow(center1.dy, 2) -
          2 * center1.dy * yIntercept -
          pow(radius1, 2) +
          pow(yIntercept, 2);

      double discriminant = pow(b, 2) - 4 * a * c;
      if (discriminant < 0) {
        // They do not intersect!
        return intersectionPoints;
      }

      double intersectionX1 = (-b + sqrt(discriminant)) / (2 * a);
      double intersectionY1 = ySlope * intersectionX1 + yIntercept;
      intersectionPoints.add(new Offset(intersectionX1, intersectionY1));
      if (discriminant > 0) {
        // There are two intersection points.
        double intersectionX2 = (-b - sqrt(discriminant)) / (2 * a);
        double intersectionY2 = ySlope * intersectionX2 + yIntercept;

        intersectionPoints.add(new Offset(intersectionX2, intersectionY2));
        double thing = sqrt(discriminant);
        //print(thing);
      }
    } else {
      double xSlope = -(center1.dy - center2.dy) / (center1.dx - center2.dx);
      double xIntercept = (pow(center1.dx, 2) -
              pow(center2.dx, 2) +
              pow(center1.dy, 2) -
              pow(center2.dy, 2) -
              (pow(radius2, 2) - pow(radius1, 2))) /
          (2 * (center1.dx - center2.dx));

      double a = 1 + pow(xSlope, 2);
      double b =
          2 * xIntercept * xSlope - 2 * center1.dy - 2 * xSlope * center1.dx;
      double c = pow(center1.dy, 2) +
          pow(center1.dx, 2) -
          2 * center1.dx * xIntercept -
          pow(radius2, 2) +
          pow(xIntercept, 2);

      double discriminant = pow(b, 2) - 4 * a * c;
      if (discriminant < 0) {
        // They do not intersect!
        return intersectionPoints;
      }

      double intersectionY1 = (-b + sqrt(discriminant)) / (2 * a);
      double intersectionX1 = xSlope * intersectionY1 + xIntercept;
      intersectionPoints.add(new Offset(intersectionX1, intersectionY1));
      if (discriminant > 0) {
        // There are two intersection points.
        double intersectionY2 = (-b - sqrt(discriminant)) / (2 * a);
        double intersectionX2 = xSlope * intersectionY2 + xIntercept;

        intersectionPoints.add(new Offset(intersectionX2, intersectionY2));
        double thing = sqrt(discriminant);
        //print(thing);
      }
    }
    return intersectionPoints;
  }

  void solve(Offset target) {
    // TODO: Generalize to more than two bones;
    Bone bone1 = child; //<>//
    Bone bone2 = bone1.getChild();

    List<Offset> jointPoints =
        getCircleIntersection(loc, bone1.len, target, bone2.len);

    if (jointPoints.length < 1) {
      double newAngle = (target - loc).direction;
      bone1.setAngle(newAngle);
      bone2.setAngle(newAngle);
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

    //double targetDistance = dist(aLoc.dx, aLoc.dy, target.dx, target.dy);
    double firstAngle =
        atan2(closestPoint.dy - loc.dy, closestPoint.dx - loc.dx);

    bone1.setAngle(firstAngle);

    double secondAngle =
        atan2(target.dy - closestPoint.dy, target.dx - closestPoint.dx);

    bone2.setAngle(secondAngle);
  }
}
