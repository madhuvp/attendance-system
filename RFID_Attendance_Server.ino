#include <ESP8266WiFi.h>
#include <MFRC522.h>
#include <Wire.h>
#include <OLED.h>
MFRC522 mfrc522(D4, D3);
OLED display(D2, D1);

char* ssid = "kishore kumar";
char* password = "25041996";
WiFiClient c;
WiFiServer server(23);


String getUID(byte *buffer, byte bufferSize) {
  String id = "";
  for (byte i = 0; i < bufferSize; i++) {
    id.concat(String(mfrc522.uid.uidByte[i] < 0x10 ? "0" : ""));
    id.concat(String(mfrc522.uid.uidByte[i], HEX));
  }
  return id;
}

char *status;
char buf[10];
char recv[20];
bool disp = true;

void setup() {

  display.begin();
  SPI.begin();      // Init SPI bus
  mfrc522.PCD_Init();   // Init MFRC522

  display.print("Connecting to ");
  display.print(ssid,2);
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  int i = 0;
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    display.print(".",4,i++);
    if(i > 8) i = 0;
  }
  display.print("WiFi connected",7);
  server.begin();
  server.setNoDelay(true);
  delay(1000);

}

void loop() {
  if (server.hasClient()) {
    if (!c || !c.connected()) {
      if (c) c.stop();
      c = server.available();
      //Serial.print("New client");
    }
  }
  if (c && c.connected())
  {
    status = "ONLINE ";
    if (disp == false)
    {
      display.begin();
      display.print(status, 0);
      disp = true;
    }
    mfrc522.PCD_Init();
    if (mfrc522.PICC_IsNewCardPresent())
      if (mfrc522.PICC_ReadCardSerial()) {
        String x = getUID(mfrc522.uid.uidByte, mfrc522.uid.size);
        x.toUpperCase();
        x.toCharArray(buf, x.length());
        //Serial.println(buf);
        c.println(buf);
        delay(1);
        c.flush();
      }
    if (c.available()) {
      String r = c.readStringUntil('\n');      
      r.toUpperCase();
      r.toCharArray(recv, r.length());
      //Serial.println(recv);
      display.begin();
      display.print(status, 0);
      display.print(recv, 2);
      if(r.charAt(r.length()-1) == 'M')
      display.print("MARKED", 4);
      if(r.charAt(r.length()-1) == 'A')  
      display.print("ALREADY MARKED", 4); 
      if(r.charAt(r.length()-1) == 'R')  
      display.print("REGISTERED", 4);      
      while (c.available()) char y = c.read();
      c.flush();
    }
  }
  else
  {
    status = "OFFLINE";
    if (disp == true)
    {
      display.begin();
      display.print(status, 0);
      char ip[20];
      WiFi.localIP().toString().toCharArray(ip, WiFi.localIP().toString().length()+1);
      display.print(ip,2);
      disp = false;
    }
  }
}
