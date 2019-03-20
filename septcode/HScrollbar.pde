class HScrollbar {
  int swidth, sheight;    // width and height of bar
  float xpos, ypos;       // x and y position of bar
  float spos, newspos;    // x position of slider
  float sposMin, sposMax; // max and min values of slider
  int loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean locked;
  float ratio;

  HScrollbar (float xp, float yp, int sw, int sh, int l) {
    swidth = sw;
    sheight = sh;
    int widthtoheight = sw - sh;
    ratio = (float)sw / (float)widthtoheight;
    xpos = xp;
    ypos = yp-sheight/2;
    spos = xpos + swidth/2 - sheight/2;
    newspos = spos;
    sposMin = xpos;
    sposMax = xpos + swidth;
    loose = l;
  }

  void updateScroll() {
    if (overEvent()) {
      over = true;
    } else {
      over = false;
    }
    if (mousePressed && over) {
      locked = true;
    }
    if (!mousePressed) {
      locked = false;
    }
    if (locked) {
      newspos = constrain(mouseX-sheight/2, sposMin, sposMax);
    }
    if (abs(newspos - spos) > 1) {
      spos = spos + (newspos-spos)/loose;
    }
  }

  float constrain(float val, float minv, float maxv) {
    return min(max(val, minv), maxv);
  }

  boolean overEvent() {
    if (mouseX > xpos && mouseX < xpos+swidth &&
       mouseY > ypos && mouseY < ypos+sheight) {
      return true;
    } else {
      return false;
    }
  }

  void displayScroll() {
    noStroke();
    fill(255,80);
    rect(xpos, ypos, swidth, sheight);
    fill(0,255,0,80);
    rect(xpos,ypos,spos-xbar,sheight);
    if (over || locked) {
      fill(0, 255, 0);
    } else {
      fill(0, 255, 0);
     
    }
    rect(spos, ypos, 2, sheight);   
  }
  
  void displayScroll2() {
    noStroke();
    fill(255,80);
    rect(xpos, ypos, swidth, sheight);
    fill(138, 43, 226, 80); 
    rect(xpos,ypos,spos-xbar,sheight);
    if (over || locked) {
      fill(138, 43, 226);
    } else {
      fill(138, 43, 226);
    }
    rect(spos, ypos, 2, sheight);   
  }
  
  void displayScroll3() {
    noStroke();
    fill(255,80);
    rect(xpos, ypos, swidth, sheight);
    fill(252, 193, 83, 120);
    rect(xpos,ypos,spos-xbar,sheight);
    if (over || locked) {
      fill(252, 193, 83);
    } else {
      fill(252, 193, 83);
    }
    rect(spos, ypos, 2, sheight);   
  }
  
    void displayScroll4() {
    noStroke();
    fill(255,80);
    rect(xpos, ypos, swidth, sheight);
    fill(78, 131, 201, 120);
    rect(xpos,ypos,spos-xbar,sheight);
    if (over || locked) {
      fill(78, 131, 201);
    } else {
      fill(78, 131, 201);
    }
    rect(spos, ypos, 2, sheight);   
  }

  float getPos() {
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return spos * ratio;
  }
}
