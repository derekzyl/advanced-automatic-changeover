# Hardware Design Documentation

Detailed hardware design, schematics, and safety guidelines for the Advanced Automatic Changeover Switch.

## 📋 Table of Contents

- [Electrical Design](#electrical-design)
- [Circuit Schematics](#circuit-schematics)
- [PCB Layout Guidelines](#pcb-layout-guidelines)
- [Safety Guidelines](#safety-guidelines)
- [Wiring Diagrams](#wiring-diagrams)
- [Testing Procedures](#testing-procedures)

---

## Electrical Design

### 1. System Specifications

| Parameter | Specification | Notes |
|-----------|---------------|-------|
| Input Voltage (Grid) | 220V AC, 50Hz | Adjustable for 110V/240V systems |
| Input Voltage (Generator) | 220V AC, 50Hz | Must match grid voltage |
| Load Capacity | 10-20A (2.2-4.4kW) | Based on contactor rating |
| Control Voltage | 5V DC | For ESP32 and sensors |
| Isolation | Galvanic | Full isolation between AC and DC |

### 2. Power Ratings

```
Grid Input:     220V AC, Max 20A
Generator Input: 220V AC, Max 20A
Load Output:    220V AC, Max 20A
Control Supply: 5V DC, 2A
```

### 3. Component Ratings

- **Contactors**: 20A, 220V AC, with mechanical interlock
- **Fuses**: 10A fast-blow for each input
- **Voltage Sensors**: 0-250V AC input range
- **Current Sensor**: 30A or 50A rated
- **Power Supply**: 5V/2A, isolated

---

## Circuit Schematics

### 1. Power Supply Circuit

```
220V AC Input
    │
    ├──► Fuse (F1, 10A) ──┐
    │                      │
    ├──► Surge Protector ──┤
    │                      │
    └──► Isolation Trans ──┤  (220V/12V, 5VA)
                           │
                           ▼
                   12V AC Output
                           │
                           ▼
              AC-DC Converter Module
              (12V AC → 5V DC, 2A)
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼
     ESP32            Sensors          Relay Drivers
   (3.3V via         (5V)              (5V)
    onboard LDO)
```

**Component Values:**
- Isolation Transformer: 220V/12V, 5VA minimum
- AC-DC Converter: 12V AC input, 5V/2A DC output
- Filtering Capacitors: 100µF (electrolytic), 10µF (ceramic)

### 2. Voltage Sensing Circuit

**Grid Voltage Sensor (ZMPT101B)**

```
Grid L (220V AC) ────► ZMPT101B Primary (Input)
Grid N (Neutral) ────► ZMPT101B Primary (Input)
                              │
                              │ Secondary
                              ▼
                    ZMPT101B Output (0-5V DC)
                              │
                              ├──► 10kΩ Pull-up Resistor to 5V
                              │
                              ├──► 10nF Capacitor to GND (filtering)
                              │
                              ▼
                         ESP32 GPIO 34 (ADC1_CH6)
```

**Calibration Notes:**
- Zero point: 2.5V (no AC input)
- Full scale: 250V AC → ~5V DC
- Formula: `V_AC = ((ADC_reading / 4095) * 5.0 - 2.5) * (250.0 / 2.5)`

**Generator Voltage Sensor:** Same circuit, connected to ESP32 GPIO 35

### 3. Current Sensing Circuit

**Load Current (SCT-013)**

```
Load Line (Live) ────► SCT-013 Clamp (around wire)
                              │
                              │ Secondary (Current)
                              ▼
                     Burden Resistor (33Ω, 2W)
                              │
                              ├──► 10nF Capacitor to GND
                              │
                              ▼
                         ESP32 GPIO 32 (ADC1_CH4)
```

**Burden Resistor Calculation:**
- SCT-013-030: 1V output per 30A primary current
- Recommended burden: 33Ω, 2W rating
- Formula: `I_AC = ((ADC_reading / 4095) * 5.0 - 2.5) / 33.0 * 30.0`

### 4. Contactor Control Circuit

**Grid Contactor Control**

```
ESP32 GPIO 25 ──► 220Ω Resistor ──► PC817 Optocoupler (LED)
                                           │
                                           │ (Phototransistor)
                                           ▼
                                  2N2222 Transistor (Base)
                                           │
                                           │ (Collector-Emitter)
                                           ▼
                                    Relay Driver Coil (12V)
                                           │
                                           ▼
                                    Grid Contactor Coil (220V AC)
```

**Component Values:**
- Input Resistor: 220Ω (limits LED current to ~15mA)
- Optocoupler: PC817 or 4N35
- Transistor: 2N2222 (NPN) or use ULN2003 driver IC
- Relay Driver: 12V relay coil (if contactor coil is 12V DC)

**Alternative (Direct Optocoupler Control):**
```
ESP32 GPIO 25 ──► 220Ω ──► PC817 ──► 10kΩ Pull-down ──► Gate of Logic-Level MOSFET
                                                              │
                                                              ▼
                                                        Contactor Coil
```

**Generator Contactor:** Same circuit, connected to ESP32 GPIO 26

### 5. Interlocking Circuit

**Electrical Interlock (Safety)**

```
Grid Contactor Coil ──► NC (Normally Closed) Contact of Gen Contactor
Gen Contactor Coil  ──► NC (Normally Closed) Contact of Grid Contactor
```

This ensures that activating one contactor automatically breaks the circuit to the other.

**Mechanical Interlock:** Built into contactor assembly (if using interlocked contactors)

### 6. RTC Module Connection (DS3231)

```
ESP32        DS3231
GPIO 14 ───► SCL (I2C Clock)
GPIO 27 ───► SDA (I2C Data)
3.3V    ───► VCC
GND     ───► GND
```

**Pull-up Resistors:** 4.7kΩ on SCL and SDA (usually on module)

### 7. SD Card Module Connection

```
ESP32        SD Card Module
GPIO 18 ───► SCK  (SPI Clock)
GPIO 23 ───► MOSI (SPI Data Out)
GPIO 19 ───► MISO (SPI Data In)
GPIO 5  ───► CS   (Chip Select)
3.3V    ───► VCC
GND     ───► GND
```

### 8. Complete Pin Mapping

| ESP32 Pin | Function | Component | Notes |
|-----------|----------|-----------|-------|
| GPIO 34 | ADC Input | Grid Voltage Sensor | Input only, no pull-up |
| GPIO 35 | ADC Input | Generator Voltage Sensor | Input only, no pull-up |
| GPIO 32 | ADC Input | Load Current Sensor | Input only |
| GPIO 25 | Digital Output | Grid Contactor Control | Via optocoupler |
| GPIO 26 | Digital Output | Generator Contactor Control | Via optocoupler |
| GPIO 14 | I2C SCL | RTC Module | With pull-up |
| GPIO 27 | I2C SDA | RTC Module | With pull-up |
| GPIO 18 | SPI SCK | SD Card Module | |
| GPIO 23 | SPI MOSI | SD Card Module | |
| GPIO 19 | SPI MISO | SD Card Module | |
| GPIO 5 | SPI CS | SD Card Module | |
| GPIO 2 | Digital Output | Status LED | With current-limiting resistor |
| GPIO 4 | PWM Output | Buzzer | Optional |
| 3.3V | Power | All 3.3V devices | |
| 5V | Power | Sensors, SD Card | |
| GND | Ground | All components | Common ground |

**Note:** Pin assignments may vary. Verify with your ESP32 variant's datasheet.

---

## PCB Layout Guidelines

### 1. Layout Principles

**High-Voltage Section (AC):**
- Keep all AC traces on one side of the board
- Minimum trace width: 2mm for 10A, 3mm for 20A
- Clearance: Minimum 3mm between AC traces and low-voltage sections
- Use isolation slots/cuts in PCB if needed

**Low-Voltage Section (DC):**
- Separate ground planes for analog and digital sections
- Use star grounding for sensitive analog circuits
- Keep digital signals away from analog sensors

**Isolation Barrier:**
- Clear physical separation between AC and DC sections
- Use optocouplers and isolation transformers at the boundary
- No copper fills connecting AC and DC sections

### 2. Component Placement

```
┌─────────────────────────────────────┐
│  HIGH-VOLTAGE SECTION               │
│  ┌──────────┐      ┌──────────┐    │
│  │ Grid     │      │ Generator│    │
│  │Contactor │      │Contactor │    │
│  └──────────┘      └──────────┘    │
│                                     │
│  ┌──────────┐      ┌──────────┐    │
│  │Surge     │      │Fuses     │    │
│  │Protector │      │          │    │
│  └──────────┘      └──────────┘    │
└─────────────────────────────────────┘
         │                    │
    [ISOLATION BARRIER - NO COPPER]
         │                    │
┌─────────────────────────────────────┐
│  LOW-VOLTAGE SECTION                │
│  ┌──────────┐      ┌──────────┐    │
│  │ ESP32    │      │Power     │    │
│  │          │      │Supply    │    │
│  └──────────┘      └──────────┘    │
│                                     │
│  ┌──────────┐      ┌──────────┐    │
│  │ Sensors  │      │RTC, SD   │    │
│  │ (ADC)    │      │Card      │    │
│  └──────────┘      └──────────┘    │
└─────────────────────────────────────┘
```

### 3. Grounding Strategy

- **AC Ground (Earth):** Connected to enclosure/chassis
- **DC Ground (Common):** Separate from AC ground, connected via isolation
- **Analog Ground:** Separate plane for sensor circuits
- **Digital Ground:** Separate plane for ESP32 and digital circuits
- **Star Ground:** Connect analog and digital grounds at single point

---

## Safety Guidelines

### 1. Electrical Safety

⚠️ **CRITICAL SAFETY REQUIREMENTS:**

1. **Isolation**
   - All high-voltage signals must be isolated from low-voltage circuits
   - Use optocouplers for all control signals
   - Use isolation transformers for power supply
   - Maintain minimum 3mm clearance on PCB

2. **Interlocking**
   - Both electrical and mechanical interlocking required
   - Verify interlock operation before power-on
   - Never bypass interlocks for testing

3. **Protection**
   - Fuses on both input sources (10A recommended)
   - Surge protection on AC inputs
   - Overcurrent protection (MCB or relay-based)
   - Undervoltage protection in firmware

4. **Enclosure**
   - Use IP54 or better rated enclosure
   - Proper grounding of enclosure to earth
   - Ventilation for heat dissipation
   - Warning labels for high voltage

### 2. Installation Safety

1. **Power Off:** Always disconnect power before wiring
2. **Qualified Personnel:** High-voltage connections by licensed electrician only
3. **Testing:** Test with low voltage first, then gradually increase
4. **Verification:** Verify all connections with multimeter before power-on
5. **Documentation:** Document all wiring connections

### 3. Operational Safety

1. **Regular Inspection:** Check contactors, connections, and sensors monthly
2. **Maintenance:** Clean contacts, check for loose connections
3. **Monitoring:** Monitor data logs for anomalies
4. **Emergency Stop:** Include emergency stop switch in design
5. **User Training:** Train users on safe operation

### 4. Compliance

- Follow local electrical codes (e.g., IEC, NEC, BS)
- UL/CE certification recommended for commercial use
- EMC compliance for electromagnetic interference
- Environmental ratings for deployment location

---

## Wiring Diagrams

### 1. Main Power Wiring

```
Grid Input:
  L (Live) ──► Fuse ──► Surge Protector ──► Grid Contactor (Terminal 1)
  N (Neutral) ────────────────────────────► Common Neutral Bus
  E (Earth) ──────────────────────────────► Earth Terminal

Generator Input:
  L (Live) ──► Fuse ──► Surge Protector ──► Generator Contactor (Terminal 1)
  N (Neutral) ────────────────────────────► Common Neutral Bus
  E (Earth) ──────────────────────────────► Earth Terminal

Load Output:
  Grid Contactor (Terminal 2) ──┐
                                ├──► Load L (Live)
  Generator Contactor (Terminal 2) ──┘
  Common Neutral Bus ──────────────────► Load N (Neutral)
  Earth Terminal ───────────────────────► Load E (Earth)
```

### 2. Control Wiring

```
5V Power Supply
  +5V ──► ESP32, Sensors, SD Card, RTC (VCC)
  GND ──► ESP32, Sensors, SD Card, RTC (GND), Common Ground

Contactor Control:
  ESP32 GPIO 25 ──► Optocoupler ──► Grid Contactor Coil
  ESP32 GPIO 26 ──► Optocoupler ──► Generator Contactor Coil

Sensor Connections:
  Grid Voltage Sensor ──► ESP32 GPIO 34
  Generator Voltage Sensor ──► ESP32 GPIO 35
  Load Current Sensor ──► ESP32 GPIO 32
```

---

## Testing Procedures

### 1. Power Supply Test

1. Connect isolation transformer to 220V AC
2. Measure 12V AC output with multimeter
3. Connect AC-DC converter, measure 5V DC output
4. Verify regulation under load (connect ESP32)
5. Check isolation: No continuity between AC and DC grounds

### 2. Sensor Calibration

**Voltage Sensor:**
1. Connect known AC source (e.g., 220V from wall)
2. Read ADC value from ESP32
3. Calculate calibration factor
4. Store in EEPROM/config

**Current Sensor:**
1. Connect known load (e.g., 10A resistive load)
2. Read ADC value
3. Calculate calibration factor
4. Verify with different loads

### 3. Contactor Test

1. Apply 5V to control input (via optocoupler)
2. Verify contactor closes (audible click)
3. Measure continuity across contacts with multimeter
4. Test interlocking: Activate one, verify other cannot activate
5. Measure switching time (should be <100ms)

### 4. Integration Test

1. Power on system
2. Connect grid source (low voltage test first)
3. Verify ESP32 detects grid voltage
4. Connect generator source
5. Simulate grid failure
6. Verify automatic switch to generator
7. Restore grid, verify switch back

### 5. Safety Test

1. Verify isolation: No continuity between AC and DC
2. Test interlocking: Both contactors cannot be ON
3. Test dead-time: Measure delay between switches
4. Test overcurrent: Trigger overcurrent, verify shutdown
5. Test undervoltage: Low voltage should trigger switch

---

## Troubleshooting

### Common Issues

| Issue | Possible Cause | Solution |
|-------|----------------|----------|
| No power to ESP32 | Power supply failure | Check 5V output, verify connections |
| Incorrect voltage readings | Sensor calibration | Recalibrate sensors |
| Contactors not switching | Control circuit fault | Check optocouplers, verify GPIO |
| Interlock failure | Wiring error | Verify interlock connections |
| SD card not detected | SPI connections | Check wiring, verify CS pin |

---

**Last Updated**: [Current Date]
**Version**: 1.0

**⚠️ REMINDER:** Always follow local electrical codes and work with qualified electricians for high-voltage installations.



