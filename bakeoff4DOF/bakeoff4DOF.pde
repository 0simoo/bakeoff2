import java.util.ArrayList;
import java.util.Collections;

//these are variables you should probably leave alone
int index = 0; //starts at zero-ith trial
float border = 0; //some padding from the sides of window, set later
int trialCount = 12; //this will be set higher for the bakeoff
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 0.5f; //for every error, add this value to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false; //is the user done

final int screenPPI = 72; //what is the DPI of the screen you are using
//you can test this by drawing a 72x72 pixel rectangle in code, and then confirming with a ruler it is 1x1 inch.

//These variables are for my example design. Your input code should modify/replace these!
float logoX = 500;
float logoY = 500;
float logoZ = 50f;
float logoRotation = 0;

boolean overBox = false;
boolean overCorner = false;
boolean locked = false;
boolean lockedCorner = false;
float xOffset = 0.0;
float yOffset = 0.0;

boolean pickedUp = false;

private class Destination
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Destination> destinations = new ArrayList<Destination>();

void setup() {
  size(1000, 800);
  rectMode(CENTER);
  textFont(createFont("Arial", inchToPix(.3f))); //sets the font to Arial that is 0.3" tall
  textAlign(CENTER);
  rectMode(CENTER); //draw rectangles not from upper left, but from the center outwards

  //don't change this!
  border = inchToPix(2f); //padding of 1.0 inches

  for (int i=0; i<trialCount; i++) //don't change this!
  {
    Destination d = new Destination();
    d.x = random(border, width-border); //set a random x with some padding
    d.y = random(border, height-border); //set a random y with some padding
    d.rotation = random(0, 360); //random rotation between 0 and 360
    int j = (int)random(20);
    d.z = ((j%12)+1)*inchToPix(.25f); //increasing size from .25 up to 3.0"
    destinations.add(d);
    println("created target with " + d.x + "," + d.y + "," + d.rotation + "," + d.z);
  }

  Collections.shuffle(destinations); // randomize the order of the button; don't change this.
}



void draw() {

  background(40); //background is dark grey
  fill(200);
  noStroke();

  //shouldn't really modify this printout code unless there is a really good reason to
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchToPix(.4f));
    text("User had " + errorCount + " error(s)", width/2, inchToPix(.4f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per destination", width/2, inchToPix(.4f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per destination inc. penalty", width/2, inchToPix(.4f)*4);
    return;
  }

  //===========DRAW DESTINATION SQUARES=================
  for (int i=trialIndex; i<trialCount; i++) // reduces over time
  {
    pushMatrix();
    Destination d = destinations.get(i); //get destination trial
    translate(d.x, d.y); //center the drawing coordinates to the center of the destination trial
    rotate(radians(d.rotation)); //rotate around the origin of the destination trial
    noFill();
    strokeWeight(3f);
    if (trialIndex==i)
      stroke(255, 0, 0, 192); //set color to semi translucent
    else
      stroke(128, 128, 128, 128); //set color to semi translucent
    rect(0, 0, d.z, d.z);
    popMatrix();
  }

  //===========DRAW LOGO SQUARE=================
  pushMatrix();
  translate(logoX, logoY); //translate draw center to the center oft he logo square
  rotate(radians(logoRotation)); //rotate using the logo square as the origin
  noStroke();
  fill(60, 60, 192, 192);
  overBox = isOverBox();
  if (pickedUp) {
      stroke(204, 102, 0);
  }
  rect(0, 0, logoZ, logoZ);
  overCorner = isOverCorner();
  popMatrix();

  //===========DRAW EXAMPLE CONTROLS=================
  fill(255);
  scaffoldControlLogic(); //you are going to want to replace this!
  moveLogo();
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchToPix(.8f));
  
  //accuracy feedback
  Destination d = destinations.get(trialIndex);  
  
  if(dist(d.x, d.y, logoX, logoY)<inchToPix(.05f))
    fill(124,252,0);
  else
    fill(255,160,122);
  text("D", width/2 - inchToPix(.3f), inchToPix(1.2f));
  
  if(calculateDifferenceBetweenAngles(d.rotation, logoRotation)<=5)
    fill(124,252,0);
  else
    fill(255,160,122);
  text("R", width/2, inchToPix(1.2f));
  
  if(abs(d.z - logoZ)<inchToPix(.1f))
    fill(124,252,0);
  else
    fill(255,160,122);
  text("Z", width/2 + inchToPix(.3f), inchToPix(1.2f));
}

