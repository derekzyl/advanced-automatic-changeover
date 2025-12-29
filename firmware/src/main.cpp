#include <Arduino.h>
#include <WiFi.h>
#include <PubSubClient.h>
#include <RTClib.h>
#include <SD.h>
#include <SPI.h>
#include <ArduinoJson.h>
#include "config.h"

// Global Objects
RTC_DS3231 rtc;
WiFiClient espClient;
PubSubClient mqttClient(espClient);

// State Variables
enum PowerSource { GRID, GENERATOR, NONE };
PowerSource currentSource = NONE;
PowerSource previousSource = NONE;

unsigned long lastSwitchTime = 0;
unsigned long gridRestoreTime = 0;
unsigned long lastLogTime = 0;
unsigned long lastMqttPublish = 0;
unsigned long systemUptime = 0;

// Sensor Values
float gridVoltage = 0.0;
float genVoltage = 0.0;
float loadCurrent = 0.0;
float loadPower = 0.0;

// Function Declarations
void initPins();
void initRTC();
void initSD();
void initWiFi();
void initMQTT();
void checkInitialState();
float readVoltage(int pin);
float readCurrent(int pin);
void switchToSource(PowerSource source);
void monitorPowerSources();
void updateDataLog();
void logEvent(const char* event);
void handleMQTT();
void mqttCallback(char* topic, byte* payload, unsigned int length);
void publishStatus();
void reconnectMQTT();
bool isGridStable();
bool isGeneratorAvailable();

void setup() {
    Serial.begin(115200);
    delay(1000);
    
    Serial.println("\n=== Advanced Automatic Changeover Switch ===");
    Serial.println("Initializing system...");
    
    initPins();
    initRTC();
    initSD();
    initWiFi();
    initMQTT();
    checkInitialState();
    
    Serial.println("System initialized successfully!");
    Serial.println("Starting main loop...\n");
}

void loop() {
    // Main control loop - runs every 100ms
    unsigned long currentTime = millis();
    
    // Monitor power sources and handle switching
    monitorPowerSources();
    
    // Update data log every second
    if (currentTime - lastLogTime >= LOG_INTERVAL_MS) {
        updateDataLog();
        lastLogTime = currentTime;
    }
    
    // Publish MQTT status every second
    if (currentTime - lastMqttPublish >= 1000) {
        publishStatus();
        lastMqttPublish = currentTime;
    }
    
    // Handle MQTT
    if (!mqttClient.connected()) {
        reconnectMQTT();
    }
    mqttClient.loop();
    
    // Update system uptime
    systemUptime = currentTime / 1000;
    
    delay(100); // 100ms main loop delay
}

void initPins() {
    pinMode(GRID_CONTACTOR_PIN, OUTPUT);
    pinMode(GEN_CONTACTOR_PIN, OUTPUT);
    pinMode(LED_PIN, OUTPUT);
    pinMode(BUZZER_PIN, OUTPUT);
    
    // Ensure both contactors are OFF initially
    digitalWrite(GRID_CONTACTOR_PIN, LOW);
    digitalWrite(GEN_CONTACTOR_PIN, LOW);
    digitalWrite(LED_PIN, LOW);
    digitalWrite(BUZZER_PIN, LOW);
    
    Serial.println("Pins initialized");
}

void initRTC() {
    if (!rtc.begin()) {
        Serial.println("RTC not found! Using system time.");
    } else {
        if (rtc.lostPower()) {
            Serial.println("RTC lost power, setting time...");
            rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));
        }
        Serial.println("RTC initialized");
    }
}

void initSD() {
    if (!SD.begin(SD_CS_PIN)) {
        Serial.println("SD card initialization failed!");
    } else {
        Serial.println("SD card initialized");
        
        // Create data.csv header if file doesn't exist
        if (!SD.exists("/data.csv")) {
            File dataFile = SD.open("/data.csv", FILE_WRITE);
            if (dataFile) {
                dataFile.println("timestamp,source,grid_voltage,gen_voltage,load_current,load_power");
                dataFile.close();
            }
        }
        
        // Create events.csv header if file doesn't exist
        if (!SD.exists("/events.csv")) {
            File eventFile = SD.open("/events.csv", FILE_WRITE);
            if (eventFile) {
                eventFile.println("timestamp,event");
                eventFile.close();
            }
        }
    }
}

void initWiFi() {
    WiFi.mode(WIFI_STA);
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    
    Serial.print("Connecting to WiFi");
    int attempts = 0;
    while (WiFi.status() != WL_CONNECTED && attempts < 20) {
        delay(500);
        Serial.print(".");
        attempts++;
    }
    
    if (WiFi.status() == WL_CONNECTED) {
        Serial.println();
        Serial.print("WiFi connected! IP address: ");
        Serial.println(WiFi.localIP());
    } else {
        Serial.println();
        Serial.println("WiFi connection failed!");
    }
}

