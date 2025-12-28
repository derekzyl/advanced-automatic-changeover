# System Architecture

Comprehensive architectural documentation for the Advanced Automatic Changeover Switch system.

## 📋 Table of Contents

- [System Overview](#system-overview)
- [Hardware Architecture](#hardware-architecture)
- [Software Architecture](#software-architecture)
- [Communication Architecture](#communication-architecture)
- [Data Flow Architecture](#data-flow-architecture)
- [Security Architecture](#security-architecture)

---

## System Overview

The system consists of three main layers:

```
┌─────────────────────────────────────────┐
│      Presentation Layer                 │
│  (Flutter Mobile/Web Application)       │
└──────────────┬──────────────────────────┘
               │
               │ WiFi / Bluetooth / MQTT
               │
┌──────────────▼──────────────────────────┐
│      Control & Monitoring Layer         │
│  (ESP32 Firmware)                       │
└──────────────┬──────────────────────────┘
               │
               │ GPIO / ADC / I2C / SPI
               │
┌──────────────▼──────────────────────────┐
│      Hardware Layer                     │
│  (Sensors, Contactors, Power)           │
└─────────────────────────────────────────┘
```

---

## Hardware Architecture

### 1. Power Distribution

```
Grid (220V AC) ────┐
                   ├──► [ATS Logic] ────► Load (220V AC)
Generator (220V AC)┘
```

### 2. Control System Architecture

```
┌─────────────────────────────────────────────┐
│           ESP32-C3 Controller               │
│  ┌──────────────────────────────────────┐   │
│  │  Processing Core                     │   │
│  │  - Switching Logic                   │   │
│  │  - Sensor Processing                 │   │
│  │  - Data Logging                      │   │
│  └──────────────────────────────────────┘   │
│  ┌──────────────────────────────────────┐   │
│  │  Communication Module                │   │
│  │  - WiFi (802.11 b/g/n)              │   │
│  │  - Bluetooth Low Energy             │   │
│  │  - MQTT Client                       │   │
│  │  - HTTP Server (REST API)            │   │
│  └──────────────────────────────────────┘   │
│  ┌──────────────────────────────────────┐   │
│  │  I/O Interfaces                      │   │
│  │  - ADC (Voltage/Current Sensors)     │   │
│  │  - GPIO (Contactor Control)          │   │
│  │  - I2C (RTC, Display)                │   │
│  │  - SPI (SD Card)                     │   │
│  └──────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
         │              │              │
    ┌────▼────┐    ┌────▼────┐   ┌────▼────┐
    │ Sensors │    │Storage  │   │Control  │
    │         │    │         │   │         │
    │ Voltage │    │ SD Card │   │Contactors│
    │ Current │    │ RTC     │   │ Relays  │
    └─────────┘    └─────────┘   └─────────┘
```

### 3. Sensor Interface Architecture

```
AC Power Lines
    │
    ├──► ZMPT101B (Grid) ───► ADC ───► ESP32
    │
    ├──► ZMPT101B (Generator) ───► ADC ───► ESP32
    │
    └──► SCT-013 (Load) ───► ADC ───► ESP32
```

**Signal Conditioning:**
- AC signals isolated via transformers
- ADC conversion with 12-bit resolution (0-4095)
- Software filtering for noise reduction
- Calibration constants stored in EEPROM

### 4. Safety Architecture

```
┌─────────────────────────────────────────┐
│      Safety Layer                       │
│  ┌───────────────────────────────────┐  │
│  │  Hardware Interlocking            │  │
│  │  - Mechanical interlock           │  │
│  │  - Electrical interlock circuit   │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │  Software Protection              │  │
│  │  - Dead-time delay                │  │
│  │  - Overcurrent detection          │  │
│  │  - Undervoltage protection        │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │  Isolation                        │  │
│  │  - Optocouplers                   │  │
│  │  - Isolation transformers         │  │
│  │  - Galvanic isolation             │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

---

## Software Architecture

### 1. Firmware Architecture (ESP32)

```
┌─────────────────────────────────────────┐
│         Main Application                │
│  ┌───────────────────────────────────┐  │
│  │  Control Loop                     │  │
│  │  - Monitor sensors                │  │
│  │  - Execute switching logic        │  │
│  │  - Update data logs               │  │
│  │  - Handle communications          │  │
│  └───────────────────────────────────┘  │
└───────────┬─────────────────────────────┘
            │
    ┌───────┴───────┬───────────┬────────────┐
    │               │           │            │
┌───▼────┐  ┌──────▼───┐  ┌───▼────┐  ┌───▼────┐
│Sensor  │  │Switching │  │Data    │  │Network │
│Manager │  │Logic     │  │Logger  │  │Manager │
│        │  │          │  │        │  │        │
│Read    │  │Priority  │  │SD Card │  │WiFi    │
│Filter  │  │Safety    │  │RTC     │  │MQTT    │
│Calib.  │  │Interlock │  │Flash   │  │HTTP    │
└────────┘  └──────────┘  └────────┘  └────────┘
```

### 2. Firmware Module Structure

```cpp
// Core Modules
- sensor_manager.h/cpp      // Sensor reading and calibration
- switching_controller.h/cpp // Switching logic and safety
- data_logger.h/cpp         // Data logging to SD/flash
- network_manager.h/cpp     // WiFi, MQTT, HTTP
- config_manager.h/cpp      // Configuration management
- rtc_manager.h/cpp         // Real-time clock operations
- safety_monitor.h/cpp      // Safety checks and protections
```

### 3. Mobile App Architecture (Flutter)

```
┌─────────────────────────────────────────┐
│      Flutter Application                │
│  ┌───────────────────────────────────┐  │
│  │  UI Layer (Widgets)               │  │
│  │  - Dashboard                      │  │
│  │  - Charts & Graphs                │  │
│  │  - Controls                       │  │
│  │  - Settings                       │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │  State Management (Provider)      │  │
│  │  - Power Status State             │  │
│  │  - Data Logs State                │  │
│  │  - Settings State                 │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │  Business Logic Layer             │  │
│  │  - MQTT Service                   │  │
│  │  - API Service                    │  │
│  │  - Data Processing                │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

### 4. Flutter App Module Structure

```dart
lib/
├── models/              // Data models
│   ├── power_status.dart
│   ├── data_log.dart
│   └── event.dart
├── services/            // Business logic
│   ├── mqtt_service.dart
│   ├── api_service.dart
│   └── data_service.dart
├── providers/           // State management
│   ├── power_provider.dart
│   └── settings_provider.dart
├── screens/             // UI screens
│   ├── dashboard_screen.dart
│   ├── logs_screen.dart
│   └── settings_screen.dart
└── widgets/             // Reusable widgets
    ├── voltage_gauge.dart
    └── power_chart.dart
```

---

## Communication Architecture

### 1. Communication Protocols

```
┌─────────────────────────────────────────┐
│      Communication Stack                │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │  Application Layer                │  │
│  │  - MQTT (Pub/Sub)                 │  │
│  │  - HTTP REST API                  │  │
│  │  - Bluetooth GATT                 │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │  Transport Layer                  │  │
│  │  - TCP/IP (WiFi)                  │  │
│  │  - BLE (Bluetooth)                │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │  Physical Layer                   │  │
│  │  - 802.11 WiFi                    │  │
│  │  - Bluetooth 5.0                  │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

### 2. MQTT Topic Structure

```
changeover/
├── status/              # Status updates (published by ESP32)
│   ├── power_source     # Current source (GRID/GENERATOR)
│   ├── voltages         # Grid and Generator voltages
│   ├── current          # Load current
│   └── power            # Calculated power
├── control/             # Control commands (published by app)
│   ├── switch_source    # Manual switch command
│   └── settings         # Configuration updates
└── events/              # Event notifications
    ├── switch_event     # Switching events
    ├── fault            # Fault detection
    └── alert            # Alert messages
```

### 3. REST API Endpoints

```
GET  /api/status         # Get current system status
GET  /api/history        # Get historical data logs
GET  /api/events         # Get event log
POST /api/control        # Send control command
GET  /api/config         # Get configuration
POST /api/config         # Update configuration
```

### 4. Data Format (JSON)

```json
{
  "timestamp": "2026-01-15T10:30:00Z",
  "source": "GRID",
  "grid_voltage": 220.5,
  "generator_voltage": 0.0,
  "load_current": 15.2,
  "load_power": 3344.0,
  "status": "NORMAL",
  "uptime": 86400
}
```

---

## Data Flow Architecture

### 1. Real-Time Monitoring Flow

```
Sensors (AC) ──► ADC ──► ESP32 Processing ──► Data Logger
                                      │
                                      ├──► MQTT ──► Mobile App
                                      │
                                      └──► HTTP API ──► Web Dashboard
```

### 2. Control Command Flow

```
Mobile App ──► MQTT/HTTP ──► ESP32 ──► Safety Check ──► Contactor Control
                                                  │
                                                  └──► Feedback ──► App
```

### 3. Data Logging Flow

```
Sensor Reading ──► Process ──► Add Timestamp (RTC) ──► Format Data
                                                              │
                                                              ├──► SD Card (CSV)
                                                              ├──► Internal Flash (JSON)
                                                              └──► Cloud (Optional)
```

### 4. Event Processing Flow

```
Event Detection (Switch, Fault, Alert)
    │
    ├──► Log to SD Card
    ├──► Update Internal State
    ├──► Publish via MQTT
    └──► Trigger Notification (if critical)
```

---

## Security Architecture

### 1. Network Security

```
┌─────────────────────────────────────────┐
│      Security Measures                  │
│  ┌───────────────────────────────────┐  │
│  │  Authentication                   │  │
│  │  - WPA2/WPA3 WiFi                 │  │
│  │  - MQTT Username/Password         │  │
│  │  - API Token Authentication       │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │  Encryption                       │  │
│  │  - TLS/SSL for MQTT               │  │
│  │  - HTTPS for REST API             │  │
│  │  - Encrypted SD Card (Optional)   │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │  Access Control                   │  │
│  │  - Firewall Rules                 │  │
│  │  - Rate Limiting                  │  │
│  │  - Command Validation             │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

### 2. Safety & Validation

- Input validation for all commands
- Range checking for sensor values
- Timeout mechanisms for communications
- Watchdog timer for system reliability
- Secure boot (if supported by ESP32)

---

## System States & State Machine

### 1. Power Source States

```
        ┌─────────┐
        │  NONE   │ (Initial/Error State)
        └────┬────┘
             │
    ┌────────┴────────┐
    │                 │
┌───▼────┐      ┌─────▼─────┐
│  GRID  │◄────►│ GENERATOR │
└────────┘      └───────────┘
```

**State Transitions:**
- `NONE → GRID`: When grid voltage > threshold
- `GRID → GENERATOR`: When grid voltage < threshold AND generator available
- `GENERATOR → GRID`: When grid restored AND stable for configured time
- `GRID → NONE`: When both sources fail
- `GENERATOR → NONE`: When generator fails

### 2. System Operational States

```
BOOT → INITIALIZE → CONNECTING → RUNNING → ERROR → RECOVERY
                                        │           │
                                        └───────────┘
```

---

## Performance Characteristics

### Timing Requirements

| Operation | Target Time | Notes |
|-----------|-------------|-------|
| Sensor Reading | 100ms | Main loop period |
| Switching Time | 300-500ms | Including dead-time |
| MQTT Publish | <1s | Network dependent |
| Data Log Write | <100ms | SD card write |
| Display Update | 1s | Mobile app refresh rate |

### Resource Usage

| Resource | Usage | Notes |
|----------|-------|-------|
| Flash Memory | ~500KB | Firmware + logs |
| RAM | ~50KB | Runtime variables |
| SD Card | Variable | Data logs (1MB/day typical) |
| Network Bandwidth | ~1KB/s | MQTT traffic |

---

**Last Updated**: [Current Date]
**Version**: 1.0

