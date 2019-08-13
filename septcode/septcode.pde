//  Ebola Outbreak Response Simulator 
//  MDES Risk + Resilience Open Project
//  Michael de St. Aubin

//  Credits to: 
//  GSD 6349 Mapping II : Geosimulation
//  Havard University Graduate School of Design
//  Professor Robert Gerard Pietrusko
//  <rpietrusko@gsd.harvard.edu>
//  (c) Fall 2017 

//===========================================================// Global Variables

// Cost used for determining shortest path.
Cost      cst;                 
int       ROADVALUE = 1;    
ASCgrid   roadASC;
ASCgrid   DE;  
DEswatch  deColors; 
Lattice DElat;
//HZascii
ASCgrid   HZ;
Lattice HZlat;
PrintWriter output;

//input
BufferedReader reader;
String line;

HScrollbar hs1;
HScrollbar hs2;
HScrollbar hs3;
HScrollbar hs4;

// List of target lattices
ArrayList<Lattice> ccs; 
ArrayList<Cost>    ccsIn;

ArrayList<PVector> targets;
ArrayList<HealthZone> healthZones;

ArrayList<Agent> population;
ArrayList<Agent> exposedPop;
ArrayList<MultiTargetFinder> cars; 
ArrayList<Agent> survivor;
ArrayList<Agent> popRecord;

ArrayList<Float> sickHistory;
ArrayList<Float> survivorHistory;
ArrayList<Float> deathHistory;
ArrayList<Float> seekHistory;

PImage topo;
PImage topo2;

boolean recording  = false;
boolean isSetup    = false;
boolean imageFlip  = false;
boolean imageFlip2  = false;
boolean pop        = false;
boolean reset      = false;
boolean popRec     = false;
boolean adjust     = false;
boolean adjust2    = false;
boolean viz        = false;
boolean mouseOverText = false;

//mangina
float initPop                 =  0;
int   populationHome5         =  1;   
float birthProb5              =  0.0075;
int   populationHome4         =  4;   
float birthProb4              =  0.4;
int   populationHome3         =  3;   
float birthProb3              =  0.2;
int   populationHome2         =  2;   
float birthProb2              =  0.05;

//massive pop
//float initPop                 =  0;
//int   populationHome5         =  1;   
//float birthProb5              =  0.039;
//int   populationHome4         =  4;   
//float birthProb4              =  0.95;
//int   populationHome3         =  3;   
//float birthProb3              =  0.4;
//int   populationHome2         =  2;   
//float birthProb2              =  0.130;

//max
//float initPop                 =  0;
//int   populationHome5         =  1;   
//float birthProb5              =  1;
//int   populationHome4         =  4;   
//float birthProb4              =  1;
//int   populationHome3         =  3;   
//float birthProb3              =  1;
//int   populationHome2         =  2;   
//float birthProb2              =  1;



//float birthProbLow                =  0.1;

int dayCounter             = 0;
int framesPerDay           = 16;
int burialTime             = 0;
int minDays                = 2;
int maxDays                = 21;

int   spreadDistance       = 10;
int   deadSpreadDistance   = 18;
float infectionProbability = 0; 
float deadInfectionProbability = 0;
float healProbability      = 0;
float healProbability2     = 0;


int currentPopulationSize  = 0;
int currentHealed          = 0;

float totalDeaths      = 0;
float numHealed        = 0;
float numHospHeal      = 0;
float numHospNoHeal    = 0;
float numIsolationHeal = 0;
float deathsPerDay     = 0;
float vacGlobal        = 0; 
float pubGlobal        = 0;
float burGlobal        = 0;
float caseGlobal       = 0;
float cfrGlobal       = 0;

float xCord  = 0; //<>//
float xCord1 = 0;
float xCord2 = 0;
float yCord  = 930;
float yCord2 = 1075;
int   h      = 0;
float prevX;
float prevYSick;
float seekLine;

int   rectX, rectY; 
int   rectWidth = 15;
int   rectHeight = 15;
color rectColor, baseColor;
color rectHighlight;
color currentColor;
boolean rectOver = false;
boolean info = true;

int yTitle     = 959;
int xStat      = 1335;
int xStat2     = 1435;
int xStat3     = 1525;
int xStat4     = 1635;
int xStat5     = 1685;
int xStat6     = 1840;
int y1         = 985;
int y2         = 1010;
int y3         = 1035;
int y4         = 1060;

int xbar       = 1685;

boolean zone4 = false;

import peasy.*;
import peasy.org.apache.commons.math.*;
import peasy.org.apache.commons.math.geometry.*;

PeasyCam cam;

//===========================================================//  setup

void setup()
{
  size(1920, 1080);
  //fullScreen();
  //cam = new PeasyCam(this, 100);
  //cam.setMinimumDistance(50);
  //cam.setMaximumDistance(500);
  //background(0);
  frameRate(12);
  
  //input
  reader = createReader("DATA/inputfile.csv"); 


  deColors = new DEswatch ();
  //DE = new ASCgrid ("DATA/hz1.asc");
  DE = new ASCgrid ("DATA/newpop5.asc");
  DE.fitToScreen();
  DE.updateImage(deColors.getSwatch());

  DElat = new Lattice(DE.w, DE.h);
  fillLattice( DElat, DE );
  
  //HZascii
  HZ = new ASCgrid ("DATA/hz1.asc");
  HZ.fitToScreen();
  HZlat = new Lattice(HZ.w, HZ.h);
  fillLattice2( HZlat, HZ );

  topo  = loadImage( "DATA/newback.png" );
  topo2  = loadImage( "DATA/newback_nolabel.png" );
  
  output = createWriter("sim_data.csv");
  output.println("Days"+","+"Population Size"+","+"Total Deaths"+","+"Total Cases"+","+"CFR"+","+"Vaccination"+","+"Seek Treatment"+","+"Safe Burials");

  roadASC = new ASCgrid("DATA/newroad.asc");
  roadASC.fitToScreen2();

  hs1 = new HScrollbar(xbar, 845, 200, 11, 14);
  hs2 = new HScrollbar(xbar, 905, 200, 11, 14);
  hs3 = new HScrollbar(xbar, 865, 200, 11, 14);
  hs4 = new HScrollbar(xbar, 885, 200, 11, 14);

  targets =   new ArrayList<PVector>();
  popRecord = new ArrayList<Agent>();
  ccs =       new ArrayList<Lattice>();
  ccsIn =     new ArrayList<Cost>();                       

  // seeking agent
  cars = new ArrayList<MultiTargetFinder>();
  exposedPop = new ArrayList<Agent>();
  createPopulation();
  

  healthZones = new ArrayList<HealthZone>();

  sickHistory =     new ArrayList<Float>();
  survivorHistory = new ArrayList<Float>();
  deathHistory =    new ArrayList<Float>();
  seekHistory =     new ArrayList<Float>();

  rectColor =     color(0);
  rectHighlight = color(255);
  rectX = xStat3-45;
  rectY = yTitle-6;
};

