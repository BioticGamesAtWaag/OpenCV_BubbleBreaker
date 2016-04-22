/*
  This code is free software: you can redistribute it and/or modify 
  it under the terms of the GNU General Public License as published 
  by the Free Software Foundation, either version 3 of the License, 
  or (at your option) any later version.
  This code is distributed in the hope that it will be useful, but 
  WITHOUT ANY WARRANTY; without even the implied warranty of 
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU 
  General Public License for more details.
  You should have received a copy of the GNU General Public License
  along with this code. If not, see <http://www.gnu.org/licenses/>.
*/

/* Load libraries */
import gab.opencv.*;              // Load library https://github.com/atduskgreg/opencv-processing
import processing.video.*;        // Load video camera library 

/* Declare variables */
Capture video;                    // Camera stream
OpenCV opencv;                    // OpenCV
PImage now, diff;                 // PImage variables to store the current image and the difference between two images 

int poppedBubbles;                //  Count total number of popped bubbles
ArrayList bubbles;                //  ArrayList to hold the Bubble objects
PImage bubblePNG;                 //  PImage that will hold the image of the bubble
PFont font;                       //  A new font object

int DiffTreshold = 50;            //  Sensitivity of the script

/* Define a bubble class */
class Bubble {
  int bubbleX, bubbleY, bubbleWidth, bubbleHeight;  //  Variables to hold the bubble's coordinates and width/height
 
  Bubble ( int bX, int bY, int bW, int bH )  //  Class constructor- sets all the values when a new bubble object is created
  {
    bubbleX = bX;
    bubbleY = bY;
    bubbleWidth = bW;
    bubbleHeight = bH;
  }
 
  int update()      //   The Bubble update function
  {
    int movementAmount;          //  Create and set a variable to hold the amount of white pixels detected in the area where the bubble is
    movementAmount = 0;
    for( int y = bubbleY; y < (bubbleY + (bubbleHeight-1)); y++ ){   //  For loop that cycles through all of the pixels in the area the bubble occupies
      for( int x = bubbleX; x < (bubbleX + (bubbleWidth-1)); x++ ){
        if ( x< width && x > 0 && y < height && y > 0 ){             //  If the current pixel is within the screen bondaries
          if (brightness(diff.pixels[x + (y * width)]) > 127)        //  and if the brightness is above 127 (in this case, if it is white)
          {
            movementAmount++;                                        //  Add 1 to the movementAmount variable.
          }
        }
      }
    }
     
    if (movementAmount > 5)               //  If more than 5 pixels of movement are detected in the bubble area
    {
      poppedBubbles++;                    //  Add 1 to the variable that holds the number of popped bubbles
      return 1;                           //  Return 1 so that the bubble object is destroyed 
    }else{                                //  If less than 5 pixels of movement are detected,
      bubbleY += 10;                      //  increase the y position of the bubble so that it falls down
      if (bubbleY > height)               //  If the bubble has dropped off of the bottom of the screen
      {  
        return 1;                         //  Return '1' so that the bubble object is destroyed
      }                      
      image(bubblePNG, bubbleX, bubbleY); //  Draws the bubble to the screen
            return 0;                     //  Returns '0' so that the bubble isn't destroyed
    }
  }
}

/* Setup function */
void setup() {
  size(640, 480);                         //  Create canvas window
  video = new Capture(this, 640, 480);    //  Define video size
  opencv = new OpenCV(this, 640, 480);    //  Define opencv size

  video.start();                          //  Start capturing video        

  poppedBubbles = 0;                      //  Set score to 0
  bubbles = new ArrayList();              //  Initialises the ArrayList
 
  bubblePNG = loadImage("bubble.png");    //  Load the bubble image into memory
  font = loadFont("Serif-48.vlw");        //  Load the font file into memory
  textFont(font, 22);                     //  Set font size
}

/* Draw function */
void draw() {
  
  // Add one bubble each round at a random x position
  bubbles.add(new Bubble( int(random(0, 600)), (-1 * bubblePNG.height), bubblePNG.width, bubblePNG.height)); 
  
  opencv.loadImage(video);   //  Capture video from camera in OpenCV
  now = opencv.getInput();   //  Store image in PImage
  image(video, 0, 0);        //  Draw camera image to screen 
  
  opencv.blur(3);                  //  Reduce camera noise            
  opencv.diff(now);                //  Difference between two pictures
  opencv.threshold(DiffTreshold);  //  Convert to Black and White
  diff = opencv.getOutput();       //  Store this image in an PImage variable
  
  for ( int i = 0; i < bubbles.size(); i++ ){   //  For every bubble in the bubbles array
    Bubble _bubble = (Bubble) bubbles.get(i);   //  Copies the current bubble into a temporary object
 
    if(_bubble.update() == 1){                  //  If the bubble's update function returns '1'
      bubbles.remove(i);                        //  then remove the bubble from the array
      _bubble = null;                           //  and make the temporary bubble object null
      i--;                                      //  since we've removed a bubble from the array, we need to subtract 1 from i, or we'll skip the next bubble
    }else{                                      //  If the bubble's update function doesn't return '1'
      bubbles.set(i, _bubble);                  //  Copies the updated temporary bubble object back into the array
      _bubble = null;                           //  Makes the temporary bubble object null.
    }
  }
    
  text("Bubbles popped: " + poppedBubbles, 20, 40);   // Display score
}

/* Capture function */
void captureEvent(Capture c) {
  c.read();
}
