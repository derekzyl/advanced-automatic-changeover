# Firmware Implementation

ESP32 firmware for the Advanced Automatic Changeover Switch.

## Configuration

Before uploading, edit `src/config.h` and update:

1. **WiFi Credentials:**
   ```cpp
   #define WIFI_SSID "YOUR_WIFI_SSID"
   #define WIFI_PASSWORD "YOUR_WIFI_PASSWORD"
   ```

2. **MQTT Broker:**
   ```cpp
   #define MQTT_BROKER "192.168.1.100"
   #define MQTT_PORT 1883
   ```

3. **Pin Definitions:** Adjust if using different ESP32 board or pin assignments

4. **Voltage Thresholds:** Adjust based on your requirements
   ```cpp
   #define VOLTAGE_THRESHOLD_LOW 180.0
   #define VOLTAGE_THRESHOLD_HIGH 200.0
   ```

## Building and Uploading

```bash
# Install dependencies
pio pkg install

# Build
pio run -e esp32-c3-devkitc-02

# Upload
pio run -e esp32-c3-devkitc-02 -t upload

# Monitor serial output
pio device monitor
```

## Features

- ✅ Automatic switching between Grid and Generator
- ✅ Real-time voltage and current monitoring
- ✅ Data logging to SD card
- ✅ MQTT communication
- ✅ WiFi connectivity
- ✅ Safety interlocking
- ✅ Event logging

## Serial Monitor Output

The firmware outputs detailed information via serial monitor:
- System initialization status
- Sensor readings
- Switching events
- MQTT connection status
- Error messages

## Troubleshooting

1. **WiFi not connecting:** Check SSID and password in config.h
2. **MQTT not connecting:** Verify broker IP and port
3. **SD card not detected:** Check CS pin and wiring
4. **Incorrect sensor readings:** Calibrate sensors (adjust scale factors)