//===========================================================// DRAW LOOP

void draw()
{ 
  clear();
  background(0);

  visualization();
  //dataViz();
  dataRecord();
  simulation();
  //fill(0);
  //noStroke();
  //rectMode(CORNER);
  //rect(0, yCord2-127, 6, -15);
  record();

  if (viz) {
    vizWindow();
  }

  if (frameCount%24 == 0) {
    //println("pop = " x+population.size());
    //println("cars = " +cars.size());
    //println("survivor = " +survivor.size());
    //println("poprecord = " +popRecord.size());
    //println("healthzones = " + healthZones.size());
    //println("targets = " + targets.size());
  }
};


//===========================================================// SIMULATION



void simulation()
{  
  
  

 // csv.createFile("testing.csv"); //<>//
  //noStroke();
  //fill(0);
  //rect(0,0,width,951);
  ////tint(255, 210);
  
   // PrintWriter dataStr;
  //  dataStr = createWriter("SimData.csv");
  
  if (imageFlip == false && imageFlip2 == false) {
    image(HZ.getImage(), 0, 0);
  } else if (imageFlip == true && imageFlip2 == false) {
    image(topo, 0, 0);
  } else if (imageFlip == false && imageFlip2 == true) {
    image(topo2, 0, 0);
  }

  scrollBar();
  //drawTargets();

  //3/11/18 change
  ccsIn = new ArrayList<Cost>();
  for ( PVector t : targets )
  {        
    cst = new Cost( roadASC, ROADVALUE ); 
    cst.moreOptimal = true;
    cst.targetLocation = t;
    ccsIn.add(cst);
  }    

  for ( HealthZone h : healthZones)
  {
    h.drawCenter();
  } 

  for ( Agent a : population )
  {
    if (isSetup)
    {
      float slope = 0.1;
      a.update(healthZones, slope);
    }

    if (pop)
    {
      a.drawAgent();
    }
  }

  for (Agent p : popRecord) {
    if (p.deceased) {
      float slope = 0.1;
      p.drawAgent(); 
      p.update(healthZones, slope);
    }
  }
  
  for (Agent p : exposedPop) {
      float slope = 0.1;
      p.drawAgent(); 
      p.update(healthZones, slope);
      
      //if(p.seek){
      //  removeSick();
      //  newPathFinder(p.loc.x,p.loc.y);
      //}
  }
  
  //for (Agent person : exposedPop){
  //       int HZcode = (int) HZlat.get(person.loc.x, person.loc.y);
  //       fill(255,0,0,255);
  //       text(HZcode, mouseX+5, mouseY-5 );
  //  }

  for ( MultiTargetFinder c : cars ) {
    c.pickTarget(ccsIn);
    //c.findTarget(healthZones);
    c.update(ccs);
    c.drawAgent();
    c.updateHealth();
  }

  infect();

  if ( frameCount % framesPerDay == 0 )
  {
    currentPopulationSize = population.size();
    removeDeadCar();
    removeDead();
    removeDeceased();
    dayCounter += 1;
    println(dayCounter);

    output.println(dayCounter+","+currentPopulationSize+","+totalDeaths+","+caseGlobal+","+cfrGlobal+","+vacGlobal+","+pubGlobal+","+burGlobal);// writing to .csv file
    output.flush();// Write the remaining data to .csv file
    
    //input data from csv
    try {
    line = reader.readLine();
  } catch (IOException e) {
    e.printStackTrace();
    line = null;
  }
  if (line == null) {
    // Stop reading because of an error or file is empty
    noLoop();  
  } else {
    //get input varibles here
    int[] pieces = int(split(line, ','));
    int x = int(pieces[0]);
    int y = int(pieces[1]);
    println("x" + x + "," + "y"+y); 
  }
    
    /*
     float numAffected = numHealed + totalDeaths + numInfected + numSick;
  float caseFatalityRate = totalDeaths/(numHealed+totalDeaths) * 100;

  float percentSick = numSick / popSize * 100;
  float percentInfected = numInfected / popSize * 100;
  float percentHealed = numHealed / popSize * 100;
  float percentDead = totalDeaths / popSize * 100;
  float percentHealthy = numHealthy / popSize * 100;
  float percentAffected = numAffected / popSize * 100;
  float percentIncidence = numAffected / dayCounter;  
  float popDensity = popSize / 22000 * 10;
  //float percentHospHeal = 100-caseFatalityRate;
  float percentIsolationHeal = numIsolationHeal/(numIsolationHeal+numNoSeekNoHeal);
  float percentHospHeal = numHospHeal/(numHospHeal+numHospNoHeal);



float numHospHeal      = 0;
float numHospNoHeal    = 0;
float numIsolationHeal = 0;

  noStroke();
  fill(0);
  rect(1308, yCord, 800, 800);
  fill(255);
  strokeWeight(1);
  stroke(150);
  // line(0, yCord, width, yCord);
  line(1308, yCord, 1308, yCord+150);

  
  text( "HOSPITAL", xStat, y3);
  text(  ":  " + nf(numExZone, 0, 0), xStat2, y3);

  text( "ETU", xStat, y4);
  text( ":  " + nf(numTempZone, 0, 0), xStat2, y4);

  // text( "HEALTHY   ", xStat3, yTitle);
  //text( nf(numHealthy, 0, 0), xStat2, yHealthy);

  text( "INCUBATION  ", xStat3, y1);
  text(  ":  " + nf(numInfected, 0, 0), xStat4, y1);

  text( "SYMPTOMATIC ", xStat3, y2);
  text(  ":  " + nf(numSick, 0, 0), xStat4, y2);

  //text( "IN TREATMENT : ", xStat, yTreatment);
  //text(  nf(numTreatment, 0, 0), xStat2, yTreatment);


  text( "TOTAL AFFECTED", xStat5, y1  );
  text(  ":  " + nf(numAffected, 0, 0), xStat6, y1 );

  text( "PREVALANCE", xStat5, y2);
  text(  ":  " + nf(percentAffected, 0, 3)+"%", xStat6, y2);

  text( "INCIDENCE RATE", xStat5, y3);
  text( ":  " + nf(percentIncidence, 0, 2), xStat6, y3);

  text( "CASE FATALITY RATE", xStat5, y4);
  text(  ":  " + nf(caseFatalityRate, 0, 2)+"%", xStat6, y4); 
   */
   
   
  }

  texter();
  button();
}


