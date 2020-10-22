
Anchor a;

void setup() {
  size(400, 400);
  a = new Anchor(0, 0);
  Bone b = new Bone(random(70, 100), a);
  a.setChild(b);
  Bone b2 = new Bone(random(70, 100), b);
  b.setChild(b2);
}

ArrayList<PVector> getCircleIntersection(PVector center1, float radius1, PVector center2, float radius2) {
  ArrayList<PVector> intersectionPoints = new ArrayList<PVector>();
  if (center1.y - center2.y != 0.0) {
    float ySlope = -(center1.x - center2.x)/(center1.y - center2.y);
    float yIntercept = (pow(center1.y,2) - pow(center2.y,2) + pow(center1.x,2) - pow(center2.x,2) - (pow(radius1,2) - pow(radius2,2)))/(2 * (center1.y - center2.y));
  
    float a = 1 + pow(ySlope,2);
    float b = 2*yIntercept*ySlope - 2*center1.x - 2*ySlope*center1.y;
    float c = pow(center1.x,2) + pow(center1.y,2) - 2*center1.y * yIntercept - pow(radius1, 2) + pow(yIntercept, 2);
  
    float discriminant = pow(b,2) - 4*a*c; 
    if (discriminant < 0) {
      // They do not intersect!
      return intersectionPoints;
    }
  
    float intersectionX1 = (-b + sqrt(discriminant))/(2*a);
    float intersectionY1 = ySlope * intersectionX1 + yIntercept;
    intersectionPoints.add(new PVector(intersectionX1, intersectionY1));
    if(discriminant > 0) {
      // There are two intersection points.
      float intersectionX2 = (-b - sqrt(discriminant))/(2*a);
      float intersectionY2 = ySlope * intersectionX2 + yIntercept;
    
      intersectionPoints.add(new PVector(intersectionX2, intersectionY2));
      float thing = sqrt(discriminant);
      //print(thing);
    }
  } else {
    float xSlope = -(center1.y - center2.y)/(center1.x - center2.x);
    float xIntercept = (pow(center1.x,2) - pow(center2.x,2) + pow(center1.y,2) - pow(center2.y,2) - (pow(radius2,2) - pow(radius1,2)))/(2 * (center1.x - center2.x));
  
    float a = 1 + pow(xSlope,2);
    float b = 2*xIntercept*xSlope - 2*center1.y - 2*xSlope*center1.x;
    float c = pow(center1.y,2) + pow(center1.x,2) - 2*center1.x * xIntercept - pow(radius2, 2) + pow(xIntercept, 2);
  
    float discriminant = pow(b,2) - 4*a*c; 
    if (discriminant < 0) {
      // They do not intersect!
      return intersectionPoints;
    }
  
    float intersectionY1 = (-b + sqrt(discriminant))/(2*a);
    float intersectionX1 = xSlope * intersectionY1 + xIntercept;
    intersectionPoints.add(new PVector(intersectionX1, intersectionY1));
    if(discriminant > 0) {
      // There are two intersection points.
      float intersectionY2 = (-b - sqrt(discriminant))/(2*a);
      float intersectionX2 = xSlope * intersectionY2 + xIntercept;
    
      intersectionPoints.add(new PVector(intersectionX2, intersectionY2));
      float thing = sqrt(discriminant);
      //print(thing);
    }
  }
  return intersectionPoints;
}

void mouseMoved() {
  print("X: ");
  print(mouseX);
  print(" Y: ");
  println(mouseY);
}

void solve(PVector target) {
  
  // TODO: Generalize to more than two bones;
  Bone bone1 = a.getChild(); //<>//
  Bone bone2 = bone1.getChild();
  
  ArrayList<PVector> jointPoints = getCircleIntersection(a.getAttachPoint(), bone1.len, target, bone2.len);
  
  if (jointPoints.size() < 1) {
    float newAngle = atan2(target.y - a.getAttachPoint().y, target.x - a.getAttachPoint().x);
    bone1.setAngle(newAngle);
    bone2.setAngle(newAngle);
    return;
  }
  
  PVector closestPoint = jointPoints.get(0);
  float minDist = dist(closestPoint.x, closestPoint.y, bone1.getAttachPoint().x, bone1.getAttachPoint().y);
  for (PVector point : jointPoints) {
    float currDist = dist(point.x, point.y, bone1.getAttachPoint().x, bone1.getAttachPoint().y);
    if (minDist > currDist) {
      minDist = currDist;
      closestPoint = point;
    }
  }  
  
  // what angle of bone two starting from target and being length of bone two,
  // will have an endpoint bone1 length away from a
  PVector aLoc = a.getAttachPoint();
  
  //float targetDistance = dist(aLoc.x, aLoc.y, target.x, target.y);
  float firstAngle = atan2(closestPoint.y - aLoc.y, closestPoint.x - aLoc.x);
  
  bone1.setAngle(firstAngle);
  
  float secondAngle = atan2(target.y - closestPoint.y, target.x - closestPoint.x);
  
  bone2.setAngle(secondAngle);
  
}

void draw() {
  background(100);
  translate(width / 2, height / 2);
  solve(new PVector(mouseX - width/2, mouseY - height / 2));
  a.draw();
}