void moveLogo() {
  //move
  if (pickedUp) {
    logoX = mouseX-xOffset;
    logoY = mouseY-yOffset;
  }
}

//our new design for control, which is not as terrible
void scaffoldControlLogic()
{
  //upper left corner, rotate counterclockwise
  text("CCW", inchToPix(12.25f), inchToPix(10.6f));
  if (mousePressed && dist(inchToPix(12.25f), inchToPix(10.6f), mouseX, mouseY)<inchToPix(.46f))
    logoRotation -= 0.1;

  //upper right corner, rotate clockwise
  text("CW", width-inchToPix(.3f), inchToPix(10.6f));
  if (mousePressed && dist(width-inchToPix(.4f), inchToPix(10.6f), mouseX, mouseY)<inchToPix(.5f))
    logoRotation += 0.1;

  //lower left corner, decrease Z
  text("-", inchToPix(12.94f), inchToPix(10.9f));
  if (mousePressed && dist(inchToPix(12.94f), inchToPix(10.9f), mouseX, mouseY)<inchToPix(.5f))
    logoZ = constrain(logoZ-inchToPix(.02f), .01, inchToPix(4f)); //leave min and max alone!

  //lower right corner, increase Z
  text("+", inchToPix(12.94f), inchToPix(10.3f));
  if (mousePressed && dist(inchToPix(12.9f), inchToPix(10.3f), mouseX, mouseY)<inchToPix(.42f))
    logoZ = constrain(logoZ+inchToPix(.02f), .01, inchToPix(4f)); //leave min and max alone!


  //left middle, move left
  text("left", inchToPix(.4f), inchToPix(10.6f));
  if (mousePressed && dist(inchToPix(.4f), inchToPix(10.6f), mouseX, mouseY)<inchToPix(.5f))
    logoX-=inchToPix(.02f);

  text("right", inchToPix(1.8f), inchToPix(10.6f));
  if (mousePressed && dist(inchToPix(1.8f), inchToPix(10.6f), mouseX, mouseY)<inchToPix(.5f))
    logoX+=inchToPix(.02f);

  text("up", inchToPix(1.1f), inchToPix(10.2f));
  if (mousePressed && dist(inchToPix(1.1f), inchToPix(10.2f), mouseX, mouseY)<inchToPix(.5f))
    logoY-=inchToPix(.02f);

  text("down", inchToPix(1.1f), inchToPix(11f));
  if (mousePressed && dist(inchToPix(1.1f), inchToPix(11f), mouseX, mouseY)<inchToPix(.5f))
    logoY+=inchToPix(.02f);
    
  if(checkForSuccess()){
    fill(124,252,0);
  }
  text("Submit", inchToPix(7f), inchToPix(11f));
}

void mousePressed()
{
  if (overBox) {
    pickedUp = !pickedUp;
  }
  if (startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
  }
  locked = overBox;
  xOffset = mouseX-logoX;
  yOffset = mouseY-logoY;
  lockedCorner = overCorner;
  
  if (dist(inchToPix(7f), inchToPix(11f), mouseX, mouseY)<inchToPix(.5f))
  {
    if (userDone==false && !checkForSuccess())
      errorCount++;

    trialIndex++; //and move on to next trial

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
  }
}

void mouseDragged() {
  //draggable square but its a bit janky
  //if(locked){
  //  pickedUp = !pickedUp;
  //}
  if(!locked) {
    logoRotation = degrees(atan2((logoY - mouseY), (logoX - mouseX)));
    println("radians:" + logoRotation + " degrees: " + degrees(logoRotation));
  }
  if(locked) {
    logoX = mouseX-xOffset;
    logoY = mouseY-yOffset;
  }
  if(lockedCorner) {
    float currentLogoZ = logoZ;
    cursor(HAND);
    if (mouseY > logoY+currentLogoZ) {
      logoZ = constrain(logoZ+inchToPix(.02f), .01, inchToPix(4f));
    }
    else {
      logoZ = constrain(logoZ-inchToPix(.02f), .01, inchToPix(4f));
    }
  }
}