void visualization() {

  //rectMode(CORNER);
  //noStroke();
  //fill(0);
  //rect(0, 930, width, 100);

  float popSize = population.size() + totalDeaths;
  float numSick = 0;
  float numInfected = 0;
  // float numHealed = 0;
  float numHealthy = 0;
  float numExZone   = 0;
  float numTempZone = 0;
  //float numIsolationHeal = 0;
  //float numHospHeal = 0;
  //float numHospNoHeal = 0;
  float numNoSeekNoHeal = 0;

  for ( HealthZone h : healthZones) {
    if (h.isTemporary == true) {
      numTempZone += 1;
    }
    if (h.isTemporary == false) {
      numExZone += 1;
    }
  }

  for (Agent person : population) {
    if ( person.sick == true) { 
      numSick += 1;
    } else if (person.infected == true) { 
      numInfected += 1;
    } else if ( person.surviveNo == true) { 
      numIsolationHeal += 1;
    } else if ( person.dead == false && person.healed == false && person.infected == false && person.sick == false) { 
      numHealthy += 1;
    }
  }

  for (MultiTargetFinder person : cars) {
    if ( person.sick == true) { 
      numSick += 1;
    } else if (person.infected == true) { 
      numInfected += 1;
    } else if (  person.noSeekNoHeal == true) { 
      numNoSeekNoHeal += 1;
    }
  }

  for (Agent person : exposedPop) {
    if (person.exposed) { 
      numInfected += 1;
    } else if (person.sick) { 
      numSick += 1;
    }
  }

  //for (Agent person : population) {
  //  if ( person.noSeek == true) { 
  //    numNoSeek += 1;
  //  }
  //}

  //for (MultiTargetFinder person : cars) {
  //  if (  person.seekHeal == true) { 
  //    numHospHeal += 1;
  //  }
  //}

  //for (MultiTargetFinder person : cars) {
  //  if (  person.seekNoHeal == true) { 
  //    numHospNoHeal += 1;
  //  }
  //}
  //------------------------------------------------------------// bottom data bar  

  float xValue3 = hs3.getPos();
  float pub = round(map(xValue3, xbar+95, xbar + 305, 0, 100));
  pubGlobal = pub;
  seekLine = pub;
  
  caseGlobal = numHealed+totalDeaths;

  sickHistory.add(yCord-(numSick*5));
  survivorHistory.add(yCord-((numHealed+totalDeaths)));
  deathHistory.add(yCord-(totalDeaths));
  seekHistory.add(seekLine); 

  //fill(255);
  //rect(0,yCord2-120,15,-15);

  strokeWeight(1);
  fill(150);
  stroke(150);

  for ( int i = 0; i < 120; i += 20) {
    for ( int p = 0; p <= 100; p += 20) {
      stroke(70);
      line(0, yCord2-20-i, 1273, yCord2-20-i);
    }
  }

  for ( int i = 0; i < 1290; i += 67) { 
    for ( int p = 0; p <= 20; p += 1) {
      stroke(40);
      line(0+i, yCord2, 0+i, yCord2-145);
    }
  }

  for ( int i = 1; i < 1290; i += 67) {
    textAlign(CENTER);
    text(round((i/9)/7), 0+i, yCord2-127);
    textAlign(LEFT);
    noStroke();
    text("WEEK", 8, yCord2-127);
  }

  for ( int p = 0; p <= 110; p += 20) {
    textAlign(LEFT);
    if (!adjust && !adjust2) { 
      if (p > 0) { 
        text((p/5)*2, 1280, yCord2-p+5);
      }
    } else if (!adjust && adjust2) {
      text((p/5)*4, 1278, yCord2-p+5);
    }
  }

  fill(0);
  rectMode(CORNER);
  rect(0, yCord2-127, 6, -15);
  fill(150);

  xCord = 0;

  for (int i = 0; i < frameCount; i++) 
  {
    Float ySick   = sickHistory.get(i);

    if (numSick <= 40) { 
      adjust = false; 
      adjust2 = false;
      ySick   = (ySick+yCord)/2;
      //println( "ysick 1 =" + ySick);
    } else if (numSick > 40) {
      // adjust = false; 
      adjust2 = true;
      ySick   = (ySick*1.155 +yCord)/2;
      //println( "ysick 2 =" + ySick);
    }

    //simulation data// 
    strokeWeight(2);
    stroke(255, 48, 36);
    line(xCord, ySick+145, xCord, ySick+145);
    stroke(255, 48, 36, 20);
    line(xCord, ySick+145, xCord, yCord2);
    stroke(3, 191, 103);

    //existing data// 
    strokeWeight(1);

    stroke(200);
    line(67*6, yCord2-0, 67*6, yCord2-120); 

    stroke(70, 70, 70); 
    //if (!adjust && !adjust2) {
    //line(0, yCord2-0, 67*6, yCord2 - 40/2);  
    //line(67*6, yCord2 - 40/2, 67*7, yCord2 - 104/2);
    //line(67*7, yCord2 - 104/2, 67*8, yCord2 - 56/2);
    //line(67*8, yCord2 - 56/2, 67*9, yCord2 - 80/2);
    //line(67*9, yCord2 - 80/2, 67*10, yCord2 - 24/2);
    //line(67*10, yCord2 - 24/2, 67*11, yCord2 - 16/2);
    //line(67*11, yCord2 - 16/2, 67*12, yCord2);
    //line(67*12, yCord2, 67*13, yCord2-56/2);
    //line(67*13, yCord2-56/2, 67*14, yCord2);
    //line(67*14, yCord2, 67*19, yCord2);
    //}

    //else if(adjust && !adjust2){
    //line(0,yCord2 - 40/2, 67, yCord2 - 104/2);
    //line(67,yCord2 - 104/2, 67*2, yCord2 - 56/2);
    //line(67*2, yCord2 - 56/2, 67*3, yCord2 - 80/2);
    //line(67*3, yCord2 - 80/2, 67*4, yCord2 - 24/2);
    //line(67*4, yCord2 - 24/2, 67*5, yCord2 - 16/2);
    //line(67*5, yCord2 - 16/2, 67*6, yCord2);
    //line(67*6, yCord2, 67*7, yCord2-56/2);
    //line(67*7, yCord2-56/2, 67*8, yCord2);
    //line(67*8, yCord2, 67*19, yCord2);
    //} else if (adjust2 && !adjust) {
    //line(0, yCord2 - 40/4, 67, yCord2 - 104/4);
    //line(67, yCord2 - 104/4, 67*2, yCord2 - 56/4);
    //line(67*2, yCord2 - 56/4, 67*3, yCord2 - 80/4);
    //line(67*3, yCord2 - 80/4, 67*4, yCord2 - 24/4);
    //line(67*4, yCord2 - 24/4, 67*5, yCord2 - 16/4);
    //line(67*5, yCord2 - 16/4, 67*6, yCord2);
    //line(67*6, yCord2, 67*7, yCord2-56/4);
    //line(67*7, yCord2-56/4, 67*8, yCord2);
    //line(67*8, yCord2, 67*19, yCord2);
    //}

    xCord = xCord + 0.6;
  }

  fill(0);
  stroke(100);
  strokeWeight(2);
  line(0, 1074, width, 1074);
  stroke(200);
  //line(0, yCord, width, yCord);
  //line(0, yCord2-145, width, yCord2-145);
  strokeWeight(1);
  // line(0, height-125, width, height-125);
  //line(0,yCord-100,1215,yCord-100);
  noStroke();
  rect(0, 1075, 1308, 5);

  float numAffected = numHealed + totalDeaths + numInfected + numSick;
  float caseFatalityRate = totalDeaths/(numHealed+totalDeaths) * 100;
  cfrGlobal = caseFatalityRate;

  float percentSick = numSick / popSize * 100;
  float percentInfected = numInfected / popSize * 100;
  float percentHealed = numHealed / popSize * 100;
  float percentDead = totalDeaths / popSize * 100;
  float percentHealthy = numHealthy / popSize * 100;
  float percentAffected = numAffected / popSize * 100;
  float percentIncidence = numAffected / dayCounter;  
  float popDensity = popSize / 22000 * 10;
  //float percentHospHeal = 100-caseFatalityRate;
  float percentIsolationHeal = numIsolationHeal/(numIsolationHeal+numNoSeekNoHeal);
  float percentHospHeal = numHospHeal/(numHospHeal+numHospNoHeal);


  noStroke();
  fill(0);
  rect(1308, yCord, 800, 800);
  fill(255);
  strokeWeight(1);
  stroke(150);
  // line(0, yCord, width, yCord);
  line(1308, yCord, 1308, yCord+150);

  textAlign(LEFT);
  textSize(15);
  text("EBOLA OUTBREAK", xStat, yTitle);
  textSize(13);

  text( "DAY", xStat, y1);
  text(  ":  " + dayCounter, xStat2, y1);

  text( "POPULATION", xStat, y2);
  text(  ":  " + round(popSize), xStat2, y2);

  text( "HOSPITAL", xStat, y3);
  text(  ":  " + nf(numExZone, 0, 0), xStat2, y3);

  text( "ETU", xStat, y4);
  text( ":  " + nf(numTempZone, 0, 0), xStat2, y4);

  // text( "HEALTHY   ", xStat3, yTitle);
  //text( nf(numHealthy, 0, 0), xStat2, yHealthy);

  text( "INCUBATION  ", xStat3, y1);
  text(  ":  " + nf(numInfected, 0, 0), xStat4, y1);

  text( "SYMPTOMATIC ", xStat3, y2);
  text(  ":  " + nf(numSick, 0, 0), xStat4, y2);

  //text( "IN TREATMENT : ", xStat, yTreatment);
  //text(  nf(numTreatment, 0, 0), xStat2, yTreatment);

  text( "SURVIVOR", xStat3, y3);
  text(  ":  " + nf(numHealed, 0, 0), xStat4, y3);

  text( "DEATHS", xStat3, y4);
  text( ":  " + nf(totalDeaths, 0, 0), xStat4, y4);

  text( "TOTAL AFFECTED", xStat5, y1  );
  text(  ":  " + nf(numAffected, 0, 0), xStat6, y1 );

  text( "PREVALANCE", xStat5, y2);
  text(  ":  " + nf(percentAffected, 0, 3)+"%", xStat6, y2);

  text( "INCIDENCE RATE", xStat5, y3);
  text( ":  " + nf(percentIncidence, 0, 2), xStat6, y3);

  text( "CASE FATALITY RATE", xStat5, y4);
  text(  ":  " + nf(caseFatalityRate, 0, 2)+"%", xStat6, y4); 

  fill(255);
  strokeWeight(5);
  //  noStroke();
  //ellipse(xStat3-10, yTitle-5, 4, 4);
  stroke(255, 48, 36, 150);
  ellipse(xStat3-12, y2-5, 4, 4);
  stroke(254, 184, 1, 150);
  ellipse(xStat3-12, y1-5, 4, 4);
  stroke(3, 191, 103, 150);
  ellipse(xStat3-12, y3-5, 4, 4);
  stroke(138, 43, 226, 150);
  ellipse(xStat3-12, y4-5, 4, 4);

  noStroke();
  fill(255, 100);
  ellipse(xStat-12, y3-5, 9, 9);
  fill(0, 255, 0);
  ellipse(xStat-12, y3-5, 3, 3);
  fill(255, 100);
  ellipse(xStat-12, y4-5, 9, 9);
  fill(0, 255, 255, 120);
  ellipse(xStat-12, y4-5, 3, 3);


  //if (numSick == 0 && numInfected == 0 && dayCounter > 200) {
  //  if (looping) {
  //    recording = !recording;
  //    noLoop();
  //  } else {
  //    loop();
  //  }
  //}
}
//--------------------------------------------------------------//


