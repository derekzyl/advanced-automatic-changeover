# Bill of Materials (BOM)

Complete list of components required for the Advanced Automatic Changeover Switch system.

## 📋 Component Categories

- [Microcontroller & Communication](#microcontroller--communication)
- [Power Switching](#power-switching)
- [Sensors](#sensors)
- [Storage & Time](#storage--time)
- [Isolation & Safety](#isolation--safety)
- [Power Supply](#power-supply)
- [Connectors & Hardware](#connectors--hardware)
- [Optional Components](#optional-components)

---

## Microcontroller & Communication

| Component | Part Number | Qty | Unit Price | Total | Supplier | Notes |
|-----------|------------|-----|------------|-------|----------|-------|
| ESP32-C3 Development Kit | ESP32-C3-DevKitC-02 | 1 | $5-8 | $5-8 | AliExpress, DigiKey, Mouser | Main controller with WiFi & Bluetooth |
| ESP32-C3 Module (Alternative) | ESP32-C3-MINI-1 | 1 | $3-5 | $3-5 | AliExpress, LCSC | If using custom PCB |

**Alternative Options:**
- ESP32 (WiFi + Bluetooth Classic)
- ESP32-S3 (More GPIO, dual-core)
- ESP8266 (WiFi only, lower cost)

---

## Power Switching

| Component | Part Number | Qty | Unit Price | Total | Supplier | Notes |
|-----------|------------|-----|------------|-------|----------|-------|
| Contactor (Grid) | Schneider LC1D09/220V or Similar | 1 | $15-25 | $15-25 | Electrical suppliers | 9A, 220V AC coil, mechanically interlocked preferred |
| Contactor (Generator) | Schneider LC1D09/220V or Similar | 1 | $15-25 | $15-25 | Electrical suppliers | Same as Grid contactor |
| Contactor Relay (Optional) | Finder 40.52.0.024.0000 | 2 | $8-12 | $16-24 | RS Components, DigiKey | Smaller relay for low-power testing |
| Relay Driver Module | 4-Channel Relay Module 5V | 1 | $2-5 | $2-5 | AliExpress, Amazon | For contactor coil control |

**Specifications:**
- **Rated Current**: 10-20A (based on load requirements)
- **Voltage**: 220V AC (adjust for local standard: 110V/240V)
- **Coil Voltage**: 220V AC or 12V/24V DC (based on design)
- **Interlocking**: Mechanical or electrical interlock required

---

## Sensors

| Component | Part Number | Qty | Unit Price | Total | Supplier | Notes |
|-----------|------------|-----|------------|-------|----------|-------|
| AC Voltage Sensor (Grid) | ZMPT101B | 1 | $2-4 | $2-4 | AliExpress, Amazon | 0-250V AC transformer module |
| AC Voltage Sensor (Generator) | ZMPT101B | 1 | $2-4 | $2-4 | AliExpress, Amazon | Same as Grid sensor |
| Current Transformer (Load) | SCT-013-030 (30A) or SCT-013-050 (50A) | 1 | $5-8 | $5-8 | AliExpress, Amazon | Clamp-on CT sensor |
| Current Transformer (Alternative) | ACS712-30A | 1 | $2-4 | $2-4 | AliExpress, Amazon | Hall-effect sensor (less accurate) |

**Specifications:**
- **ZMPT101B**: Output 0-5V DC for 0-250V AC input
- **SCT-013**: 30A or 50A rating based on max load
- Requires burden resistor (typically 33Ω for SCT-013)

---

## Storage & Time

| Component | Part Number | Qty | Unit Price | Total | Supplier | Notes |
|-----------|------------|-----|------------|-------|----------|-------|
| RTC Module | DS3231 | 1 | $2-4 | $2-4 | AliExpress, Amazon | High-precision RTC with battery backup |
| MicroSD Card Module | MicroSD Card Adapter Module | 1 | $1-3 | $1-3 | AliExpress, Amazon | SPI interface for data logging |
| MicroSD Card | 16GB Class 10 | 1 | $5-10 | $5-10 | Local/Online | For data storage |
| CR2032 Battery | CR2032 | 1 | $1-2 | $1-2 | Local | For RTC backup |

**Alternative:**
- Use ESP32's internal RTC (less accurate, requires NTP sync)

---

## Isolation & Safety

| Component | Part Number | Qty | Unit Price | Total | Supplier | Notes |
|-----------|------------|-----|------------|-------|----------|-------|
| Optocoupler | PC817 or 4N35 | 4-6 | $0.10-0.30 | $0.40-1.80 | AliExpress, LCSC | Digital isolation for control signals |
| Isolation Transformer | 220V/12V, 2-5VA | 1 | $5-10 | $5-10 | AliExpress, Electrical suppliers | For power supply isolation |
| Surge Protection Module | 220V Surge Protector | 1 | $5-15 | $5-15 | Electrical suppliers | MOV-based surge suppression |
| Fuse Holder | Panel Mount Fuse Holder | 2 | $1-3 | $2-6 | AliExpress, Amazon | For input protection |
| Fuses | 10A Fast-Blow | 2 | $0.50-1 | $1-2 | Electrical suppliers | Input protection fuses |
| MCB (Optional) | 10A Single Pole MCB | 2 | $5-10 | $10-20 | Electrical suppliers | Circuit breaker for each source |

---

## Power Supply

| Component | Part Number | Qty | Unit Price | Total | Supplier | Notes |
|-----------|------------|-----|------------|-------|----------|-------|
| AC-DC Power Supply Module | 220V AC to 5V DC, 2A | 1 | $3-8 | $3-8 | AliExpress, Amazon | For ESP32 and sensors |
| Voltage Regulator (Alternative) | LM2596 Buck Converter | 1 | $1-3 | $1-3 | AliExpress | If using 12V supply |
| Capacitors | 100µF, 10µF Electrolytic | 5 | $0.10-0.20 | $0.50-1 | AliExpress, LCSC | Power supply filtering |

**Specifications:**
- Input: 220V AC (or 110V/240V based on local standard)
- Output: 5V DC, 2A minimum
- Isolation recommended for safety

---

## Connectors & Hardware

| Component | Part Number | Qty | Unit Price | Total | Supplier | Notes |
|-----------|------------|-----|------------|-------|----------|-------|
| Terminal Blocks | 5mm Screw Terminal Blocks | 10-15 | $0.20-0.50 | $2-7.50 | AliExpress, LCSC | For wire connections |
| Jumper Wires | Male-Female, Male-Male | 1 pack | $2-5 | $2-5 | AliExpress, Amazon | Prototyping connections |
| Breadboard (Prototype) | Full-size Breadboard | 1 | $3-5 | $3-5 | AliExpress, Amazon | For initial testing |
| PCB (Custom) | Custom PCB Design | 1 | $10-30 | $10-30 | JLCPCB, PCBWay | For final production version |
| Enclosure | IP65 Electrical Enclosure | 1 | $20-50 | $20-50 | AliExpress, Electrical suppliers | Weatherproof enclosure |
| DIN Rail (Optional) | Standard DIN Rail | 1 | $5-10 | $5-10 | Electrical suppliers | For mounting contactors |

---

## Optional Components

| Component | Part Number | Qty | Unit Price | Total | Supplier | Notes |
|-----------|------------|-----|------------|-------|----------|-------|
| OLED Display | 0.96" SSD1306 OLED | 1 | $3-5 | $3-5 | AliExpress, Amazon | Local status display |
| LCD Display (Alternative) | 16x2 LCD with I2C | 1 | $4-6 | $4-6 | AliExpress, Amazon | Larger display option |
| Buzzer | Active Piezo Buzzer 5V | 1 | $0.50-1 | $0.50-1 | AliExpress, Amazon | Audio alerts |
| LED Indicators | 5mm LEDs (Red, Green, Yellow) | 5 | $0.10-0.20 | $0.50-1 | AliExpress, LCSC | Status indicators |
| Push Buttons | Tactile Push Buttons | 2-3 | $0.20-0.50 | $0.40-1.50 | AliExpress, LCSC | Manual override switches |
| Generator Auto-Start Module | Custom/Commercial | 1 | $30-100 | $30-100 | Electrical suppliers | For generator automation |

---

## 📊 Cost Summary

### Basic Version (Minimal Components)
- **Microcontroller**: $5-8
- **Contactors**: $30-50
- **Sensors**: $9-16
- **Storage/RTC**: $8-19
- **Isolation/Safety**: $10-25
- **Power Supply**: $3-8
- **Connectors/Hardware**: $15-50
- **Total**: **$80-176**

### Full-Featured Version (Including Optional)
- **Basic Components**: $80-176
- **Display**: $3-6
- **Enclosure**: $20-50
- **Generator Auto-Start**: $30-100
- **Total**: **$133-332**

### Production/Commercial Version
- **Custom PCB**: $10-30
- **Professional Enclosure**: $50-150
- **High-Quality Components**: +50-100% markup
- **Certification & Testing**: Variable
- **Total**: **$300-800+**

---

## 🔍 Component Selection Notes

### Contactor Selection
- Choose based on **maximum load current** (with 50-100% safety margin)
- For residential: 10-20A contactors sufficient
- For commercial: 25-63A contactors may be required
- Ensure **mechanical interlocking** or use interlocked contactor sets
- Consider contactor coil voltage (220V AC or 12V/24V DC)

### Sensor Selection
- **ZMPT101B**: Good for voltage sensing, requires calibration
- **SCT-013**: Non-invasive, accurate, preferred for current sensing
- **ACS712**: Alternative, but less accurate and requires disconnection for installation

### ESP32 Variant Selection
- **ESP32-C3**: Modern, cost-effective, WiFi + BLE
- **ESP32**: More GPIO, dual-core, established ecosystem
- **ESP8266**: Lower cost, WiFi only, less powerful

---

## 🛒 Recommended Suppliers

### International
- **AliExpress** - Best prices, slow shipping
- **DigiKey** - Fast shipping, higher prices, authentic components
- **Mouser Electronics** - Large selection, good for commercial
- **LCSC** - Good for components, competitive pricing
- **RS Components** - Professional components, good documentation

### Regional (Adjust based on location)
- **Nigeria**: Kara Market Lagos, Online stores (Jumia, Konga for some items)
- **USA**: Amazon, Micro Center (local), Adafruit
- **UK**: RS Components, Farnell
- **India**: Robu.in, ElectronicsComp

---

## ⚠️ Important Notes

1. **Voltage Ratings**: Ensure all components match your local voltage standard (110V/220V/240V)
2. **Safety First**: Use certified components for high-voltage applications
3. **Local Regulations**: Check electrical codes for contactor and safety component requirements
4. **Quantity Discounts**: Bulk orders can reduce per-unit costs
5. **Shipping**: Factor in shipping costs, especially for international orders
6. **Alternatives**: Many components have cheaper alternatives but verify compatibility

---

## 📝 Purchase Checklist

- [ ] ESP32 development board
- [ ] Two contactors (matching specifications)
- [ ] Two voltage sensors (ZMPT101B)
- [ ] One current transformer (SCT-013)
- [ ] RTC module (DS3231)
- [ ] MicroSD card module + card
- [ ] Optocouplers (4-6 pieces)
- [ ] AC-DC power supply (5V, 2A)
- [ ] Isolation components (transformer, surge protector)
- [ ] Fuses and fuse holders
- [ ] Terminal blocks and connectors
- [ ] Enclosure (appropriate size)
- [ ] Optional: Display, buzzer, LEDs

---

**Last Updated**: [Current Date]
**Version**: 1.0

