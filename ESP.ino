#include <Arduino.h>
#include <WiFi.h>
#include <PubSubClient.h>
#include <HardwareSerial.h>
#include <Firebase_ESP_Client.h>
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"

HardwareSerial SerialPort(2);

#define DATABASE_URL "https://automatic-watering-syste-7cda0-default-rtdb.asia-southeast1.firebasedatabase.app/"
#define API_KEY "AIzaSyA6i5BtnHWafDCPNUHmerifr_O6La_wKa4"
#define SSID "2022-CS-56/ssid"
#define PASSWORD "2022-CS-56/password"
#define USER_EMAIL "arduinotesting32@gmail.com"
#define USER_PASSWORD "Temporary_Password"

const char* mqttServer = "broker.mqtt.cool";
const int mqttPort = 1883;
String receivedValue = "-1";
String uid;
String mode = "LCD";

WiFiClient espClient;
WiFiClient thinkClient;
PubSubClient client(espClient);
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

void setup() {
  Serial.begin(115200);
  SerialPort.begin(9600, SERIAL_8N1, 17, 16);
  connectToWiFi();
  connectToMQTT();
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;
  Firebase.reconnectWiFi(true);
  config.token_status_callback = tokenStatusCallback;
  config.max_token_generation_retry = 5;
  Firebase.begin(&config, &auth);
  Serial.println("Getting User UID");
  while ((auth.token.uid) == "") {
    Serial.print('.');
    delay(1000);
  }
  // Print user UID
  uid = auth.token.uid.c_str();
  Serial.print("User UID: ");
  Serial.println(uid);
}
void connectToWiFi() {
  WiFi.begin(SSID, PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to WiFi");
}

void connectToMQTT() {
  client.setServer(mqttServer, mqttPort);

  while (!client.connected()) {
    Serial.println("Connecting to MQTT...");
    if (client.connect("2022-CS-17/esp/esp-controller")) {
      Serial.println("Connected to MQTT");
    } else {
      Serial.print("Failed with state ");
      Serial.println(client.state());
      delay(2000);
    }
  }
  client.subscribe("2022-CS-17/esp/button");
  client.setCallback(callback);
}

void publishMessage(char* mqttTopic, char* message) {
  if (client.connected()) {
    client.publish(mqttTopic, message);
    Serial.println("Message published to MQTT");
  } else {
    Serial.println("Failed to publish message. Reconnecting to MQTT...");
    connectToMQTT(); // Reconnect to MQTT
    if (client.connected()) {
      client.publish(mqttTopic, message);
      Serial.println("Message published to MQTT");
    } else {
      Serial.print("Failed to reconnect with state ");
      Serial.println(client.state());
    }
  }
}
void writeToFireBase(String button) {
    if (Firebase.ready()) {
    Firebase.RTDB.setString(&fbdo, "/Button/Pressed", button);
  }
} 
void callback(char* topic, byte* payload, unsigned int length) {
  String topicStr = topic;
  String payloadStr(reinterpret_cast<char*>(payload), length);
  Serial.println(topicStr);
  Serial.println(payloadStr);
  char buttonPressed = payloadStr.charAt(0);
  SerialPort.print(buttonPressed);
  if (buttonPressed == '5') {
    if (mode == "LCD") {
      mode = "FireBase";
    } else {
      mode = "LCD";
    }
  } else {
    if (mode == "FireBase") {
      writeToFireBase(payloadStr);
    }
  }
}

void loop() {
  client.loop();
}