void texter()
{
    //HZascii
    if( mouseOverText )
    {
        int LUcode = (int) HZlat.get(mouseX, mouseY );
        fill(255,0,0,255);
        text(LUcode, mouseX+5, mouseY-5 );
    }
    

}

void fillLattice( Lattice latIn, ASCgrid DEin ) // fill Lattice
{
  for ( int x = 0; x < DEin.w; x += 1 ) {
    for ( int y = 0; y < DEin.h; y += 1 ) {

      float value = DEin.get(x, y);
      latIn.put(x, y, value  );
    }
  }
}

void fillLattice2( Lattice latIn, ASCgrid HZin ) // fill Lattice
{
  for ( int x = 0; x < HZin.w; x += 1 ) {
    for ( int y = 0; y < HZin.h; y += 1 ) {

      float value2 = HZin.get(x, y);
      latIn.put(x, y, value2  );
    }
  }
}
//===========================================================//

void drawTargets()
{
  for ( PVector t : targets )
  {
    noStroke();
    fill( 255 );
    ellipse( t.x, t.y, 3, 3 );
  }
};

//--------------------------------------------------------------//

void scrollBar() {

  hs1.updateScroll();
  hs1.displayScroll();

  hs2.updateScroll();
  hs2.displayScroll2();

  hs3.updateScroll();
  hs3.displayScroll3();

  hs4.updateScroll();
  hs4.displayScroll4();

  float xValue  = hs1.getPos();
  float xValue2 = hs2.getPos();
  float xValue3 = hs3.getPos();
  float xValue4 = hs4.getPos();

  int    aid = round(map(xValue, xbar+95, xbar + 305, 0, 100));
  String aidMoney = nfc(aid);
  int    aid2 = round(map(xValue2, xbar+95, xbar + 305, 0, 100));
  burGlobal = aid2;
  String aidMoney2 = nfc(aid2);
  int    pub = round(map(xValue3, xbar+95, xbar + 305, 0, 100));
  String pubAwarness = nfc(pub);
  int    vac = round(map(xValue4, xbar+95, xbar + 305, 0, 100));
  vacGlobal = vac;
  String vacPercent = nfc(vac);

  fill(0, 255, 255, 120);
  //rect(55, hs2.ypos, hs2.spos-55, 10);

  textSize(9);
  textAlign(LEFT);
  fill(255);
  text("% " + aidMoney, hs1.spos+8, hs1.ypos+9);
  text("% " + aidMoney2, hs2.spos+8, hs2.ypos+9);
  text("% " + pubAwarness, hs3.spos+8, hs3.ypos+9); 
  text("% " + vacPercent, hs4.spos+8, hs4.ypos+9); 

  fill(255);
  textSize(12);
  text("INTERVENTION TOOL BARS", xStat5, hs1.ypos-15);
  strokeWeight(1);
  stroke(255, 100);
  line(xStat5, hs1.ypos-9, xStat5+200, hs1.ypos-9);
  noStroke();

  textSize(10);
  textAlign(RIGHT);
  text("HOSPITAL CAPACITY", xStat5 - 5, hs1.ypos+9);
  text("SAFE BURIAL", xStat5 - 5, hs2.ypos+9);
  text("SEEK TREATMENT", xStat5 - 5, hs3.ypos+9);
  text("VACCINATION", xStat5 - 5, hs4.ypos+9);

  //scale
  textAlign(LEFT);
  stroke(250);
  strokeWeight(2);
  textSize(10);
  //text("10 KM", 164, 911);
  //line(25, 910, 158, 910);
  //line(25, 910, 25, 905);
  //line(158, 910, 158, 905);
  textSize(13);
}

