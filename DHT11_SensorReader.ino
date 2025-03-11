#include "dht.h"
#define dht_apin A0 
 
dht DHT;
 
void setup(){ 
  Serial.begin(9600);
  delay(1000);
}
 
void loop(){
 
    DHT.read11(dht_apin);
    Serial.print(DHT.temperature); 
    Serial.print(",");
    Serial.print(DHT.humidity);
    
    Serial.println();
    
    delay(30000);
}