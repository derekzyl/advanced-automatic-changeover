The Design and Implementation of an Advanced Automatic Changeover Switch with Integrated Data Logger and IoT Capabilities

The Design and Implementation of an Advanced Automatic Changeover Switch with Integrated Data Logger and IoT Capabilities

Great topic 👌 — this is a real-world hardware + software system and combining it with a Flutter app makes it powerful for monitoring and control.

Let’s break it down into:

1️⃣ What the system must do
2️⃣ Hardware architecture & components
3️⃣ Control & sensing logic
4️⃣ IoT communication
5️⃣ Flutter mobile app functions

🚀 System Overview

An Advanced Automatic Changeover Switch automatically switches electrical load between:

Primary Source (e.g., Grid / PHCN)

Backup Source (Generator / Solar inverter)

The system must:

Feature	Purpose
Auto-switching	No downtime when power fails
Data logging	Track power usage & outages
IoT monitoring	View status on phone anywhere
Safety protections	Prevent back-feed and overload
Manual override	User can switch source manually
🧱 Hardware Block Diagram
       Grid Power ─┐
                    ├─ ATS ──► Load
Generator/Inverter ─┘       │
                            ▼
                    Sensors + MCU (ESP32)
                            │
                    Storage + IoT Module
                            │ WiFi/Bluetooth
                            ▼
                     Flutter Mobile App

🛠 Key Hardware Components
Component	Function
ESP32	Central controller + WiFi + Bluetooth
2 or 3 Contactors	Switching high-voltage sources
Power relay drivers	Isolate MCU from AC coils
AC voltage sensors (ZMPT101B)	Detects input availability & voltage quality
CT sensors (SCT-013)	Load current monitoring
RTC module	Accurate timestamping for logging
MicroSD / onboard flash	Local data storage
Surge protection + fuses	Electrical safety
⚙️ Switching Logic

✔ Priority Source: Grid
✔ If grid fails → Automatically switch to Generator
✔ If grid returns stable for X seconds → Switch back
✔ If generator overload detected → Alerts + shutdown option

Switching must include:
✔ Interlocking → Prevent both sources ON simultaneously
✔ Dead time delay → Prevent arcing and equipment damage

🔐 Safety & Electrical Design
Required Safety Features
Mechanical & electrical interlocking
Overcurrent protection (MCB/Relay cutoff)
Zero-cross switching (optional for smoother transitions)
EMI/Noise suppression for contactor coils

🛑 MCU never handles mains AC directly — everything is isolated with:

Optocouplers

Isolation transformers

Relay/Driver coils

🔍 Sensing & Data Logging
What is logged:

Grid uptime/voltage levels

Generator runtime duration

Energy consumption per source

Number of switch events

Fault events (overcurrent, undervoltage)

Logging destinations

Onboard flash

Cloud (optional upgrade)

📡 IoT + Flutter App Integration
Communication Options
Option	Pros	Cons
WiFi (MQTT/REST)	Can monitor from anywhere	Needs router/internet
Bluetooth	Offline support	Short range
Hybrid (best)	Full flexibility	More firmware work
Mobile App Features (Flutter)
Dashboard

Live source status: 🟢Grid / 🔵Generator

Live voltage & current readings

Power usage graph

Events & Data Logs

Outage reports

Runtime history

Controls

Manual changeover from phone

Generator start/stop (if supported)

Alerts & Notifications

Grid failure detected

Generator overload

Maintenance reminders

🧪 Software Flow (Firmware)
Start Boot →
Check Grid Voltage →
  If > threshold → Source = Grid
  Else → Start Generator
Monitor Load Current & Voltage →
Log data to memory →
Send data to mobile/cloud →
Display status on local LCD (optional)

🔌 Optional Extras to Make It “Advanced”
Feature	Benefit
Generator auto-start module	Fully autonomous backup
Power factor monitoring	Better energy analytics
LCD/OLED screen	Local quick info
QR pairing for Flutter app	Easy deployment
Predictive analytics	Estimate outages & maintenance
📘 Deliverables for Academic Project

You will be able to present:

✔ Hardware prototype that switches loads
✔ ESP32 firmware with safety & monitoring
✔ Data logging with analytics
✔ Flutter app for IoT monitoring/control
✔ Technical documentation, block diagrams, PCB design, flow charts

It checks all academic project boxes 🎯:

Microcontroller + power electronics

IoT + mobile development

Data acquisition + embedded control

Power systems + safety compliance