//--------------------------------------------------------------//

void createPopulation() // Create Population
{
  population = new ArrayList<Agent>();
  //population.add(new Agent(100,100));


  for ( int x = 0; x < DElat.w; x += 1 ) {
    for ( int y = 0; y < DElat.h; y += 1 ) {
//Modification by Archit Goyal 7/25/2019
      int val =  (int) DElat.get(x, y);
      float randVal = random(1.0);
      
        if (val == populationHome5 && randVal <= birthProb5) {
        Agent temp = new Agent(x, y);
        temp.setHomeClass(populationHome5);
        addToPopulation(temp);
      } else if (val == populationHome2 && randVal <= (birthProb2+birthProb5)) {
        Agent temp = new Agent(x, y);
        temp.setHomeClass(populationHome2);
        addToPopulation(temp);
      } else if (val == populationHome3 && randVal <= (birthProb3+birthProb2+birthProb5)) {
        Agent temp = new Agent(x, y);
        temp.setHomeClass(populationHome3);
        addToPopulation(temp);
      } else if (val == populationHome4 && randVal <= (birthProb4+birthProb3+birthProb2+birthProb5)) {
        Agent temp = new Agent(x, y);
        temp.setHomeClass(populationHome4);
        addToPopulation(temp);
      }
    }
  }

}

private void addToPopulation(Agent temp) {
  if (temp.loc.y < 920) {
    population.add(temp);
    initPop = population.size();
  }
}

//===========================================================//
void mousePressed()
{ 
  if (rectOver) {
    if (!info) {
      info = true;
    } else if (info) {
      info = false;
    }
  }
};

//===========================================================//
void keyPressed()
{   
  //Bug - Program used to crash when random keys are pressed 
  //Modification by Archit Goyal 
  if ( key == 't' )
  {  
    // pressing the 't' key adds a new target location 
    // to the mouse location

    PVector  tt = new PVector( mouseX, mouseY );      // create a target PVector
    cst = new Cost( roadASC, ROADVALUE );             // init the Cost function
    cst.moreOptimal = true ;                           // right now, less optimal paths
    Lattice l = cst.getCostSurface( tt );             // get the cost surface lattice for new target
    ccs.add( l  );                                    // add the lattice to the rest of the cost surfaces
    targets.add( tt );                                // add the new target to the target list

    // Health Zone

    int x = 0;
    int y = 0;

    HealthZone newZone = new HealthZone(x, y, isSetup);

    newZone.loc.x = mouseX;
    newZone.loc.y = mouseY;

    healthZones.add(newZone);  
    for (MultiTargetFinder a : cars) { 
      a.target = null;
    }
  }

  if ( key == 'w') {    // primary image
    if (imageFlip == false) {
      imageFlip = true;
      imageFlip2 = false;
    } else if (imageFlip == true) {
      imageFlip = false;
    }
  }

  if ( key == 'e') {    // primary image
    if (imageFlip == true) {
      imageFlip = false;
      imageFlip2 = true;
    } else if (imageFlip2 == false) {
      imageFlip2 = true;
    }
  }

  if (key == 'r') {
    if (recording == false) {
      recording = true;
    } else if (recording == true) {
      recording = false;
    }
  }

  if (key == 'q') {
    if (popRec == false) {
      popRec = true;
    } else if (popRec == true) {
      popRec = false;
    }
  }

  if (key == 'x') {
    if (!pop) {
      pop = true;
    } else if (pop) {
      pop = false;
    }
  }

  if (key == 'a') {
    if (!viz) {
      viz = true;
    } else if (viz) {
      viz = false;
    }
  }

  if (key == 'n') {
    fill(0);
    rect(0, 0, width, height);
    population.clear();
    healthZones.clear();
    cars.clear();
    //sickHistory.clear();
    createPopulation();

    isSetup = false;
    dayCounter = 0;
    totalDeaths = 0;

    loop();
  }

  if ( key == ' ') // run simulation
  {
    isSetup = true;
    dayCounter = 0;
    xCord = 0;
    xCord1 = 0;
    xCord2 = 0;

     sickHistory.clear();
  }

  if ( key == 's') // sick agent
  {
    newExposed(mouseX, mouseY);
  }
  
  if( key == 'v' ){
      mouseOverText = !mouseOverText;
    }

  if ( key == 'c') // sick agent
  {
    newPathFinder(mouseX, mouseY);
  } else {
  assert true;
  }
}

//===============================================================================// Infect

