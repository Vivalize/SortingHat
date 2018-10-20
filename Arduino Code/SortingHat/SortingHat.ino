#include <Servo.h>

// Bluetooth Int Data Control Scheme:
// XXYYYYYY
// XX = Bits defining which motor to move
// YYYYYY = Bits defining how much to move the motor
const int signalFeatureIDBits = 2;

// The range of motion of the servos
const int servoMins[] = {20,30,40,140};
const int servoMaxs[] = {140,150,140,40};


Servo servos[4];

void setup() {
  Serial.begin(9600);
  
  servos[0].attach(6);  // Mouth
  servos[1].attach(9);  // Tip
  servos[2].attach(10); // Eye - Left
  servos[3].attach(11); // Eye - Right
  
  Serial.println("Setup Complete");
}


void loop() {
  
  if (Serial.available() > 0) {
    int incomingSignal = Serial.read();
    
    handleControlSignal(incomingSignal);
  }

}


//This function takes in a received byte and interprets it to servo motion
void handleControlSignal(int incomingByte) {

  //First 2 bits determine which servo to move
  int featureID = incomingByte >> (8-signalFeatureIDBits);

  //Remaining bits define how much to move the servo
  int featureVal = incomingByte & (255 >> signalFeatureIDBits);

  //This determines the actual amount to move the servo
  int toWrite = ((featureVal*(servoMaxs[featureID]-servoMins[featureID]))/pow(2,(8-signalFeatureIDBits)))+servoMins[featureID];

  //Write to the servo
  servos[featureID].write(toWrite);
}

