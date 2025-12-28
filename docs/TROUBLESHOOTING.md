# Troubleshooting Guide

Common issues and solutions for the Advanced Automatic Changeover Switch system.

## 📋 Table of Contents

- [Hardware Issues](#hardware-issues)
- [Firmware Issues](#firmware-issues)
- [Mobile App Issues](#mobile-app-issues)
- [Communication Issues](#communication-issues)
- [Performance Issues](#performance-issues)

---

## Hardware Issues

### ESP32 Not Powering On

**Symptoms:**
- No LED indicators
- Serial monitor shows no output

**Possible Causes:**
1. Power supply failure
2. Incorrect wiring
3. Short circuit

**Solutions:**
1. Check 5V power supply output with multimeter
2. Verify power connections (VCC and GND)
3. Check for short circuits on power lines
4. Try different USB cable/port (if using USB power)

### Sensors Reading Incorrect Values

**Symptoms:**
- Voltage readings don't match actual values
- Current readings are zero or incorrect

**Possible Causes:**
1. Incorrect calibration
2. Loose connections
3. Sensor failure
4. ADC reference voltage issue

**Solutions:**
1. Recalibrate sensors (see [IMPLEMENTATION.md](IMPLEMENTATION.md))
2. Check all sensor connections
3. Verify sensor output with multimeter
4. Check ESP32 ADC reference voltage (should be 3.3V)

### Contactors Not Switching

**Symptoms:**
- Contactors don't respond to control signals
- No audible click when activating

**Possible Causes:**
1. Control circuit fault
2. Contactor coil failure
3. Optocoupler failure
4. Insufficient coil voltage

**Solutions:**
1. Check GPIO output with multimeter (should toggle high/low)
2. Verify optocoupler operation
3. Check contactor coil voltage (should match rating)
4. Test contactor manually with direct power

### Interlock Not Working

**Symptoms:**
- Both contactors can be ON simultaneously
- System allows dual-source connection

**Possible Causes:**
1. Wiring error in interlock circuit
2. Mechanical interlock not installed
3. Software bug

**Solutions:**
1. Verify interlock wiring (NC contacts in series)
2. Check mechanical interlock installation
3. Review firmware interlock logic
4. Test with multimeter (verify one contactor opens other's circuit)

---

## Firmware Issues

### WiFi Connection Fails

**Symptoms:**
- ESP32 doesn't connect to WiFi
- Serial monitor shows connection errors

**Possible Causes:**
1. Incorrect SSID/password
2. WiFi router incompatible (5GHz only)
3. Signal too weak
4. Router MAC filtering

**Solutions:**
1. Double-check WiFi credentials in code
2. Ensure router supports 2.4GHz (ESP32 requirement)
3. Move ESP32 closer to router or add WiFi extender
4. Check router MAC filtering settings
5. Try different WiFi network for testing

### MQTT Connection Issues

**Symptoms:**
- MQTT messages not received
- Connection timeout errors

**Possible Causes:**
1. Incorrect broker address
2. Firewall blocking port 1883
3. Broker not running
4. Network connectivity issue

**Solutions:**
1. Verify MQTT broker IP address and port
2. Check firewall rules (allow port 1883)
3. Ensure MQTT broker is running
4. Test network connectivity (ping broker)
5. Try local broker (localhost) first

### SD Card Not Detected

**Symptoms:**
- Data logging fails
- Serial monitor shows "SD card initialization failed"

**Possible Causes:**
1. Incorrect SPI pin connections
2. SD card not formatted
3. SD card damaged
4. Power supply issue

**Solutions:**
1. Verify SPI connections (CS, MOSI, MISO, SCK)
2. Format SD card as FAT32
3. Try different SD card
4. Check 3.3V power supply (SD cards can be sensitive)
5. Use shorter SPI wires (signal integrity)

### Data Logging Errors

**Symptoms:**
- Log files corrupted
- Missing data entries
- File system errors

**Possible Causes:**
1. SD card failure
2. Power interruptions during write
3. File system corruption
4. Insufficient power supply

**Solutions:**
1. Replace SD card
2. Add power backup/capacitor
3. Format SD card and restart
4. Check power supply stability
5. Implement file sync/flush after writes

---

## Mobile App Issues

### App Cannot Connect to ESP32

**Symptoms:**
- Connection timeout
- "Unable to connect" error

**Possible Causes:**
1. Incorrect IP address
2. ESP32 not on same network
3. Firewall blocking connection
4. ESP32 not running

**Solutions:**
1. Verify ESP32 IP address (check serial monitor)
2. Ensure phone and ESP32 on same WiFi network
3. Check firewall/network restrictions
4. Verify ESP32 is running and connected to WiFi

### Real-Time Data Not Updating

**Symptoms:**
- Dashboard shows stale data
- No updates in charts

**Possible Causes:**
1. MQTT connection lost
2. App not subscribed to topics
3. ESP32 not publishing
4. Network connectivity issue

**Solutions:**
1. Check MQTT connection status
2. Verify topic subscriptions
3. Check ESP32 serial monitor for publish errors
4. Test network connectivity
5. Restart app

### App Crashes

**Symptoms:**
- App closes unexpectedly
- Error messages in log

**Possible Causes:**
1. Null pointer exception
2. JSON parsing error
3. Memory leak
4. Threading issue

**Solutions:**
1. Check error logs (flutter logs)
2. Validate JSON data format
3. Add null checks in code
4. Review memory usage
5. Update Flutter SDK and dependencies

---

## Communication Issues

### MQTT Messages Delayed

**Symptoms:**
- Status updates arrive late
- Commands take time to execute

**Possible Causes:**
1. Network congestion
2. QoS level too low
3. Broker performance
4. WiFi signal weak

**Solutions:**
1. Check network traffic
2. Use QoS 1 for critical messages
3. Upgrade MQTT broker
4. Improve WiFi signal strength
5. Reduce publish frequency if needed

### Bluetooth Connection Problems

**Symptoms:**
- Cannot pair with ESP32
- Connection drops frequently

**Possible Causes:**
1. Bluetooth not enabled on ESP32
2. Pairing issues
3. Range too far
4. Interference

**Solutions:**
1. Verify Bluetooth is enabled in firmware
2. Check pairing process
3. Stay within 10m range
4. Reduce interference (move away from WiFi routers)
5. Try different Bluetooth device for testing

---

## Performance Issues

### System Slow Response

**Symptoms:**
- Delayed switching
- Laggy data updates

**Possible Causes:**
1. Main loop delay too long
2. Blocking operations
3. Too many operations in loop
4. Memory fragmentation

**Solutions:**
1. Reduce main loop delay
2. Use non-blocking operations
3. Optimize code (remove unnecessary operations)
4. Use FreeRTOS tasks for heavy operations
5. Check available memory

### High Power Consumption

**Symptoms:**
- Power supply heating up
- Voltage drops

**Possible Causes:**
1. Too many active components
2. WiFi always on
3. Continuous sensor readings
4. Power supply insufficient

**Solutions:**
1. Implement sleep modes when idle
2. Reduce WiFi transmit power
3. Sample sensors less frequently
4. Upgrade power supply capacity
5. Use lower power components

---

## Diagnostic Commands

### Serial Monitor Commands

```
status          - Show current status
config          - Show configuration
test_sensors    - Test sensor readings
test_contactors - Test contactor operation
reset           - Reset system
```

### Common Debugging Steps

1. **Check Serial Monitor:** Always check serial output first
2. **Verify Connections:** Use multimeter to test connections
3. **Test Components Individually:** Isolate problem to specific component
4. **Review Logs:** Check data logs and event logs
5. **Network Tools:** Use ping, telnet to test connectivity

---

## Getting Help

If issues persist:

1. Check documentation:
   - [IMPLEMENTATION.md](IMPLEMENTATION.md)
   - [HARDWARE.md](HARDWARE.md)
   - [SETUP.md](SETUP.md)

2. Review code and configuration
3. Check for known issues in project repository
4. Consult with qualified electrician for hardware issues
5. Open an issue with detailed information:
   - Error messages
   - Steps to reproduce
   - Hardware configuration
   - Firmware version

---

**Last Updated**: [Current Date]
**Version**: 1.0