/**
 pushMatrix();
 translate(logoX, logoY); //translate draw center to the center oft he logo square
 rotate(radians(logoRotation)); //rotate using the logo square as the origin
 noStroke();
 fill(60, 60, 192, 192);
 overBox = isOverBox();
 rect(0, 0, logoZ, logoZ);
 popMatrix();
 **/

void mouseReleased()
{
  locked = false;
  lockedCorner = false;
}

//Keyboard input is illegal
//void keyPressed()
//{
//  if (key == ' ') {
//    if (userDone==false && !checkForSuccess())
//      errorCount++;

//    trialIndex++; //and move on to next trial

//    if (trialIndex==trialCount && userDone==false)
//    {
//      userDone = true;
//      finishTime = millis();
//    }
//  }
//}

boolean isOverBox()
{
  if (!isOverCorner() &&
          mouseX >= logoX-(logoZ/2) && mouseX <= logoX+(logoZ/2) &&
          mouseY >= logoY-(logoZ/2) && mouseY <= logoY+(logoZ/2)) {
    return true;
  } else {
    return false;
  }
}

boolean isOverCorner()
{
  float offset = (0.25)*logoZ;  
  boolean bottomRight = mouseX >= (logoX+(logoZ/2)-offset) && mouseX <= (logoX+(logoZ/2)+offset) &&
          mouseY >= (logoY+(logoZ/2)-offset) && mouseY <= (logoY+(logoZ/2)+offset);
  boolean bottomLeft = mouseX >= (logoX-(logoZ/2)-offset) && mouseX <= (logoX-(logoZ/2)+offset) &&
          mouseY >= (logoY+(logoZ/2)-offset) && mouseY <= (logoY+(logoZ/2)+offset);
  boolean topRight = mouseX >= (logoX+(logoZ/2)-offset) && mouseX <= (logoX+(logoZ/2)+offset) &&
          mouseY >= (logoY-(logoZ/2)-offset) && mouseY <= (logoY-(logoZ/2)+offset);
  boolean topLeft = mouseX >= (logoX-(logoZ/2)-offset) && mouseX <= (logoX-(logoZ/2)+offset) &&
          mouseY >= (logoY-(logoZ/2)-offset) && mouseY <= (logoY-(logoZ/2)+offset);
 
  if (bottomRight || bottomLeft || topRight || topLeft) {
    cursor(HAND);
    print("over corner\n");
    return true;
  } else {
    cursor(ARROW);
    print("not over corner\n");
    return false;
  }
}


//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
  Destination d = destinations.get(trialIndex);  
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, logoRotation)<=5;
  boolean closeZ = abs(d.z - logoZ)<inchToPix(.1f); //has to be within +-0.1"  

  println("Close Enough Distance: " + closeDist + " (logo X/Y = " + d.x + "/" + d.y + ", destination X/Y = " + logoX + "/" + logoY +")");
  println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(d.rotation, logoRotation)+")");
  println("Close Enough Z: " +  closeZ + " (logo Z = " + d.z + ", destination Z = " + logoZ +")");
  println("Close enough all: " + (closeDist && closeRotation && closeZ));

  return closeDist && closeRotation && closeZ;
}

//utility function I include to calc diference between two angles
double calculateDifferenceBetweenAngles(float a1, float a2)
{
  double diff=abs(a1-a2);
  diff%=90;
  if (diff>45)
    return 90-diff;
  else
    return diff;
}

//utility function to convert inches into pixels based on screen PPI
float inchToPix(float inch)
{
  return inch*screenPPI;
}


//this is illegal D:
//void mouseWheel(MouseEvent event) {
//  float e = event.getCount();
//  logoZ += e;
//  println(logoZ);
//}