void initMQTT() {
    mqttClient.setServer(MQTT_BROKER, MQTT_PORT);
    mqttClient.setCallback(mqttCallback);
    reconnectMQTT();
}

void reconnectMQTT() {
    while (!mqttClient.connected()) {
        Serial.print("Attempting MQTT connection...");
        
        if (mqttClient.connect(MQTT_CLIENT_ID)) {
            Serial.println("connected!");
            mqttClient.subscribe(MQTT_TOPIC_CONTROL);
            logEvent("MQTT connected");
        } else {
            Serial.print("failed, rc=");
            Serial.print(mqttClient.state());
            Serial.println(" try again in 5 seconds");
            delay(5000);
        }
    }
}

void mqttCallback(char* topic, byte* payload, unsigned int length) {
    String message = "";
    for (unsigned int i = 0; i < length; i++) {
        message += (char)payload[i];
    }
    
    Serial.print("Message arrived [");
    Serial.print(topic);
    Serial.print("] ");
    Serial.println(message);
    
    if (String(topic) == MQTT_TOPIC_CONTROL) {
        if (message == "GRID") {
            switchToSource(GRID);
        } else if (message == "GENERATOR") {
            switchToSource(GENERATOR);
        } else if (message == "AUTO") {
            // Enable automatic mode (already enabled by default)
            logEvent("Automatic mode enabled");
        }
    }
}

void checkInitialState() {
    Serial.println("Checking initial power state...");
    
    // Read initial voltages
    gridVoltage = readVoltage(GRID_VOLTAGE_PIN);
    genVoltage = readVoltage(GEN_VOLTAGE_PIN);
    
    Serial.print("Grid voltage: ");
    Serial.print(gridVoltage);
    Serial.println(" V");
    
    Serial.print("Generator voltage: ");
    Serial.print(genVoltage);
    Serial.println(" V");
    
    // Determine initial source
    if (gridVoltage > VOLTAGE_THRESHOLD_HIGH) {
        switchToSource(GRID);
        Serial.println("Initial source: GRID");
    } else if (genVoltage > VOLTAGE_THRESHOLD_HIGH) {
        switchToSource(GENERATOR);
        Serial.println("Initial source: GENERATOR");
    } else {
        switchToSource(NONE);
        Serial.println("Initial source: NONE (both sources unavailable)");
    }
}

float readVoltage(int pin) {
    int adcValue = analogRead(pin);
    float voltage = (adcValue / 4095.0) * 3.3; // ESP32 ADC is 0-3.3V
    
    // ZMPT101B calibration: 2.5V is zero point, 250V AC = 5V DC
    float acVoltage = abs(voltage - 1.65) * (250.0 / 1.65) * VOLTAGE_SENSOR_SCALE / 100.0;
    
    return acVoltage;
}

float readCurrent(int pin) {
    int adcValue = analogRead(pin);
    float voltage = (adcValue / 4095.0) * 3.3; // ESP32 ADC is 0-3.3V
    
    // SCT-013 calibration with 33Ω burden resistor
    // 1V per 30A for 30A model
    float current = abs(voltage - 1.65) / BURDEN_RESISTOR * CURRENT_SENSOR_SCALE;
    
    return current;
}

bool isGridStable() {
    float voltage = readVoltage(GRID_VOLTAGE_PIN);
    return (voltage > VOLTAGE_THRESHOLD_HIGH);
}

bool isGeneratorAvailable() {
    float voltage = readVoltage(GEN_VOLTAGE_PIN);
    return (voltage > VOLTAGE_THRESHOLD_HIGH);
}

void switchToSource(PowerSource source) {
    // Safety: Ensure dead time
    unsigned long currentTime = millis();
    if (currentTime - lastSwitchTime < SWITCH_DELAY_MS) {
        return;
    }
    
    // Don't switch if already on desired source
    if (currentSource == source) {
        return;
    }
    
    Serial.print("Switching from ");
    switch (currentSource) {
        case GRID: Serial.print("GRID"); break;
        case GENERATOR: Serial.print("GENERATOR"); break;
        case NONE: Serial.print("NONE"); break;
    }
    Serial.print(" to ");
    switch (source) {
        case GRID: Serial.print("GRID"); break;
        case GENERATOR: Serial.print("GENERATOR"); break;
        case NONE: Serial.print("NONE"); break;
    }
    Serial.println();
    
    // Turn off both contactors first (safety interlock)
    digitalWrite(GRID_CONTACTOR_PIN, LOW);
    digitalWrite(GEN_CONTACTOR_PIN, LOW);
    delay(SWITCH_DELAY_MS); // Dead-time delay
    
    // Switch to desired source
    previousSource = currentSource;
    currentSource = source;
    
    if (source == GRID) {
        digitalWrite(GRID_CONTACTOR_PIN, HIGH);
        logEvent("Switched to GRID");
    } else if (source == GENERATOR) {
        digitalWrite(GEN_CONTACTOR_PIN, HIGH);
        logEvent("Switched to GENERATOR");
    } else {
        logEvent("Both sources OFF");
    }
    
    lastSwitchTime = currentTime;
    
    // Visual feedback
    digitalWrite(LED_PIN, (source != NONE) ? HIGH : LOW);
}