void infect()
{
  
    ////--------------------------------------------------------------// person to person

  for ( int i = 0; i < exposedPop.size(); i += 1) {

    Agent exposedAgent = exposedPop.get(i);

    for ( int j = i + 1; j < population.size(); j += 1) 
    {
      Agent person2 = population.get(j);

      float distance = dist( exposedAgent.loc.x, exposedAgent.loc.y, person2.loc.x, person2.loc.y);

      float xVacValue = hs4.getPos();
      float vacPercent = map(xVacValue, xbar+95, xbar + 305, 0, 100); 

      if (vacPercent < 20) {
        infectionProbability = 0.0225;
      } else if (vacPercent >= 20 && vacPercent < 40) {  
        infectionProbability = 0.002;
      } else if (vacPercent >= 40 && vacPercent < 60) {  
        infectionProbability = 0.0005;
      } else if (vacPercent >= 60 && vacPercent < 80) {  
        infectionProbability = 0.0002;
      } else if (vacPercent >= 80) {  
        infectionProbability = 0.00005;
      }

      // first condition
      if ( distance <= spreadDistance && exposedAgent.sick && !person2.sick)
      {
        //person 1 makes person 2 sick
        if (prob(infectionProbability) == true) {
           person2.getExposed();
        }
      }

      //if (person2.exposed) {
      //  removeExposed();
      //  newExposed(person2.loc.x, person2.loc.y);
      //}
    }
  }

  ////--------------------------------------------------------------// person to person
  for ( int i = 0; i < popRecord.size(); i += 1) {

    Agent deadPerson = popRecord.get(i);

    for ( int j = i + 1; j < population.size(); j += 1) 
    {
      Agent person2 = population.get(j);

      float distance = dist( deadPerson.loc.x, deadPerson.loc.y, person2.loc.x, person2.loc.y);

      float xValue3 = hs2.getPos();
      float pubAware = map(xValue3, xbar+95, xbar + 305, 0, .005); 

      deadInfectionProbability = .005-pubAware;

      // first condition
      if ( distance <= deadSpreadDistance && deadPerson.deceased && !person2.sick)
      {
        //person 1 makes person 2 sick
        if (prob(deadInfectionProbability) == true && deadPerson.infectiousBody) {
          person2.getExposed();
        }
      } 
    }
  }


  //--------------------------------------------------------------// car to person
  for ( int i = 0; i < cars.size(); i += 1) {

    MultiTargetFinder car1 = cars.get(i);

    for ( int j = 0; j < population.size(); j += 1) 
    {
      Agent person = population.get(j);

      float distance = dist( car1.loc.x, car1.loc.y, person.loc.x, person.loc.y);

      // Infection probability in healthcare 
      if (car1.atTarget) {
        infectionProbability = 0.0001;
      } else {  
        infectionProbability = 0.0010;
      }

      // first condition
      if ( distance <= spreadDistance && car1.sick && !person.sick)
      {
        //car makes person sick
        if (prob(infectionProbability) == true) {
          person.getExposed();
        }
      } 
      
      //if (person.exposed) {
      //  removeExposed();
      //  newExposed(person.loc.x, person.loc.y);
      //}
    }
  }
  
  for ( int j = 0; j < population.size(); j += 1) 
    {
      Agent person = population.get(j);
      if (person.exposed) {
        removeExposed();
        newExposed(person.loc.x, person.loc.y);
      }
    }
  
  
 for ( int i = 0; i < exposedPop.size(); i += 1) {
    Agent exposedAgent = exposedPop.get(i);
     if (exposedAgent.seek){
        removeSick();
        newPathFinder(exposedAgent.loc.x, exposedAgent.loc.y);
     }

  }
}



//===============================================================================//  probability function

boolean prob( float probRate )
{
  if (random(0, 1) <= probRate) {
    return true;
  } else {
    return false;
  }
}

//===============================================================================// record functions

void record() {

  //sim record
  if (recording) {
    saveFrame("output/#####.png");
    fill(255, 0, 0);
  } else if (!recording) {
    noFill();
  }

  stroke(255, 0, 0);
  strokeWeight(4);
  ellipse(width-30, 15, 10, 10);
}

// Data Output
void dataRecord() {         
  if (recording) {
    saveFrame("outputData/#####.png");
  } else if (!recording) {
    noFill();
  }
}

//===============================================================================//  new agents 

void newPathFinder(float x, float y) {  
  MultiTargetFinder car = new MultiTargetFinder( x, y);
  car.findRoad(ccs);
  cars.add(car); 
  car.getSick(2, 21);
}

void sickAgent(float x, float y) {  
  Agent infectedPerson = new Agent( x, y);
  population.add(infectedPerson); 
  infectedPerson.getInfected();
}

void newExposed(float x, float y) {
  Agent exposedAgent = new Agent(x, y);
  exposedAgent.loc.x = x;
  exposedAgent.loc.y = y;
  exposedPop.add(exposedAgent);
  exposedAgent.getExposed();
  println(exposedPop.size());
}

//--------------------------------------------------------------// survivor agent
void newAgent(float x, float y) {
  Agent survivor = new Agent(x, y);
  survivor.loc.x = x;
  survivor.loc.y = y;
  popRecord.add(survivor);
  survivor.drawAgent();
  survivor.getReturned();
  if (survivor.returned) {
    numHealed += 1;
  }
}

//--------------------------------------------------------------// dead agent
void deadAgent(float x, float y) {
  Agent dead = new Agent(x, y);
  dead.loc.x = x;
  dead.loc.y = y;
  dead.vel.x  = 0;
  dead.vel.y  = 0;
  popRecord.add(dead);
  dead.drawAgent();
  dead.getDeceased();
}

//===============================================================================// background data viz

