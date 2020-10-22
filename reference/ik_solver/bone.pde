class Bone implements Attachable {
  float len;
  float angle;
  Attachable parent;
  Bone child;
  
  Bone(float len, Attachable parent) {
    this.len = len;
    this.angle = random(0, TWO_PI);
    this.parent = parent;
  }
  
  PVector getLoc() {
    return parent.getAttachPoint();
  }
  
  PVector getAttachPoint() {
    float endX = getLoc().x + len * cos(angle);
    float endY = getLoc().y + len * sin(angle);
    return new PVector(endX, endY);
  }
  
  void setChild(Bone child) {
    this.child = child;
  }
  
  void setAngle(float newAngle) {
    this.angle = newAngle;
  }
  
  Bone getChild() {
    return child;
  }
  
  void draw() {
    fill(0,100,0);
    ellipse(getAttachPoint().x, getAttachPoint().y, 17, 17);
    stroke(0);
    strokeWeight(5);
    line(getLoc().x, getLoc().y, getAttachPoint().x, getAttachPoint().y);
    if(child != null) {
      child.draw();
    }
  }
}