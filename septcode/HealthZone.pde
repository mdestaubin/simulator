class HealthZone {
  PVector loc;
  boolean isTemporary;
  float r;
  float catchmentRadius;
  float magSickRate = 1.8;
  float healProb;
  float healProb2;
  float healProbability;
  float healProbability2;

  HealthZone(float x, float y, boolean t) { 
    loc = new PVector(x, y);
    isTemporary = t;
  }

  void drawCenter() {

    if (isTemporary) {
      drawHealthZone2();
    } else {
      drawHealthZone();
    }
    healthZonePer();
  }

  void drawHealthZone() {

    r = constrain(map(healProbability, 0, 0.8, 10, 40), 10,40);
    catchmentRadius = 100;

    stroke(0,255,0);
    strokeWeight(1);
    //noStroke();
    fill(0, 255, 0, 120);
    ellipse( loc.x, loc.y, r, r);
    noStroke();
    fill(255);
    rectMode(CENTER);
    rect( loc.x, loc.y, 8, 2);
    rect( loc.x, loc.y, 2, 8);
    fill(255, 25);
    stroke(255,50);
    strokeWeight(1);
    ellipse(loc.x, loc.y, catchmentRadius, catchmentRadius);
  }   

  void drawHealthZone2 () {

    r = constrain(map(healProbability2, 0, 0.8, 10, 30), 10, 30);
    catchmentRadius = 70;

    stroke(0, 255, 255);
    strokeWeight(1);
    fill(0, 255, 255, 120);
    ellipse( loc.x, loc.y, r, r);
    fill(255);
    rectMode(CENTER);
    rect( loc.x, loc.y, 8, 3);
    rect( loc.x, loc.y, 3, 8);
    fill(255, 25);
    stroke(255,50);
    strokeWeight(1);
    ellipse(loc.x, loc.y, catchmentRadius, catchmentRadius);
  }  

  void healthZonePer() {
    float xValue  = hs1.getPos();
    float xValue2 = hs2.getPos();
    float aidFactor  = map(xValue,xbar+95, xbar + 305, 0,2);
   // float aidFactor2 = map(xValue2,xbar+95, xbar + 305,0,2);
    float aidFactor2 = 1.5;
    int numTemp = 0;
    int numExist = 0;

      int catchmentPop = 0;
      int sickPop = 0;
      for (MultiTargetFinder a : cars) {
        float d = loc.dist(a.loc);
        if (d < catchmentRadius/2 ) {
          catchmentPop += 1;
          if (a.sick) sickPop += 1;
        }
      }
      
  for ( HealthZone h : healthZones)
    {
     if(h.isTemporary == true){
      numTemp += 1; 
     }
     if(h.isTemporary == false){
      numExist += 1; 
     }
    }
  
    if(numTemp < 2){ 
      numTemp = 1;
      }
      
      if(numExist < 2){ 
      numExist = 1;
      }
   
      float existBudget = 1-((100 / numExist) * 0.01);
      float tempBudget  = 1-((100 / numTemp) * 0.01);
      float perSick     = (float) sickPop * magSickRate / 100 * 100;
      
      healProb  = map(perSick, 0, 100, 0, 2);
      healProb2 = map(perSick, 0, 100, 0, 1);
      healProbability   = ((1 - healProb)  * aidFactor)/2;
      healProbability2  = ((1 - healProb2) * aidFactor2)/2 ;
      int healPercent   = constrain(round(healProbability * 100), 30, 100);
      int healPercent2  = constrain(round(healProbability2 * 100), 30, 100);

      fill(255);
      textSize(14);
      textAlign(CENTER);
      if (isTemporary == false) {
        text(healPercent + " %", loc.x+5, loc.y - 28 );
      }
      if (isTemporary == true) {
        text(healPercent2 + " %", loc.x+5, loc.y - 19 );
      }
      noStroke();
    }
  }
  
