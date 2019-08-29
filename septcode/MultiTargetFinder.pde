class MultiTargetFinder extends Agent {

  // MultiTargetFinder has all of the functions of PathFinder with a few new tricks
  // It can read in an ArrayList of costsurfaces (i.e. paths to multiple targets )
  // it spends a certain amount of time at a target before moving on to the next one
  // in a continuous loop...

  int currentTarget = 0;       // this holds the number of the current cost surface it is reading
  int timeCounter   = 0;       // this counter is used to calculate how long it has been at a target, once there  
  int timerCutOff   = 90;      // sit at each target roughly 3 seconds
  
  //---------------------------------------------------//
  MultiTargetFinder( float x, float y )
  {
    super(x, y);
  };
  
//---------------------------------------------------//
/*
void pickTarget( ArrayList<Cost> ccsIn )
  {
      //println("Current target: " + currentTarget);
      float minDist = MAX_FLOAT;
      int   argMin  = 0;
      
      boolean isTemporarySeen = false;
      boolean targetIsTemporary = false;  
      if (target != null) return;
      else target = null;
      
      for( int i = 0; i < ccsIn.size(); i++ )
      {
        
      for (HealthZone z : healthZones){
            if (isTemporarySeen && !z.isTemporary) continue;
            if (z.isTemporary) isTemporarySeen = true;
            
          PVector targetLoc = ccsIn.get(i).targetLocation;
          float   thisDistance = dist( loc.x, loc.y, targetLoc.x, targetLoc.y);
           if( thisDistance <= minDist || (!targetIsTemporary && z.isTemporary)) 
           {
              minDist = thisDistance;
              argMin  = i;
              targetIsTemporary = z.isTemporary;
          }
       }
  }
  
  currentTarget = argMin; 
  
  } */

void pickTarget( ArrayList<Cost> ccsIn )
  {
      //println("Current target: " + currentTarget);
      float minDist = MAX_FLOAT;
      int   argMin  = 0;
      int argMinTemp = 0;
      
      boolean isTemporarySeen = false;
      boolean targetIsTemporary = false;  
      if (target != null) return;
      else target = null;
      
      for( int i = 0; i < ccsIn.size(); i++ )
      {
        
      for (HealthZone z : healthZones){
           // if (isTemporarySeen && !z.isTemporary) continue;
            if (z.isTemporary) isTemporarySeen = true;
            
          PVector targetLoc = ccsIn.get(i).targetLocation;
          float   thisDistance = dist( loc.x, loc.y, targetLoc.x, targetLoc.y);
           if( thisDistance <= minDist && z.isTemporary) 
           {  
             isTemporarySeen = true;
              minDist = thisDistance;
              argMinTemp  = i;
              targetIsTemporary = z.isTemporary;
          }
          else if (thisDistance <= minDist && !z.isTemporary){
              minDist = thisDistance;
              argMin  = i;
              targetIsTemporary = z.isTemporary;
          
          }
       }
  }
  if (isTemporarySeen)
      currentTarget = argMinTemp; 
   else {
      currentTarget = argMin;
   }
   
  
  }
 

  //---------------------------------------------------//
  void findRoad(  ArrayList<Lattice> costSurfaces ) 
  {
    // passes the first lattice from the ArrayList to PathFider.findRoad()
    // uses the max() function to get the NON_ROAD value, since NON_ROAD pixels
    // have the maximum "cost" in the cost surface

    findRoad( costSurfaces.get(currentTarget), (int) costSurfaces.get(currentTarget).max() );
  };

  //---------------------------------------------------//
  void update( ArrayList<Lattice> costSurfaces )
  {
    // currentTarget holds the number of the current cost surface / target path
    // the agent is working on. This is passed to the minimize and check target functions
    // as usual 
    minimize( costSurfaces.get( currentTarget )  );
    checkTarget( costSurfaces.get( currentTarget )  );

    // this is the new function that helps an agent step through
    // the various cost surfaces / target paths
    
  //countTimeAtTarget( costSurfaces );
    
  };
  
    void countTimeAtTarget( ArrayList<Lattice> csrf )
  {
    // once an agent gets to a target, it stays there for "timerCutOff" number of frames
    // it then updates the cost surface it is following and goes to the next target
    // it cycles through all of the target cost surfaces in the arrayList

    if ( atTarget == true ) // if it is at its current target, start counting
    {                      // on every frame
      timeCounter += 1;
    }
         
    if ( timeCounter >= timerCutOff )
    {
      // if the counter goes above a threshold (in this case, about 3 seconds)
      // it is time to move on, so... 
      timeCounter = 0;       // reset counter;
      atTarget = true;   // reset target flag
      
      // cycle through to the next target cost surface.
      // we use the % to make sure the index never gets bigger
      // than the size of the arrayList 

    //  currentTarget = (currentTarget+1) % csrf.size();
      // in the update, currentTarget will now index the next cost surface
    }
  };
  
  //---------------------------------------------------//
  
  void updateHealth() {

    //dead percentage 
   for ( HealthZone s : healthZones) {  
    if ( frameCount%framesPerDay == 0 && sick == true)
      {
      days -=1;
      if (days == 0 ) { 

        
        if (atTarget & !s.isTemporary) {
          if (num < constrain(s.healProbability, .3, 1)) {
            getHealed();  
          }
          else {
          dead = true;
        }
       }

        if (atTarget & s.isTemporary) {
          if (num < constrain(s.healProbability2, .3, 1)) {
            getHealed();
          }
          else {
          dead = true;
        }
        }
        
        if (!atTarget){
        if (num < surviveNoTreatment) {
          getHealed();
          surviveNo = true;
        } 
         else {
          dead = true;
        }
      
        }
      }
    }
  }
 }

};
