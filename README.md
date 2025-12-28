# Advanced Automatic Changeover Switch with IoT & Data Logging

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: ESP32](https://img.shields.io/badge/Platform-ESP32-blue.svg)](https://www.espressif.com/)
[![Framework: Flutter](https://img.shields.io/badge/Framework-Flutter-02569B.svg)](https://flutter.dev/)

A comprehensive automatic transfer switch (ATS) system that seamlessly switches electrical loads between primary (Grid) and backup (Generator/Inverter) power sources with integrated data logging, IoT monitoring, and mobile app control.

## 🚀 Overview

This project implements an intelligent power management system designed for residential and commercial applications where reliable backup power is critical. The system automatically detects power failures, switches to backup sources, monitors power quality, logs all events, and provides remote monitoring through a Flutter mobile application.

### Key Features

- ✅ **Automatic Source Switching** - Seamless transition between Grid and Generator/Inverter
- ✅ **Real-time Monitoring** - Live voltage, current, and power consumption tracking
- ✅ **Data Logging** - Comprehensive event logging with timestamps and analytics
- ✅ **IoT Integration** - WiFi and Bluetooth connectivity for remote access
- ✅ **Mobile App** - Flutter-based dashboard for monitoring and control
- ✅ **Safety Protection** - Overcurrent, undervoltage, and interlock protection
- ✅ **Energy Analytics** - Power usage tracking and outage reports
- ✅ **Manual Override** - User-controlled source switching when needed

## 📋 Table of Contents

- [Hardware Architecture](#-hardware-architecture)
- [Software Components](#-software-components)
- [Quick Start](#-quick-start)
- [Documentation](#-documentation)
- [Project Structure](#-project-structure)
- [Safety & Compliance](#-safety--compliance)
- [Contributing](#-contributing)
- [License](#-license)

## 🏗️ Hardware Architecture

```
┌─────────────────┐
│   Grid Power    │
│  (220V AC)      │
└────────┬────────┘
         │
         ├─────────────────┐
         │                 │
┌────────▼────────┐   ┌────▼──────────────┐
│  Contactors     │   │  Contactors       │
│  (Grid Side)    │   │  (Generator Side) │
└────────┬────────┘   └────┬──────────────┘
         │                 │
         └────────┬────────┘
                  │
         ┌────────▼────────┐
         │   Load Panel    │
         │  (220V AC)      │
         └────────┬────────┘
                  │
         ┌────────▼────────────────────────┐
         │     ESP32 Controller            │
         │  ┌──────────────────────────┐   │
         │  │  Voltage Sensors         │   │
         │  │  Current Sensors (CT)    │   │
         │  │  RTC Module              │   │
         │  │  SD Card (Data Logger)   │   │
         │  │  WiFi/Bluetooth          │   │
         │  └──────────────────────────┘   │
         └─────────────────────────────────┘
                  │
         ┌────────▼────────┐
         │  Flutter App    │
         │  (Mobile/Web)   │
         └─────────────────┘
```

### Core Components

- **ESP32-C3** - Main microcontroller with WiFi and Bluetooth
- **AC Voltage Sensors (ZMPT101B)** - Grid and Generator voltage monitoring
- **Current Transformers (SCT-013)** - Load current measurement
- **Contactors** - High-voltage switching (electrically and mechanically interlocked)
- **RTC Module (DS3231)** - Accurate timestamping for data logs
- **MicroSD Card** - Local data storage
- **Optocouplers** - Electrical isolation for safety

See [BOM.md](docs/BOM.md) for complete component list and specifications.

## 💻 Software Components

### 1. Firmware (ESP32)
- **Platform**: PlatformIO with Arduino Framework
- **Key Features**:
  - Automatic switching logic with safety interlocks
  - Real-time voltage and current monitoring
  - Data logging to SD card and internal flash
  - WiFi (MQTT/REST API) and Bluetooth communication
  - Power quality analysis
  - Fault detection and protection

### 2. Mobile Application (Flutter)
- **Platform**: iOS, Android, Web
- **Key Features**:
  - Live dashboard with real-time power metrics
  - Historical data visualization
  - Manual source switching controls
  - Outage and event history
  - Push notifications for critical events
  - Energy consumption analytics

See [IMPLEMENTATION.md](docs/IMPLEMENTATION.md) for detailed implementation guide.

## 🚀 Quick Start

### Prerequisites

- PlatformIO IDE or VS Code with PlatformIO extension
- Flutter SDK (3.9.2 or higher)
- ESP32-C3 DevKit or compatible board
- Hardware components (see [BOM.md](docs/BOM.md))

### Firmware Setup

```bash
cd firmware
pio install
pio run -e esp32-c3-devkitc-02
pio run -e esp32-c3-devkitc-02 -t upload
```

### Flutter App Setup

```bash
cd change_over_app
flutter pub get
flutter run
```

For detailed setup instructions, see [SETUP.md](docs/SETUP.md).

## 📚 Documentation

Comprehensive documentation is available in the `docs/` directory:

- **[BOM.md](docs/BOM.md)** - Complete Bill of Materials with component specifications and suppliers
- **[IMPLEMENTATION.md](docs/IMPLEMENTATION.md)** - Detailed implementation guide for hardware, firmware, and software
- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** - System architecture and design decisions
- **[HARDWARE.md](docs/HARDWARE.md)** - Hardware design, schematics, and PCB layout
- **[SETUP.md](docs/SETUP.md)** - Step-by-step setup and installation guide
- **[API.md](docs/API.md)** - Communication protocol and API documentation
- **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** - Common issues and solutions

## 📁 Project Structure

```
advanced-automatic-changeover/
│
├── firmware/              # ESP32 firmware (PlatformIO)
│   ├── src/
│   │   └── main.cpp      # Main firmware code
│   ├── include/          # Header files
│   ├── lib/              # Libraries
│   └── platformio.ini    # PlatformIO configuration
│
├── change_over_app/      # Flutter mobile application
│   ├── lib/
│   │   └── main.dart     # App entry point
│   ├── android/          # Android-specific files
│   ├── ios/              # iOS-specific files
│   └── pubspec.yaml      # Flutter dependencies
│
├── docs/                 # Documentation
│   ├── BOM.md
│   ├── IMPLEMENTATION.md
│   ├── ARCHITECTURE.md
│   ├── HARDWARE.md
│   ├── SETUP.md
│   ├── API.md
│   └── TROUBLESHOOTING.md
│
└── README.md             # This file
```

## ⚠️ Safety & Compliance

**WARNING**: This project involves high-voltage AC power. Proper safety measures must be followed:

- ⚠️ All high-voltage connections must be performed by qualified electricians
- ⚠️ Use proper isolation (optocouplers, isolation transformers)
- ⚠️ Ensure mechanical and electrical interlocking of contactors
- ⚠️ Include appropriate fuses, MCBs, and surge protection
- ⚠️ Follow local electrical codes and regulations
- ⚠️ The MCU never directly handles mains AC voltage

See [HARDWARE.md](docs/HARDWARE.md) for detailed safety guidelines.

## 🎯 Use Cases

- **Residential**: Home backup power systems with generator/inverter
- **Commercial**: Office buildings with critical load management
- **Industrial**: Facilities requiring seamless power source transitions
- **Academic**: Power systems and IoT research projects

## 🛠️ Switching Logic

The system follows these priority rules:

1. **Primary Source**: Grid power (PHCN/Utility)
2. **Backup Source**: Generator or Solar Inverter
3. **Auto-Switch**: Automatic transition on power failure
4. **Return Switch**: Automatic return to grid when stable (configurable delay)
5. **Safety**: Dead-time delay prevents arcing; interlocks prevent dual-source connection

## 📊 Data Logging

The system logs:
- Power source status changes
- Voltage and current measurements (per source)
- Energy consumption (kWh per source)
- Outage duration and frequency
- Fault events (overcurrent, undervoltage, etc.)
- Generator runtime hours
- Switching events with timestamps

Data is stored locally on SD card and can be exported via the mobile app.

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Authors

- Project Developer - [Your Name/Organization]

## 🙏 Acknowledgments

- ESP32 community for hardware support
- Flutter team for the excellent framework
- PlatformIO for embedded development tools

## 📞 Support

For issues, questions, or contributions:
- Open an issue on GitHub
- Refer to [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for common problems

---

**⚠️ Disclaimer**: This is a prototype system. Always consult with qualified electricians and follow local electrical codes before deploying in production environments.


