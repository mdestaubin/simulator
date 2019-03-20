import java.util.Iterator;

class Agent {

  PVector loc;
  PVector oLoc;
  PVector vel;
  PVector Accel;
  PVector target;
  int     LUhome;
  float   mag;
  int     kernelSize = 700; 
  float   slope;
  float   slopeVel = 1;
  float   maxVel = 2;
  float   minVel = 0 ;

  float num = random(0, 1);
  float treatmentProb;
  float surviveNoTreatment = 0.25;

  Kernel         k;            // each agent has a kernel
  boolean foundRoad = false;   // once the agent is on the road->true
  boolean  atTarget = false;   // once the agent is on the road pixel that is closest to target->true
  int         speed = 15;       

  /////////////////////////////////////////// merge variables
  boolean dead      = false;
  boolean sick      = false;
  boolean healed    = false;
  boolean infected  = false;
  boolean healthy   = true;
  boolean seek      = false;
  boolean noSeek    = false;
  boolean surviveNo = false;
  boolean hospHeal  = false;
  boolean seekNoHeal = false;
  boolean seekHeal = false;
  boolean noSeekNoHeal = false;
  boolean treatment = false;
  boolean treatment2 = false;
  boolean returned  = false;
  boolean deceased  = false;
  boolean plusNoSeek = false;
  boolean infectiousBody = true;

  int rad;
  int days = 0;
  float t = frameCount;
  float incubationPeriod = random(32, 300);
  int burialTimePeriod = 1;
  int burialTime = 0;
  int burialTime2 = 0;
  
  float offset = random(-10,10);

  ////////////////////////////////////////////////////////////

  Agent()
  {
    loc = new PVector( random(width), random(height) );
    vel = new PVector( random(-0.1, 0.1), random(-0.1, 0.1) );
    mag = 0.1;
  }

