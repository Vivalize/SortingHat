import processing.sound.*;
import processing.serial.*;
import controlP5.*;
import oscP5.*;
import netP5.*;
import java.io.*;

//If using facial recognition, set to true
//To use microphone amplitude, set to false
boolean useFace = false;

//Set to the port of the bluetooth device listed when running this
int serialPort = 9;

//Turn to false if you don't want to connect to bluetooth
boolean sendToArduino = true;

Serial port;
Amplitude amp;
AudioIn in;
ControlP5 MyController;
OscP5 oscP5;
NetAddress myRemoteLocation;
int prevVal = 0;
int sensitivity = 100;
int xPos = 0;
int offset = 50;
float mouthHeight = 0.0;
float leftEyeHeight = 0.0;
float rightEyeHeight = 0.0;
float leftEyebrowHeight = 0.0;
float rightEyebrowHeight = 0.0;

void setup() {
  size(400, 180);
  background(255);
  MyController = new ControlP5(this);
  MyController.addSlider("sensitivity",0,300,(int) sensitivity,20,20,10,100);
  //run("mkdir wubadubdub");
  if (sendToArduino) {
    println("Available serial ports:");
    for(int i = 0; i < Serial.list().length; i++) {
      if (i==serialPort) { System.err.println("["+i+"] "+Serial.list()[i]); }
      else { println("["+i+"] "+Serial.list()[i]); }
    }  
    port = new Serial(this, Serial.list()[serialPort], 9600);
  }
  
  if (!useFace) {
    // Create an Input stream which is routed into the Amplitude analyzer
    amp = new Amplitude(this);
    in = new AudioIn(this, 0);
    in.start();
    amp.input(in);
  } else {
    oscP5 = new OscP5(this,8338);
    myRemoteLocation = new NetAddress("127.0.0.1",8338);
    oscP5.plug(this,"mouth","/gesture/mouth/height");
    oscP5.plug(this,"leftEye","/gesture/eye/left");
    oscP5.plug(this,"rightEye","/gesture/eye/right");
    oscP5.plug(this,"leftEyebrow","/gesture/eyebrow/left");
    oscP5.plug(this,"rightEyebrow","/gesture/eyebrow/right");
    run("open /Applications/FaceOSC.app");
  }
  
}      

void draw() {
  
  int output;
  if (!useFace) {
    output = getMic();
  } else output = getFace();
  
  if (sendToArduino) {
    //Write to arduino
    println(output);
    port.write(output);
    delay(20);
  }
  
  //Post
  //background((int)(Math.sqrt(reading*255.0)));
  background(output);
  
  stroke(127, 34, 255);
  line(xPos, 180-prevVal, xPos, 180-output);

  // at the edge of the screen, go back to the beginning:
  if (xPos >= width) {
    xPos = 0;
    background(0);
  } else {
    // increment the horizontal position:
    xPos++;
  }
  
  prevVal = output;
  //delay(10);
}
  
  
int getMic() {
  //Read reading
  float reading = amp.analyze();
  
  //Amplitude from 0-180
  int amplitude = (int) (reading * 180.0);
  
  //Adjustments
  amplitude = (int) (Math.sqrt(reading * 32400));
  
  //Sensitivity scale
  amplitude = (int) (((double)amplitude) * ((double)sensitivity/100.0));
  
  //Safeguards
  if (amplitude <= 0) { amplitude = 1; }
  if (amplitude > 180) { amplitude = 180; }
    
  return amplitude;
}

int getFace() {
  return int(mouthHeight) * 15;
}

public void mouth(float input) { mouthHeight = input; }
public void leftEye(float input) { leftEyeHeight = input; }
public void rightEye(float input) { rightEyeHeight = input; }
public void leftEyebrow(float input) { leftEyebrowHeight = input; }
public void rightEyebrow(float input) { rightEyebrowHeight = input; }

void run(String cmd) {
  try {
    Runtime.getRuntime().exec(cmd, null, null);
  } catch (Exception err) {
    err.printStackTrace();
  }
}