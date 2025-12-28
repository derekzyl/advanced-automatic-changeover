# Setup Guide

Step-by-step setup instructions for the Advanced Automatic Changeover Switch system.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Hardware Setup](#hardware-setup)
- [Firmware Setup](#firmware-setup)
- [Mobile App Setup](#mobile-app-setup)
- [Configuration](#configuration)
- [Initial Testing](#initial-testing)

---

## Prerequisites

### Required Software

- **PlatformIO** (VS Code extension or standalone)
- **Flutter SDK** (3.9.2 or higher)
- **Arduino IDE** (optional, for reference)
- **Serial Terminal** (PuTTY, minicom, or PlatformIO monitor)

### Required Hardware

See [BOM.md](BOM.md) for complete component list.

---

## Hardware Setup

### Step 1: Assemble Components

1. **Mount Contactors** in enclosure on DIN rail or direct mounting
2. **Install ESP32** development board in low-voltage section
3. **Connect Power Supply** (isolation transformer + AC-DC converter)
4. **Wire Sensors** according to [HARDWARE.md](HARDWARE.md) schematics

### Step 2: Wire High-Voltage Section

⚠️ **WARNING:** Only qualified electricians should perform high-voltage wiring.

1. **Grid Input:**
   - Connect L (Live) through fuse to Grid Contactor
   - Connect N (Neutral) to common neutral bus
   - Connect E (Earth) to earth terminal

2. **Generator Input:**
   - Connect L (Live) through fuse to Generator Contactor
   - Connect N (Neutral) to common neutral bus
   - Connect E (Earth) to earth terminal

3. **Load Output:**
   - Connect both contactor outputs to Load L
   - Connect neutral bus to Load N
   - Connect earth terminal to Load E

### Step 3: Wire Control Circuit

1. **Connect Sensors:**
   - Grid voltage sensor → ESP32 GPIO 34
   - Generator voltage sensor → ESP32 GPIO 35
   - Load current sensor → ESP32 GPIO 32

2. **Connect Control Outputs:**
   - ESP32 GPIO 25 → Grid contactor (via optocoupler)
   - ESP32 GPIO 26 → Generator contactor (via optocoupler)

3. **Connect Peripherals:**
   - RTC module → I2C (GPIO 14/27)
   - SD card module → SPI (GPIO 5/18/19/23)

4. **Connect Power:**
   - 5V power supply to ESP32 and sensors
   - Verify all grounds connected

---

## Firmware Setup

### Step 1: Install PlatformIO

```bash
# Install VS Code extension: PlatformIO IDE
# Or install standalone PlatformIO Core
pip install platformio
```

### Step 2: Clone/Open Project

```bash
cd firmware
# Edit platformio.ini if using different ESP32 board
```

### Step 3: Install Dependencies

```bash
pio pkg install
# Or manually edit platformio.ini to add libraries
```

### Step 4: Configure WiFi Credentials

Edit `src/main.cpp` or create `src/config.h`:

```cpp
#define WIFI_SSID "Your_WiFi_SSID"
#define WIFI_PASSWORD "Your_WiFi_Password"
#define MQTT_BROKER "192.168.1.100"  // MQTT broker IP
```

### Step 5: Upload Firmware

```bash
# Build and upload
pio run -e esp32-c3-devkitc-02 -t upload

# Monitor serial output
pio device monitor
```

### Step 6: Verify Operation

1. Check serial monitor for initialization messages
2. Verify WiFi connection status
3. Test sensor readings
4. Verify contactor control

---

## Mobile App Setup

### Step 1: Install Flutter

```bash
# Follow Flutter installation guide for your OS
# https://flutter.dev/docs/get-started/install
flutter --version  # Verify installation
```

### Step 2: Install Dependencies

```bash
cd change_over_app
flutter pub get
```

### Step 3: Configure Connection

Edit `lib/services/mqtt_service.dart`:

```dart
final client = MqttServerClient.withPort('192.168.1.100', 'flutter_client', 1883);
```

Or create configuration file for easy updates.

### Step 4: Run Application

```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For Web
flutter run -d chrome
```

### Step 5: Build Release

```bash
# Android APK
flutter build apk --release

# iOS (requires Mac and Xcode)
flutter build ios --release
```

---

## Configuration

### Firmware Configuration

**Voltage Thresholds** (`src/main.cpp`):
```cpp
#define VOLTAGE_THRESHOLD_LOW 180   // Switch from grid when below
#define VOLTAGE_THRESHOLD_HIGH 200  // Switch to grid when above
#define SWITCH_DELAY_MS 300         // Dead-time delay
#define GRID_STABLE_TIME_MS 5000    // Time before switching back
```

**MQTT Topics**:
- Status: `changeover/status`
- Control: `changeover/control`
- Events: `changeover/events`

### App Configuration

Edit settings in mobile app:
- MQTT broker address
- Update interval
- Notification preferences
- Chart display options

---

## Initial Testing

### 1. Power Supply Test

- Verify 5V output with multimeter
- Check isolation between AC and DC sections

### 2. Sensor Test

- Connect known AC source
- Read values via serial monitor
- Calibrate if needed

### 3. Contactor Test

- Manually trigger via GPIO
- Verify contactor closes
- Test interlocking

### 4. Integration Test

- Power on system
- Connect test loads
- Simulate grid failure
- Verify automatic switching

### 5. Communication Test

- Verify WiFi connection
- Test MQTT publish/subscribe
- Check mobile app connectivity

---

## Troubleshooting

### Common Issues

**ESP32 not connecting to WiFi:**
- Check SSID and password
- Verify router compatibility (2.4GHz)
- Check signal strength

**Sensors reading incorrect values:**
- Verify connections
- Check calibration constants
- Test with known voltage/current source

**Contactors not switching:**
- Verify optocoupler connections
- Check GPIO output with multimeter
- Test contactor coil voltage

**SD card not detected:**
- Verify SPI connections
- Check CS pin assignment
- Format SD card as FAT32

For more troubleshooting, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

---

**Last Updated**: [Current Date]
**Version**: 1.0

