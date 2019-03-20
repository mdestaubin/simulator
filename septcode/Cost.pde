import java.util.Stack;

class Cost {

  //You do not need to know how this class works in order to use it.
  //The functions in the main program are all you need to operate it.
  //But you are welcome to peek through it if you like.

  Kernel   k;
  Lattice cs;
  public int  EMPTY_ROAD =   -99;
  public int    NON_ROAD =     0;
  int    roadCode =     1;
  boolean moreOptimal =  false;

  public PVector targetLocation;     

  //---------------------------------------------------//
  Cost( Lattice l, int _roadCode )
  {
    roadCode = _roadCode;
    cs = new Lattice( l.w, l.h );
    k = new Kernel();
    k.isNotTorus();

    for ( int x = 0; x < cs.w; x += 1 ) {
      for ( int y = 0; y < cs.h; y += 1 ) {

        int val = (int) l.get(x, y);

        if ( val == roadCode ) {
          cs.put(x, y, EMPTY_ROAD);
        } else {
          cs.put(x, y, NON_ROAD);
        }
      }
    }

    calculateCost( new PVector(width/2, height/2)  );
  };

  //---------------------------------------------------//
  Cost( PImage pi, int _roadCode )
  {
    roadCode = _roadCode;
    cs = new Lattice(pi.width, pi.height);
    k = new Kernel();
    k.isNotTorus();

    for ( int x = 0; x < cs.w; x += 1 ) {
      for ( int y = 0; y < cs.h; y += 1 ) {

        int val = (int)red( pi.get(x, y) );

        if ( val == roadCode ) {
          cs.put(x, y, EMPTY_ROAD);
        } else {
          cs.put(x, y, NON_ROAD);
        }
      }
    }

    calculateCost( new PVector(width/2, height/2)  );
  };

  //---------------------------------------------------//
  Cost( ASCgrid asc, int _roadCode )
  {
    roadCode = _roadCode;
    cs = new Lattice( asc.w, asc.h );
    k = new Kernel();
    k.isNotTorus();

    for ( int x = 0; x < cs.w; x++ ) {
      for ( int y = 0; y < cs.h; y++ ) {

        int val = (int) asc.get(x, y);

        if ( val == roadCode ) {
          cs.put(x, y, EMPTY_ROAD);
        } else {
          cs.put(x, y, NON_ROAD);
        }
      }
    }

    calculateCost( new PVector(width/2, height/2)  );
  };  

  // Find if we can optimize this bit/what is this doing?
  //---------------------------------------------------//  
  void initCostSurface()
  {
    for ( int x = 0; x < cs.w; x += 1 ) {
      for ( int y = 0; y < cs.h; y += 1 ) {

        int val = (int) cs.get(x, y);

        if ( val != NON_ROAD ) {
          cs.put(x, y, EMPTY_ROAD);
        }
      }
    }
  }; 

  //---------------------------------------------------//  
  Lattice getCostSurface()
  {
    return cs;
  };

  //---------------------------------------------------//  
  Lattice getCostSurface( PVector target )
  {
    targetLocation = target;
    calculateCost( target );
    return cs;
  };

  //---------------------------------------------------//  
  void calculateCost( PVector target )
  {
    if ( moreOptimal ) { 
      println("* * * * CALCULATING COST SURFACE USING MULTIPLE PASSES * * * * ");
      println("This takes significantly more time to process");
      println("Set moreOptimal == false to reduce processing time");
      println("if less efficient routes are not an issue");
    };

    initCostSurface();
    int valAtTarget = (int) cs.get( (int) target.x, (int) target.y );

    if ( valAtTarget == EMPTY_ROAD ) {
      target.z = 1;
      costIterate( target );
    } else {

      PVector tt = findClosest(target);
      tt.z = 1;
      costIterate( tt );
    }

    // find maximum /////////////////////////////////////
    int maxVal = -1;
    for ( int x = 0; x < cs.w; x += 1 ) {
      for ( int y = 0; y < cs.h; y += 1 ) {
        maxVal = (int)max( maxVal, cs.get(x, y) );
      }
    }

    for ( int x = 0; x < cs.w; x += 1 ) {
      for ( int y = 0; y < cs.h; y += 1 ) {
        if ( cs.get(x, y) == NON_ROAD ) 
          cs.put(x, y, maxVal);
      }
    }
    NON_ROAD = maxVal;
    //////////////////////////////////////////////////////
  };

  //---------------------------------------------------//  
  void costIterate( PVector t )
  {
    Stack<PVector> cellList= new Stack<PVector>(); 

    cellList.push(t);

    while ( !cellList.isEmpty() )
    {
      PVector   tmp = cellList.pop();
      int currDepth = (int)tmp.z; 
      cs.put((int)tmp.x, (int)tmp.y, currDepth );


      ArrayList<PVector> pv = k.getPVList( cs, tmp );

      for ( PVector p : pv )
      {
        if ( (int)p.z == EMPTY_ROAD )
        {     
          cellList.push( new PVector( p.x, p.y, currDepth + 1 ) );
        } else if ( moreOptimal && (int)p.z != NON_ROAD && (int)p.z != EMPTY_ROAD && (int)p.z > currDepth+1  )
        {
          //cs.put((int)tmp.x, (int)tmp.y, currDepth+1 );
          cellList.push( new PVector( p.x, p.y, currDepth + 1 ) );
        }
      }
    }

    cellList.clear();
  }


  //---------------------------------------------------//  
  PVector findClosest( PVector tIn )
  {
    float minDist = 99999;
    int argMinX = 0;
    int argMinY = 0;

    for ( int x = 0; x < cs.w; x++ ) {
      for ( int y = 0; y < cs.h; y++ ) {


        if ( cs.get(x, y) == EMPTY_ROAD ) { 
          float thisDist = dist( tIn.x, tIn.y, x, y );  
          if ( thisDist < minDist )
          {
            minDist = thisDist;
            argMinX = x;
            argMinY = y;
          }
        }
      }
    }

    return new PVector( argMinX, argMinY );
  };
};
