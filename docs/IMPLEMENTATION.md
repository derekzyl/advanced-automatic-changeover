# Implementation Guide

Complete step-by-step implementation guide for the Advanced Automatic Changeover Switch system, covering hardware assembly, firmware development, and software integration.

## 📑 Table of Contents

- [Hardware Implementation](#hardware-implementation)
- [Firmware Implementation](#firmware-implementation)
- [Mobile App Implementation](#mobile-app-implementation)
- [Integration & Testing](#integration--testing)
- [Deployment](#deployment)

---

## Hardware Implementation

### 1. Circuit Design

#### 1.1 Power Supply Circuit

```
220V AC Input
    │
    ├─► Fuse (10A)
    │
    ├─► Surge Protector
    │
    ├─► Isolation Transformer (220V/12V)
    │
    └─► AC-DC Converter (12V to 5V)
        │
        ├─► ESP32 (3.3V via onboard regulator)
        ├─► Sensors (5V)
        └─► Relay Modules (5V)
```

**Components:**
- Isolation transformer: 220V/12V, 5VA minimum
- AC-DC converter: 12V input, 5V/2A output
- Capacitors: 100µF and 10µF for filtering

#### 1.2 Voltage Sensing Circuit

**Grid Voltage Sensor (ZMPT101B)**
```
Grid AC (220V) ──► ZMPT101B Primary
                       │
                       └─► Secondary (0-5V DC)
                           │
                           └─► ESP32 ADC (GPIO 34)
```

**Generator Voltage Sensor (ZMPT101B)**
```
Generator AC (220V) ──► ZMPT101B Primary
                            │
                            └─► Secondary (0-5V DC)
                                │
                                └─► ESP32 ADC (GPIO 35)
```

**Calibration:**
- ZMPT101B outputs ~2.5V for 0V AC input (zero-crossing)
- Full scale: ~250V AC → ~5V DC
- Formula: `V_AC = (ADC_value / 4095) * 5.0 * (250 / 2.5)`

#### 1.3 Current Sensing Circuit

**Load Current (SCT-013)**
```
Load AC Line ──► SCT-013 Clamp
                    │
                    └─► Burden Resistor (33Ω)
                        │
                        └─► ESP32 ADC (GPIO 32)
```

**Burden Resistor Calculation:**
- SCT-013: 1V output per 30A (for 30A model)
- Burden resistor: 33Ω recommended
- Formula: `I_AC = (ADC_value / 4095) * 5.0 / 33.0 * 30.0`

#### 1.4 Contactor Control Circuit

```
ESP32 GPIO ──► Optocoupler (PC817)
                  │
                  └─► Transistor (2N2222 or Relay Driver IC)
                      │
                      └─► Contactor Coil (220V AC or 12V DC)
```

**Interlocking Logic:**
- Grid contactor and Generator contactor must NEVER be ON simultaneously
- Implement both electrical and mechanical interlocking
- Add dead-time delay (200-500ms) between switching

**Circuit Diagram:**
```
ESP32 GPIO 25 ──► Opto1 ──► Relay Driver ──► Grid Contactor Coil
ESP32 GPIO 26 ──► Opto2 ──► Relay Driver ──► Generator Contactor Coil

Safety: Mechanical interlock between contactors
```

#### 1.5 Complete Pin Mapping

| ESP32 Pin | Component | Notes |
|-----------|-----------|-------|
| GPIO 34 | Grid Voltage Sensor (ZMPT101B) | ADC1_CH6 (Input only) |
| GPIO 35 | Generator Voltage Sensor (ZMPT101B) | ADC1_CH7 (Input only) |
| GPIO 32 | Load Current Sensor (SCT-013) | ADC1_CH4 |
| GPIO 25 | Grid Contactor Control | Output, via optocoupler |
| GPIO 26 | Generator Contactor Control | Output, via optocoupler |
| GPIO 27 | RTC SDA (I2C) | I2C Data |
| GPIO 14 | RTC SCL (I2C) | I2C Clock |
| GPIO 5 | SD Card CS | SPI Chip Select |
| GPIO 23 | SD Card MOSI | SPI Data Out |
| GPIO 19 | SD Card MISO | SPI Data In |
| GPIO 18 | SD Card SCK | SPI Clock |
| GPIO 2 | Status LED | Output |
| GPIO 4 | Buzzer | Output (PWM) |

**Note**: Pin assignments may vary based on ESP32 variant. Adjust accordingly.

### 2. PCB Layout (Optional)

For production version, design a custom PCB:
- Separate high-voltage and low-voltage sections
- Proper grounding and isolation
- Sufficient trace width for current-carrying paths
- Component placement for easy maintenance

### 3. Enclosure & Assembly

1. **Mount Contactors**: Use DIN rail or direct mounting
2. **Install MCU Board**: Mount ESP32 in low-voltage section
3. **Wire High-Voltage**: Professional electrician recommended
4. **Connect Sensors**: Ensure proper isolation
5. **Test Isolation**: Verify no direct AC connection to MCU

---

## Firmware Implementation

### 1. PlatformIO Setup

**platformio.ini:**
```ini
[env:esp32-c3-devkitc-02]
platform = espressif32
board = esp32-c3-devkitc-02
framework = arduino
monitor_speed = 115200

lib_deps = 
    adafruit/RTClib@^2.1.1
    adafruit/Adafruit GFX Library@^1.11.9
    adafruit/Adafruit SSD1306@^2.5.9
    bblanchon/ArduinoJson@^6.21.3
    knolleary/PubSubClient@^2.8.0
    
build_flags = 
    -DCORE_DEBUG_LEVEL=3
```

### 2. Core Firmware Structure

**main.cpp Structure:**
```cpp
#include <Arduino.h>
#include <WiFi.h>
#include <PubSubClient.h>
#include <RTClib.h>
#include <SD.h>
#include <SPI.h>
#include <ArduinoJson.h>

// Pin Definitions
#define GRID_VOLTAGE_PIN 34
#define GEN_VOLTAGE_PIN 35
#define LOAD_CURRENT_PIN 32
#define GRID_CONTACTOR_PIN 25
#define GEN_CONTACTOR_PIN 26
#define LED_PIN 2

// Constants
#define VOLTAGE_THRESHOLD_LOW 180  // V
#define VOLTAGE_THRESHOLD_HIGH 200  // V
#define SWITCH_DELAY_MS 300         // Dead time
#define GRID_STABLE_TIME_MS 5000    // Time before switching back to grid

// Global Objects
RTC_DS3231 rtc;
WiFiClient espClient;
PubSubClient mqttClient(espClient);

// State Variables
enum PowerSource { GRID, GENERATOR, NONE };
PowerSource currentSource = NONE;
unsigned long lastSwitchTime = 0;
unsigned long gridRestoreTime = 0;

void setup() {
    Serial.begin(115200);
    initPins();
    initRTC();
    initSD();
    initWiFi();
    initMQTT();
    checkInitialState();
}

void loop() {
    monitorPowerSources();
    updateDataLog();
    handleMQTT();
    delay(100); // 100ms main loop
}
```

### 3. Key Functions Implementation

#### 3.1 Voltage Reading
```cpp
float readVoltage(int pin) {
    int adcValue = analogRead(pin);
    float voltage = (adcValue / 4095.0) * 5.0;
    // Calibration: ZMPT101B outputs 2.5V for 0V AC
    float acVoltage = abs(voltage - 2.5) * (250.0 / 2.5);
    return acVoltage;
}
```

#### 3.2 Current Reading
```cpp
float readCurrent(int pin) {
    int adcValue = analogRead(pin);
    float voltage = (adcValue / 4095.0) * 5.0;
    // SCT-013 with 33Ω burden: 1V per 30A
    float current = abs(voltage - 2.5) / 33.0 * 30.0;
    return current;
}
```

#### 3.3 Switching Logic
```cpp
void switchToSource(PowerSource source) {
    // Safety: Ensure dead time
    if (millis() - lastSwitchTime < SWITCH_DELAY_MS) {
        return;
    }
    
    // Turn off both contactors first
    digitalWrite(GRID_CONTACTOR_PIN, LOW);
    digitalWrite(GEN_CONTACTOR_PIN, LOW);
    delay(SWITCH_DELAY_MS);
    
    // Switch to desired source
    if (source == GRID) {
        digitalWrite(GRID_CONTACTOR_PIN, HIGH);
        logEvent("Switched to GRID");
    } else if (source == GENERATOR) {
        digitalWrite(GEN_CONTACTOR_PIN, HIGH);
        logEvent("Switched to GENERATOR");
    }
    
    currentSource = source;
    lastSwitchTime = millis();
}

void monitorPowerSources() {
    float gridVoltage = readVoltage(GRID_VOLTAGE_PIN);
    float genVoltage = readVoltage(GEN_VOLTAGE_PIN);
    
    // Grid available and stable
    if (gridVoltage > VOLTAGE_THRESHOLD_HIGH) {
        if (currentSource == GENERATOR) {
            gridRestoreTime = millis();
            // Wait for stable grid before switching
            if (millis() - gridRestoreTime > GRID_STABLE_TIME_MS) {
                switchToSource(GRID);
            }
        } else if (currentSource == NONE) {
            switchToSource(GRID);
        }
    }
    // Grid failed, switch to generator
    else if (gridVoltage < VOLTAGE_THRESHOLD_LOW) {
        if (genVoltage > VOLTAGE_THRESHOLD_HIGH) {
            switchToSource(GENERATOR);
        } else {
            // Both sources failed
            switchToSource(NONE);
            logEvent("POWER FAILURE - Both sources down");
        }
    }
}
```

#### 3.4 Data Logging
```cpp
void logData() {
    DateTime now = rtc.now();
    float gridVoltage = readVoltage(GRID_VOLTAGE_PIN);
    float genVoltage = readVoltage(GEN_VOLTAGE_PIN);
    float loadCurrent = readCurrent(LOAD_CURRENT_PIN);
    
    File logFile = SD.open("/data.csv", FILE_WRITE);
    if (logFile) {
        logFile.print(now.timestamp());
        logFile.print(",");
        logFile.print(currentSource == GRID ? "GRID" : "GEN");
        logFile.print(",");
        logFile.print(gridVoltage);
        logFile.print(",");
        logFile.print(genVoltage);
        logFile.print(",");
        logFile.print(loadCurrent);
        logFile.println();
        logFile.close();
    }
}

void logEvent(const char* event) {
    DateTime now = rtc.now();
    File eventFile = SD.open("/events.csv", FILE_WRITE);
    if (eventFile) {
        eventFile.print(now.timestamp());
        eventFile.print(",");
        eventFile.println(event);
        eventFile.close();
    }
    Serial.println(event);
}
```

#### 3.5 WiFi & MQTT
```cpp
void initWiFi() {
    WiFi.mode(WIFI_STA);
    WiFi.begin("YOUR_SSID", "YOUR_PASSWORD");
    
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
    }
    
    Serial.println("WiFi connected");
    Serial.println(WiFi.localIP());
}

void initMQTT() {
    mqttClient.setServer("MQTT_BROKER_IP", 1883);
    mqttClient.setCallback(mqttCallback);
}

void mqttCallback(char* topic, byte* payload, unsigned int length) {
    // Handle MQTT commands (e.g., manual switch)
    String message = String((char*)payload);
    
    if (String(topic) == "changeover/control") {
        if (message == "GRID") {
            switchToSource(GRID);
        } else if (message == "GENERATOR") {
            switchToSource(GENERATOR);
        }
    }
}

void publishStatus() {
    StaticJsonDocument<200> doc;
    doc["source"] = currentSource == GRID ? "GRID" : "GENERATOR";
    doc["grid_voltage"] = readVoltage(GRID_VOLTAGE_PIN);
    doc["gen_voltage"] = readVoltage(GEN_VOLTAGE_PIN);
    doc["load_current"] = readCurrent(LOAD_CURRENT_PIN);
    
    char buffer[200];
    serializeJson(doc, buffer);
    mqttClient.publish("changeover/status", buffer);
}
```

### 4. Complete Firmware Features Checklist

- [x] Voltage monitoring (Grid & Generator)
- [x] Current monitoring (Load)
- [x] Automatic switching logic
- [x] Safety interlocking
- [x] Dead-time delay
- [x] Data logging to SD card
- [x] RTC timestamping
- [x] WiFi connectivity
- [x] MQTT communication
- [ ] Bluetooth support
- [ ] Web server (REST API)
- [ ] OTA updates
- [ ] Configuration via web interface

---

## Mobile App Implementation

### 1. Flutter Project Setup

**pubspec.yaml:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  mqtt_client: ^9.10.0
  fl_chart: ^0.65.0
  shared_preferences: ^2.2.2
  intl: ^0.18.1
  provider: ^6.1.1
```

### 2. App Architecture

```
lib/
├── main.dart
├── models/
│   ├── power_status.dart
│   ├── data_log.dart
│   └── event.dart
├── services/
│   ├── mqtt_service.dart
│   ├── api_service.dart
│   └── data_service.dart
├── screens/
│   ├── dashboard_screen.dart
│   ├── logs_screen.dart
│   ├── settings_screen.dart
│   └── control_screen.dart
└── widgets/
    ├── voltage_gauge.dart
    ├── power_chart.dart
    └── status_indicator.dart
```

### 3. Key Implementation

#### 3.1 MQTT Service
```dart
// lib/services/mqtt_service.dart
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTService {
  late MqttServerClient client;
  
  Future<void> connect() async {
    client = MqttServerClient.withPort('YOUR_MQTT_BROKER', 'flutter_client', 1883);
    client.logging(on: true);
    
    try {
      await client.connect();
      client.subscribe('changeover/status', MqttQos.atLeastOnce);
      client.updates?.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
        // Handle updates
      });
    } catch (e) {
      print('MQTT connection error: $e');
    }
  }
  
  void publishCommand(String command) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(command);
    client.publishMessage('changeover/control', MqttQos.atLeastOnce, builder.payload!);
  }
}
```

#### 3.2 Dashboard Screen
```dart
// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mqtt_service.dart';
import '../widgets/voltage_gauge.dart';
import '../widgets/power_chart.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Changeover Status')),
      body: Column(
        children: [
          StatusIndicator(),
          Row(
            children: [
              Expanded(child: VoltageGauge(title: 'Grid', voltage: 220)),
              Expanded(child: VoltageGauge(title: 'Generator', voltage: 220)),
            ],
          ),
          Expanded(child: PowerChart()),
          ControlButtons(),
        ],
      ),
    );
  }
}
```

### 4. Flutter App Features Checklist

- [ ] MQTT connection for real-time data
- [ ] Dashboard with live metrics
- [ ] Voltage and current gauges
- [ ] Power consumption charts
- [ ] Event log viewer
- [ ] Manual control buttons
- [ ] Settings screen
- [ ] Push notifications
- [ ] Data export (CSV/PDF)
- [ ] Offline mode support

---

## Integration & Testing

### 1. Hardware Testing

1. **Power Supply Test**
   - Verify 5V output with multimeter
   - Check isolation between AC and DC sections

2. **Sensor Calibration**
   - Calibrate voltage sensors with known AC source
   - Calibrate current sensor with known load

3. **Contactor Testing**
   - Test individual contactor operation
   - Verify interlocking prevents dual activation
   - Measure switching time and dead-time

### 2. Firmware Testing

1. **Unit Tests**
   - Test voltage/current reading functions
   - Test switching logic
   - Test data logging

2. **Integration Tests**
   - Test complete switching cycle
   - Test WiFi/MQTT connectivity
   - Test SD card logging

### 3. End-to-End Testing

1. **Simulated Power Failure**
   - Disconnect grid power
   - Verify automatic switch to generator
   - Reconnect grid, verify return switch

2. **Mobile App Integration**
   - Test real-time data display
   - Test manual control commands
   - Test data log retrieval

---

## Deployment

### 1. Pre-Deployment Checklist

- [ ] All safety checks completed
- [ ] Electrical connections verified by qualified electrician
- [ ] Firmware tested and stable
- [ ] Mobile app tested on target devices
- [ ] Documentation complete
- [ ] User training materials prepared

### 2. Installation Steps

1. Mount enclosure in appropriate location
2. Install contactors and wiring (qualified electrician)
3. Connect sensors and MCU board
4. Upload firmware to ESP32
5. Configure WiFi credentials
6. Test all functions
7. Install mobile app on user devices
8. Train users on operation

### 3. Maintenance

- Regular inspection of contactors
- Clean sensors periodically
- Check SD card capacity
- Update firmware as needed
- Review data logs for anomalies

---

**Last Updated**: [Current Date]
**Version**: 1.0