  Agent( float x, float y)
  {
    loc  = new PVector(x,y);
    oLoc = new PVector(x,y);
    vel  = new PVector(random(-0.1, 0.1), random(-0.1, 0.1) );
    mag  = 0.1;

    k = new Kernel();
    k.setNeighborhoodDistance(speed);
    k.isNotTorus();
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------------//   

  void findRoad( Lattice l, int non_road )
  {
    k.setNeighborhoodDistance(40); // just very big
    // to find the nearest road point

    float minDist = width*2; // just make it big to start
    int   argMinX = 0;
    int   argMinY = 0;

    // 1. opens a very big kernel around the agent's location
    // 2. stores neighbors in an ArrayList of PVectors
    // 3. looks through all neighbors and finds the closest one
    //    that has a pixel with the road value in it
    // 4. updates its location to that road pixel
    // 5. sets the boolean that says it has found the road
    // 6. resizes the kernel to a normal range

    ArrayList<PVector> pv = k.getPVList(l, loc);
    for ( PVector p : pv )
    {
      if ( p.z > 0  && p.z != non_road ) { // finds a road pixel
        float thisDist = dist( loc.x, loc.y, p.x, p.y );

        if ( thisDist < minDist ) { // checks to see if it is the closest so far enountered
          minDist = thisDist;
          argMinX = (int)p.x;
          argMinY = (int)p.y;
        }
      }
    }//end for()

    foundRoad = true;

    loc = new PVector( argMinX, argMinY);
    k.setNeighborhoodDistance(speed);
  };

  void update( Lattice l )
  {
    minimize(l);
    checkTarget(l);
  };

  void minimize( Lattice l )
  {
    // look at all of the neighbors in the current kernel 
    // (of size, 'speed' above)
    // find the pixel with the smallest value and move there
    // this is how the cost surface is structured. road pixel
    // values increase as they move away from the target.
    // non-road pixels have the largest value in the lattice
    // therefore, the location on the road that gets an agent
    // closer to the target is always the smallest valued one.
    // ... so move there.

    loc = k.getMin(l, loc);
  };

  void checkTarget( Lattice l )
  {
    // the closest road pixel to the target always
    // has a value of 1. if the road pixel that the
    // agent is currently sitting on has the value of 1
    // it has arrived at its destination
    // set 'atTarget' == true

    PVector test = k.getMin(l, loc);
    if ( test.z == 1){
      atTarget = true;
    }
  };    

  //---------------------------------------------------------------//   

  void setHomeClass( int LUclass )
  {
    LUhome = LUclass;
    //println(LUclass);
  }

  void findTarget( ArrayList<HealthZone> healthZones )
  {         
    float minDistance = MAX_FLOAT;
    boolean isTemporarySeen = false;
    boolean targetIsTemporary = false;
    if (target != null) return;
    else target = null;

    for (HealthZone z : healthZones) 
    {
      if (isTemporarySeen && !z.isTemporary) continue;
      if (z.isTemporary) isTemporarySeen = true;
      if (!z.isTemporary && z.healProbability <= .35) continue;
      if (z.isTemporary && z.healProbability2 <= .35) continue;
      float distance = loc.dist(z.loc);
      if (distance < minDistance || (!targetIsTemporary && z.isTemporary)) 
      {
        minDistance = distance;
        //float offset = random(-5,5);
        //PVector off = new PVector(offset,offset);
        target = z.loc;
        //targetIsTemporary = z.isTemporary;
      }
    }
  }

  void update( ArrayList<HealthZone> healthZones, float slope )
  {    

    slopeVel = map(slope, 0, 45, 0.5, 0); // find max slope val

    updateVelocityMagnitude();

    float xValue3  = hs3.getPos();;
    float pubAwarness = map(xValue3,  xbar+95, xbar + 305, 0, 1);


    for ( HealthZone h : healthZones){
      float ETUdistance = dist(h.loc.x,h.loc.y,loc.x,loc.y);
      if (h.isTemporary && ETUdistance < 130){
        
        if (pubAwarness < .25 ){
      pubAwarness = pubAwarness*3;
        }
        else if (pubAwarness >= .25 && pubAwarness < .45 ){
      pubAwarness = pubAwarness*2;
        }
        else if (pubAwarness >= .45){
      pubAwarness = pubAwarness*1.5;
        }     
      }
    }
      
    treatmentProb = pubAwarness;

    if ( target != null)
    {
      updateVelocityDirection();
    }

    if (infected)
    { 
      t += 1;
     
      if (t >= incubationPeriod) {    
        getSick(minDays, maxDays);
      }
      
      if(frameCount % 100 == 0 && LUhome != 1){
      vel.x *= -3;
      vel.y *= -3;
      }
    }
    
    if (deceased) {
    if (frameCount%16 == 0) {
      burialTime += 1;
    } 
      if (burialTime < burialTimePeriod){
        infectiousBody = true;
        //println("true");
      }  
      
      else if (burialTime >= burialTimePeriod){
        infectiousBody = false;
        
        //println("false");
      }
      
    }
    
    
    //if (deceased) {
    //if (frameCount % 16 == 0) {
      
    //  burialTime += 1;
     
    //  if (burialTime <= burialTimePeriod){
    //    infectiousBody = true;
    //  }  
    //  else if (burialTime > burialTimePeriod){
    //    infectiousBody = false;
    //  }  
    // }
    //}
    
    if (sick)
    {
      if (num < treatmentProb) {     
        //findTarget(healthZones);
        seek = true; 
      } 
      
      else {
        noSeek = true;
      }
    }

    if (healthy && frameCount % 100 == 0 && LUhome != 1) {
      vel.x *= -3;
      vel.y *= -3;
    }

    if ( frameCount%framesPerDay == 0 && sick == true)
    {
      days -=1;
     
      if (days == 0 ) { 
        
        if (treatment) {
          if (num < constrain(healProbability, 30, 100)) {
            getHealed();
          }
        }

        if (treatment2) {
          if (num < constrain(healProbability2, 30, 100)) {
            getHealed();
          }
        }

        if (num < surviveNoTreatment) {
          getHealed();
          surviveNo = true;
        } 
        
        else {
          dead = true;
        }
      }
    }

    loc.add(vel);
    bounce();
    stats();
  }

  void stats() {

    if (seek && healed) {
      seekHeal = true;
    }

    if (seek && dead) {
      seekNoHeal = true;
    }

    if (noSeek && dead) {
      noSeekNoHeal = true;
    }
  }

  void updateVelocityDirection()
  {
    float originalMag = vel.mag();
    vel = new PVector(target.x - loc.x, target.y - loc.y);
    vel.setMag(originalMag);
  }

  void updateVelocityMagnitude()
  {
    float newMag = maxVel * slopeVel*slopeVel; // change this to be what you want
    newMag = constrain(newMag, minVel, maxVel);
    vel.setMag(newMag);
  }

  void getInfected()
  {
    if (healed == false) {
      healthy = false;  
      infected = true;
      t = 0;
    }
  }

  void getSick(int minDay, int maxDay)
  {
    sick = true;
    infected = false;
    healthy = false;  
    days = (int)random(minDay, maxDay);
  }

  void getHealed()
  {
    if (sick) {
      sick = false;
      seek = true;
      noSeek   = false;
      healed = true;
      target = null;
      dead = false;
      treatment = false;
    }
  }
  
  void getReturned(){
    if(healthy){
    returned = true;
    sick     = false;
    healed   = false;
    dead     = false;
    seek     = false;
    noSeek   = false;
  }
  }
  
    void getDeceased(){
    if(healthy){
    deceased = true;
    returned = false;
    sick     = false;
    healed   = false;
    dead     = false;
    seek     = false;
    noSeek   = false;
  }
  
 }

  void getTreatment() {
    if (sick) {
      treatment = true;
      vel = new PVector(0, 0);
    }
  }

  void getTreatment2() {
    if (sick) {
      treatment2 = true;
      vel = new PVector(0, 0);
    }
  }

  void getDead()
  {
    if (sick) 
    {
      sick = false;
      dead = true;
    }
    if (seek) {
      seek = true;
    }
    if (noSeek){
     noSeek = true;
    }
  }

  void drawAgent()
  {
    
    if (sick) {
      fill(255);
      rad = 3;
      speed = 10;
    } 

    if (infected) {
      fill(255);
      rad = 3;
      speed = 5;
    } 

    if (healed) {
      fill(255); 
      rad = 3;
    }
    
    if (returned) {
      fill(255); 
      rad = 4; 
    }
    
    if (deceased) {
      fill(255);
      rad = 4;
    }

    if (healthy) {
      fill(255,90); 
      rad = 2;
    }
    
    //agents by pop density
    if(LUhome == 1){
      rad = 4;
      fill(255,0,0);
      speed = 1;
    }
    
    if(LUhome == 2){
      rad = 2;
      fill(0,0,255);
    }
    
    if(LUhome == 3){
      rad = 2;
      fill(0,255,0);
      speed = 20;
    }
    
    if(LUhome == 4){
      rad = 2;
      fill(255,0,255);
    }

    noStroke();
    ellipseMode( CENTER );
    ellipse( loc.x+offset, loc.y+offset, rad, rad );

    strokeWeight(2);
    if ( sick ) {
      noFill();
      stroke(255, 48, 36,170);
      ellipse(loc.x+offset, loc.y+offset, 10, 10);
    }
    
    if(returned){
      noStroke();
      fill(3, 191, 103);
      ellipse(loc.x+offset, loc.y+offset, 5, 5);
    }
    
    if(deceased){
      
      noStroke();
      fill(138, 43, 226);

//      if (frameCount%framesPerDay == 0) {
//      burialTime2 += 1;
//    } 
//      if (burialTime2 < burialTimePeriod){
        
        ellipse(loc.x+offset, loc.y+offset, 5, 5);
        noFill();
        stroke(138, 43, 226);
      //}  
      //else if (burialTime2 >= burialTimePeriod){
      //  noFill();
      //  noStroke();
      //}
      
    ellipse(loc.x+offset, loc.y+offset, 20, 20);
      
    }
    
    if(infected) {
      noFill();
      stroke(254, 184, 1,170);
      ellipse(loc.x+offset, loc.y+offset, 10, 10);
    }
  }

  float calcRadians( PVector target )
  {
    float xDiff =  target.x -  loc.x;
    float yDiff = -target.y - -loc.y; // remember positive y on screen is opposite from mathematics

    // doing this in degrees to make it legible
    // SOH CAH TOA , we want TOA. Tan(angle_radians) = opposite/adjacent
    // therefore arctan, or atan(), to find angle
    // need if() statements to acount for all of the obtuse angles (>90_degrees)
    float angle_d = degrees(atan( yDiff / xDiff )); 
    angle_d = (xDiff < 0 ) ? 180+angle_d : (yDiff < 0 ) ? 360+angle_d : angle_d;

    return radians( angle_d );
  }

  void bounce()
  {
    if (loc.x < 0 || loc.x >= width) {
      vel.x *= -1;
    }
    if (loc.y < 0 || loc.y >= height) {
      vel.y *= -1;
    }
  }
}

void removeSick()
{
  Iterator iter = population.iterator();
  Agent tempAgent;

  while ( iter.hasNext() )
  {    
    tempAgent = (Agent)iter.next();
    if ( tempAgent.sick == true && tempAgent.noSeek == true)
    {
      //numNoSeek += 1;
    }
    
    if ( tempAgent.sick == true && tempAgent.seek == true)
    {
      iter.remove();
     // numSeek += 1;
    }

  }
}

void removeDead()
{
  Iterator iter = population.iterator();
  Agent tempAgent;

  while ( iter.hasNext() )
  {    
    tempAgent = (Agent)iter.next();
    if ( tempAgent.dead == true)
    {
      deadAgent(tempAgent.oLoc.x, tempAgent.oLoc.y);
      noStroke();
      fill(138, 43, 226);
      ellipse( tempAgent.loc.x, tempAgent.loc.y, 35, 35);
      iter.remove();
      totalDeaths  += 1;
    }
  }
}

void removeDeceased()
{
  Iterator iter = popRecord.iterator();
  Agent tempAgent;

  while ( iter.hasNext() )
  {    
    tempAgent = (Agent)iter.next();
    if ( tempAgent.deceased == true && !tempAgent.infectiousBody)
    {
      iter.remove();
    }
  }
}

void removeDeadCar()
{
  Iterator iter = cars.iterator();
  MultiTargetFinder tempCar;

  while ( iter.hasNext() )
  {    
    tempCar = (MultiTargetFinder)iter.next();
      
    if ( tempCar.dead == true)
    {
      deadAgent(tempCar.oLoc.x, tempCar.oLoc.y);
      noStroke();
      fill(138, 43, 226);
      ellipse( tempCar.loc.x, tempCar.loc.y, 35, 35);
      iter.remove();
      totalDeaths  += 1;
      deathsPerDay += 1;
      
      if (tempCar.atTarget){
        numHospNoHeal += 1;
      }
    }
      
      if (tempCar.healed == true)
      { 
      numHealed += 1;  
      //newAgent(tempCar.oLoc.x, tempCar.oLoc.y);  
      noStroke();
      fill(0, 255, 0);
      ellipse( tempCar.loc.x, tempCar.loc.y, 40, 40);
      iter.remove();
      
      if (tempCar.atTarget){
        numHospHeal += 1;
     }  
     
   }

      if(frameCount % 48 == 0){
       deathsPerDay = 0; 
     }
    }

  }
