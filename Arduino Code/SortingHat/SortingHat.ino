#include <Servo.h>

const int signalFeatureIDBits = 2;

Servo servos[4];
int servoPos[4] = {0,0,0,0};

void setup() {
  Serial.begin(9600);
  
  servos[0].attach(4);
  servos[1].attach(5);
  servos[2].attach(6);
  servos[3].attach(7);
  
  Serial.println("Setup Complete");
}

void loop() {
  if (Serial.available() > 0) {
    int incomingSignal = Serial.read();
    int featureID = incomingSignal >> (8-signalFeatureIDBits);
    int featureVal = incomingSignal & (255 >> signalFeatureIDBits);
    servos[featureID].write(featureVal);
  }

}
