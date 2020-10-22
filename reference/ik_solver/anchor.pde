class Anchor implements Attachable {
  
  PVector loc;
  Bone child;
  
  Anchor(float x, float y) {
    loc = new PVector(x, y);
  }
  
  void setChild(Bone b) {
    child = b;
  }
  
  Bone getChild() {
    return child;
  }
  
  PVector getAttachPoint() {
    return loc;
  }
  
  void draw() {
    fill(255,0,0);
    ellipse(loc.x, loc.y, 17, 17);
    child.draw();
  }
}