void monitorPowerSources() {
    // Read sensor values
    gridVoltage = readVoltage(GRID_VOLTAGE_PIN);
    genVoltage = readVoltage(GEN_VOLTAGE_PIN);
    loadCurrent = readCurrent(LOAD_CURRENT_PIN);
    loadPower = gridVoltage * loadCurrent; // Approximate power calculation
    
    // Automatic switching logic
    if (isGridStable()) {
        // Grid is available and stable
        if (currentSource == GENERATOR) {
            // Currently on generator, check if we should switch back
            if (millis() - gridRestoreTime > GRID_STABLE_TIME_MS) {
                switchToSource(GRID);
            }
        } else if (currentSource == NONE) {
            // No source active, switch to grid
            switchToSource(GRID);
            gridRestoreTime = millis();
        } else {
            // Already on grid, update restore time
            gridRestoreTime = millis();
        }
    } else {
        // Grid failed
        if (currentSource == GRID) {
            gridRestoreTime = 0; // Reset restore timer
            
            // Check if generator is available
            if (isGeneratorAvailable()) {
                switchToSource(GENERATOR);
            } else {
                switchToSource(NONE);
                logEvent("POWER FAILURE - Both sources down");
            }
        } else if (currentSource == NONE && isGeneratorAvailable()) {
            // Generator became available
            switchToSource(GENERATOR);
        }
    }
    
    // Overcurrent protection (optional - adjust threshold as needed)
    if (loadCurrent > 20.0 && currentSource != NONE) {
        Serial.println("WARNING: Overcurrent detected!");
        // Could implement automatic shutdown here if needed
    }
}

void updateDataLog() {
    DateTime now = rtc.now();
    
    // Log to SD card
    File logFile = SD.open("/data.csv", FILE_WRITE);
    if (logFile) {
        logFile.print(now.timestamp());
        logFile.print(",");
        
        switch (currentSource) {
            case GRID: logFile.print("GRID"); break;
            case GENERATOR: logFile.print("GENERATOR"); break;
            case NONE: logFile.print("NONE"); break;
        }
        
        logFile.print(",");
        logFile.print(gridVoltage);
        logFile.print(",");
        logFile.print(genVoltage);
        logFile.print(",");
        logFile.print(loadCurrent);
        logFile.print(",");
        logFile.println(loadPower);
        
        logFile.close();
    }
}

void logEvent(const char* event) {
    DateTime now = rtc.now();
    
    // Log to serial
    Serial.print("[EVENT] ");
    Serial.print(now.timestamp());
    Serial.print(" - ");
    Serial.println(event);
    
    // Log to SD card
    File eventFile = SD.open("/events.csv", FILE_WRITE);
    if (eventFile) {
        eventFile.print(now.timestamp());
        eventFile.print(",");
        eventFile.println(event);
        eventFile.close();
    }
    
    // Publish to MQTT
    StaticJsonDocument<200> doc;
    doc["timestamp"] = now.timestamp();
    doc["event_type"] = "SWITCH";
    doc["event_data"]["message"] = event;
    
    char buffer[200];
    serializeJson(doc, buffer);
    mqttClient.publish(MQTT_TOPIC_EVENTS, buffer);
}

void publishStatus() {
    DateTime now = rtc.now();
    
    StaticJsonDocument<300> doc;
    doc["timestamp"] = now.timestamp();
    
    switch (currentSource) {
        case GRID: doc["source"] = "GRID"; break;
        case GENERATOR: doc["source"] = "GENERATOR"; break;
        case NONE: doc["source"] = "NONE"; break;
    }
    
    doc["grid_voltage"] = gridVoltage;
    doc["generator_voltage"] = genVoltage;
    doc["load_current"] = loadCurrent;
    doc["load_power"] = loadPower;
    doc["status"] = "NORMAL";
    doc["uptime"] = systemUptime;
    
    char buffer[300];
    serializeJson(doc, buffer);
    mqttClient.publish(MQTT_TOPIC_STATUS, buffer);
}