void dataViz() {

  float numSick = 0;

  for (MultiTargetFinder person : cars) {
    if ( person.sick == true) { 
      numSick += 1;
    }
  }

  for (Agent person : population) {
    if ( person.sick == true && person.noSeek) { 
      numSick += 1;
    }
  }

  //--------------------------------------------------------// grid lines
  fill(0, 100);
  noStroke();
  rectMode(CORNER);
  rect(0, yCord, width, -yCord);
  strokeWeight(1);

  // horizontal lines
  for ( int i = 25; i < 920; i += 25) {
    for ( int p = 0; p <= 100; p += 20) {
      stroke(70);
      line(0, yCord-i, 1885, yCord-i);
    }
  }

  // verticle lines
  for ( int i = 0; i < 1900; i += 67) { 
    for ( int p = 0; p <= 20; p += 1) {
      stroke(40);
      line(0+i, yCord, 0+i, -900);
    }
  }

  fill(155);
  // verticle text
  for ( int p = 25; p <= 920; p += 25) {
    textAlign(LEFT);
    text(p/2.5, 1890, yCord-p+5);
  }

  //for ( int p = 25; p <= 290; p += 25) {
  //  textAlign(LEFT);
  //  text(p, 1890, yCord-325-p+5);
  //}

  //for ( int p = 25; p <= 250; p += 25) {
  //  textAlign(LEFT);
  //  text(nf(p/2.5, 0, 0), 1890, yCord-650-p+5);
  //}


  //--------------------------------------------------------// titles
  //fill(250);
  //textSize(14);
  //textAlign(RIGHT);
  //text("CURRENT CASES", width-5, yCord-307);
  //text("DEATHS VS SURVIVORS", width-5, yCord-632);
  //text("PERCENT SEEKING TREATMENT", width-5, yCord-906);

  //--------------------------------------------------------// border lines
  fill(0);
  stroke(200);
  strokeWeight(2);
  line(0, yCord, width, yCord);
  //line(0, yCord-650, width, yCord-650);

  //----------------------------in----------------------------// data lines
  strokeWeight(2);
  xCord1 = 0;
  for (int i = 0; i < frameCount; i++) 
  {
    Float ySick   = sickHistory.get(i);
    Float yHealed = survivorHistory.get(i);
    Float yDeaths = deathHistory.get(i);
    Float ySeek   = seekHistory.get(i);
    ySeek = ySeek* 2.5;

    stroke(160);
    strokeWeight(1);
    line(xCord1, yHealed, xCord1, yCord);
    strokeWeight(3);
    stroke(240);
    line(xCord1, yHealed, xCord1, yHealed);

    stroke(191, 142, 237);
    strokeWeight(1);
    line(xCord1, yDeaths, xCord1, yCord);
    stroke(138, 43, 226);
    strokeWeight(3);
    line(xCord1, yDeaths, xCord1, yDeaths);

    //existing data
    //strokeWeight(1);
    //stroke(120, 120, 120);
    //line(0, yCord-(21*0), 67*8, yCord-(43*2.5));
    //line(67*8, yCord-(43*2.5), 67*9, yCord-(57*2.5));
    //line(67*9, yCord-(57*2.5), 67*10, yCord-(102*2.5));
    //line(67*10, yCord-(102*2.5), 67*11, yCord-(111*2.5));
    //line(67*11, yCord-(111*2.5), 67*12, yCord-(122*2.5));

    //fill(120, 120, 120);
    //textSize(15);
    //text("122 Total Cases", 67*12+5, yCord-(122*2.5)+5);


    //stroke(156, 130, 181);
    //line(0, yCord-(17*0), 67*8, yCord-(34*2.5));
    //line(67*8, yCord-(34*2.5), 67*9, yCord-(41*2.5));
    //line(67*9, yCord-(41*2.5), 67*10, yCord-(59*2.5));
    //line(67*10, yCord-(59*2.5), 67*11, yCord-(75*2.5));
    //line(67*11, yCord-(75*2.5), 67*12, yCord-(82*2.5));
    //fill(156, 130, 181);
    //text("82 Total Deaths [67% CFR]", 67*12+5, yCord-(82*2.5)+5);

    // Mangina //////////////////////////////////////////////////
    strokeWeight(1);
    stroke(120, 120, 120);
    line(0, yCord-(21*0), 67*8, yCord-(36*2.5));
    line(67*8, yCord-(36*2.5), 67*9, yCord-(48*2.5));
    line(67*9, yCord-(48*2.5), 67*10, yCord-(91*2.5));
    line(67*10, yCord-(91*2.5), 67*11, yCord-(94*2.5));
    line(67*11, yCord-(94*2.5), 67*12, yCord-(96*2.5));

    fill(120, 120, 120);
    textSize(15);
    text("96 Total Cases", 67*12+5, yCord-(96*2.5)+5);


    stroke(156, 130, 181);
    line(0, yCord-(17*0), 67*8, yCord-(30*2.5));
    line(67*8, yCord-(30*2.5), 67*9, yCord-(35*2.5));
    line(67*9, yCord-(35*2.5), 67*10, yCord-(51*2.5));
    line(67*10, yCord-(51*2.5), 67*11, yCord-(63*2.5));
    line(67*11, yCord-(63*2.5), 67*12, yCord-(65*2.5));
    fill(156, 130, 181);
    text("65 Total Deaths [67% CFR]", 67*12+5, yCord-(65*2.5)+5);

    stroke(200);
    line(67*8, yCord, 67*8, yCord-950);

    xCord1 = xCord1 + 0.6;
  }

  //--------------------------------------------------------// data text
  strokeWeight(1);
  noStroke();

  float ySeek = map(seekLine, 0, 100, 0, 250); 
  ySeek = ySeek* 2.5;

  float ySick   = yCord - numSick;
  float yAware  = yCord-650-(seekLine*2.5);
  float percent = map(ySeek, 0, 250, 0, 100);
  float yDeaths = yCord-(totalDeaths);
  float yTotal =  yCord-(totalDeaths+numHealed);

  fill(255);
  textAlign(LEFT);
  text(nfc(numSick, 0), xCord1+2, ySick);
  // text(round(percent/2.5) + " % Seeking Treatment", xCord1+2, yAware);
  fill(138, 43, 226);
  text(nfc(totalDeaths, 0) + "Deaths", xCord1+2, yDeaths);
  fill(120, 120, 120);
  text(nfc((totalDeaths+numHealed), 0) + "Total", xCord1+2, yTotal);
}


//===============================================================================// window data viz

