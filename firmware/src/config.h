#ifndef CONFIG_H
#define CONFIG_H

// WiFi Configuration
#define WIFI_SSID "YOUR_WIFI_SSID"
#define WIFI_PASSWORD "YOUR_WIFI_PASSWORD"

// MQTT Configuration
#define MQTT_BROKER "192.168.1.100"
#define MQTT_PORT 1883
#define MQTT_CLIENT_ID "changeover_esp32"

// Pin Definitions
#define GRID_VOLTAGE_PIN 34
#define GEN_VOLTAGE_PIN 35
#define LOAD_CURRENT_PIN 32
#define GRID_CONTACTOR_PIN 25
#define GEN_CONTACTOR_PIN 26
#define LED_PIN 2
#define BUZZER_PIN 4

// Voltage Thresholds
#define VOLTAGE_THRESHOLD_LOW 180.0   // Switch from grid when below (V)
#define VOLTAGE_THRESHOLD_HIGH 200.0  // Switch to grid when above (V)
#define SWITCH_DELAY_MS 300           // Dead-time delay (ms)
#define GRID_STABLE_TIME_MS 5000      // Time before switching back to grid (ms)

// Sensor Calibration
#define VOLTAGE_SENSOR_SCALE 100.0    // Calibration factor for voltage sensors
#define CURRENT_SENSOR_SCALE 30.0     // Calibration factor for current sensor (30A model)
#define BURDEN_RESISTOR 33.0          // Burden resistor value (ohms)

// Data Logging
#define LOG_INTERVAL_MS 1000          // Log data every second
#define SD_CS_PIN 5                   // SD card chip select pin

// MQTT Topics
#define MQTT_TOPIC_STATUS "changeover/status"
#define MQTT_TOPIC_CONTROL "changeover/control"
#define MQTT_TOPIC_EVENTS "changeover/events"

#endif