void vizWindow() {

  float numSick = 0;

  for (MultiTargetFinder person : cars) {
    if ( person.sick == true) { 
      numSick += 1;
    }
  }

  for (Agent person : population) {
    if ( person.sick == true && person.noSeek) { 
      numSick += 1;
    }
  }

  //--------------------------------------------------------// grid lines
  fill(0, 100);
  noStroke();
  rectMode(CORNER);
  rect(0, yCord, width, -yCord);
  strokeWeight(1);

  // horizontal lines
  for ( int i = 25; i < 920; i += 25) {
    for ( int p = 0; p <= 100; p += 20) {
      stroke(70);
      line(0, yCord-i, 1885, yCord-i);
    }
  }

  // verticle lines
  for ( int i = 0; i < 1900; i += 67) { 
    for ( int p = 0; p <= 20; p += 1) {
      stroke(40);
      line(0+i, yCord, 0+i, -900);
    }
  }

  fill(155);
  // verticle text
  for ( int p = 25; p <= 900; p += 25) {
    textAlign(LEFT);
    text(p, 1890, yCord-p+5);
  }

  //for ( int p = 25; p <= 290; p += 25) {
  //  textAlign(LEFT);
  //  text(p, 1890, yCord-325-p+5);
  //}

  //for ( int p = 25; p <= 250; p += 25) {
  //  textAlign(LEFT);
  //  text(nf(p/2.5, 0, 0), 1890, yCord-650-p+5);
  //}


  //--------------------------------------------------------// titles
  //fill(250);
  //textSize(14);
  //textAlign(RIGHT);
  //text("CURRENT CASES", width-5, yCord-307);
  //text("DEATHS VS SURVIVORS", width-5, yCord-632);
  //text("PERCENT SEEKING TREATMENT", width-5, yCord-906);

  //--------------------------------------------------------// border lines
  fill(0);
  stroke(200);
  strokeWeight(2);
  line(0, yCord, width, yCord);
  //line(0, yCord-650, width, yCord-650);

  //--------------------------------------------------------// data lines
  strokeWeight(2);
  xCord2 = 0;
  for (int i = 0; i < frameCount; i++) 
  {
    Float ySick   = sickHistory.get(i);
    Float yHealed = survivorHistory.get(i);
    Float yDeaths = deathHistory.get(i);
    Float ySeek   = seekHistory.get(i);
    ySeek = ySeek* 2.5;

    stroke(160);
    strokeWeight(1);
    line(xCord2, yHealed, xCord2, yCord);
    strokeWeight(3);
    stroke(240);
    line(xCord2, yHealed, xCord2, yHealed);

    stroke(191, 142, 237);
    strokeWeight(1);
    line(xCord2, yDeaths, xCord2, yCord);
    stroke(138, 43, 226);
    strokeWeight(3);
    line(xCord2, yDeaths, xCord2, yDeaths);

    //existing data
    //strokeWeight(1);
    //stroke(120, 120, 120);
    //line(0, yCord-(21*0), 67*8, yCord-(43*2.5));
    //line(67*8, yCord-(43*2.5), 67*9, yCord-(57*2.5));
    //line(67*9, yCord-(57*2.5), 67*10, yCord-(102*2.5));
    //line(67*10, yCord-(102*2.5), 67*11, yCord-(111*2.5));
    //line(67*11, yCord-(111*2.5), 67*12, yCord-(122*2.5));

    //fill(120, 120, 120);
    //textSize(15);
    //text("122 Total Cases", 67*12+5, yCord-(122*2.5)+5);


    //stroke(156, 130, 181);
    //line(0, yCord-(17*0), 67*8, yCord-(34*2.5));
    //line(67*8, yCord-(34*2.5), 67*9, yCord-(41*2.5));
    //line(67*9, yCord-(41*2.5), 67*10, yCord-(59*2.5));
    //line(67*10, yCord-(59*2.5), 67*11, yCord-(75*2.5));
    //line(67*11, yCord-(75*2.5), 67*12, yCord-(82*2.5));
    //fill(156, 130, 181);
    //text("82 Total Deaths [67% CFR]", 67*12+5, yCord-(82*2.5)+5);

    //Mangina//
    strokeWeight(2);
    stroke(120, 120, 120);
    line(0, yCord-(21*0), 67*6, yCord-(43));
    line(67*6, yCord-(43), 67*7, yCord-(49));
    line(67*7, yCord-(49), 67*8, yCord-(90));
    line(67*8, yCord-(90), 67*9, yCord-(107));
    line(67*9, yCord-(107), 67*10, yCord-(120));
    line(67*10, yCord-(120), 67*11, yCord-(129));
    line(67*11, yCord-(129), 67*12, yCord-(140));
    line(67*12, yCord-(140), 67*13, yCord-(147));
    line(67*13, yCord-(147), 67*14, yCord-(155));
    line(67*14, yCord-(155), 67*15, yCord-(167));
    line(67*15, yCord-(167), 67*16, yCord-(205));
    line(67*16, yCord-(205), 67*17, yCord-(227));
    line(67*17, yCord-(227), 67*18, yCord-(257));
    line(67*18, yCord-(257), 67*19, yCord-(287));
    line(67*19, yCord-(287), 67*20, yCord-(319));
    line(67*20, yCord-(319), 67*21, yCord-(352));
    line(67*21, yCord-(352), 67*22, yCord-(399));
    line(67*22, yCord-(399), 67*23, yCord-(428));
    line(67*23, yCord-(428), 67*24, yCord-(477));
    line(67*24, yCord-(477), 67*25, yCord-(529));
    line(67*25, yCord-(529), 67*26, yCord-(567));
    line(67*26, yCord-(567), 67*27, yCord-(593));
    line(67*27, yCord-(593), 67*28, yCord-(614));

    //reported deaths
    stroke(156, 130, 181);
    line(0, yCord-(21*0), 67*6, yCord-(33));
    line(67*6, yCord-(33), 67*7, yCord-(38));
    line(67*7, yCord-(38), 67*8, yCord-(49));
    line(67*8, yCord-(49), 67*9, yCord-(70));
    line(67*9, yCord-(70), 67*10, yCord-(78));
    line(67*10, yCord-(78), 67*11, yCord-(89));
    line(67*11, yCord-(89), 67*12, yCord-(94));
    line(67*12, yCord-(94), 67*13, yCord-(99));
    line(67*13, yCord-(99), 67*14, yCord-(102));
    line(67*14, yCord-(102), 67*15, yCord-(106));
    line(67*15, yCord-(106), 67*16, yCord-(130));
    line(67*16, yCord-(130), 67*17, yCord-(147));
    line(67*17, yCord-(147), 67*18, yCord-(164));
    line(67*18, yCord-(164), 67*19, yCord-(181));
    line(67*19, yCord-(181), 67*20, yCord-(198));
    line(67*20, yCord-(198), 67*21, yCord-(210));
    line(67*21, yCord-(210), 67*22, yCord-(228));
    line(67*22, yCord-(228), 67*23, yCord-(248));
    line(67*23, yCord-(248), 67*24, yCord-(275));
    line(67*24, yCord-(275), 67*25, yCord-(311));
    line(67*25, yCord-(311), 67*26, yCord-(347));
    line(67*26, yCord-(347), 67*27, yCord-(360));
    line(67*27, yCord-(360), 67*28, yCord-(374));
    
    fill(156, 130, 181);
    stroke(200);
    line(67*6, yCord, 67*6, yCord-950); 

    xCord2 = xCord2 + 0.6;
  }

  //--------------------------------------------------------// data text
  strokeWeight(1);
  noStroke();

  float ySeek = map(seekLine, 0, 100, 0, 250); 
  ySeek = ySeek* 2.5;

  float ySick   = yCord - numSick;
  float yAware  = yCord-650-(seekLine*2.5);
  float percent = map(ySeek, 0, 250, 0, 100);
  float yDeaths = yCord-(totalDeaths*5);
  float yTotal =  yCord-((totalDeaths+numHealed)*5);


  textAlign(LEFT);
  //text(nfc(numSick, 0) + " Cases", xCord2+2, ySick);
  // text(round(percent/2.5) + " % Seeking Treatment", xCord2+2, yAware);
  text(nfc((totalDeaths+numHealed), 0), xCord2+2, yTotal);
  fill(156, 130, 181);
  text(nfc(totalDeaths, 0), xCord2+2, yDeaths);
}

//===============================================================================// button functions

void button() {

  if (!info) {
    fill(255);
    strokeWeight(1);
    textAlign(LEFT);
    text("x  add population", xStat3-60, 775);
    text("t  add health center", xStat3-60, 795);
    text("_  start simulation", xStat3-60, 815);
    text("c  add sick agent", xStat3-60, 835);
    text("w  background", xStat3-50, 855);
    text("n  refresh", xStat3-60, 875);
    text("r  record", xStat3-60, 895);
    text("a  graphs", xStat3-60, 915);
  }

  buttonUpdate(mouseX, mouseY);

  if (rectOver) {
    fill(rectHighlight);
  } else {
    noFill();
  }

  strokeWeight(1);
  stroke(255);
  ellipseMode(CENTER);
  ellipse(rectX+7, rectY, rectWidth, rectHeight); 

  if (rectOver) { 
    fill(0);
  } else {
    fill(255);
  }
  textAlign(CENTER);
  text("i", rectX+(rectWidth/2), rectY+5);
}

void buttonUpdate(float x, float y) {

  rectOver = false;
  if ( overRect(rectX, rectY, rectWidth, rectHeight) ) {
    rectOver = true;
  }
}

boolean overRect(int x, int y, int width, int height) {
  if (mouseX >= x && mouseX <= x+width && 
    mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}
