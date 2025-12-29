# API Documentation

Communication protocol and API reference for the Advanced Automatic Changeover Switch system.

## 📋 Table of Contents

- [MQTT Protocol](#mqtt-protocol)
- [REST API](#rest-api)
- [Bluetooth Protocol](#bluetooth-protocol)
- [Data Formats](#data-formats)

---

## MQTT Protocol

### Broker Configuration

- **Protocol:** MQTT 3.1.1
- **Port:** 1883 (standard), 8883 (TLS)
- **QoS:** At least once (QoS 1)

### Topic Structure

```
changeover/
├── status/              # Status updates (published by ESP32)
│   ├── power_source     # Current source
│   ├── voltages         # Voltage readings
│   ├── current          # Current reading
│   └── power            # Power calculation
├── control/             # Control commands (published by app)
│   ├── switch_source    # Manual switch
│   └── settings         # Configuration
└── events/              # Event notifications
    ├── switch_event     # Switching events
    ├── fault            # Fault detection
    └── alert            # Alert messages
```

### Published Topics

#### `changeover/status`

**Publisher:** ESP32  
**Frequency:** Every 1 second  
**QoS:** 1

**Payload (JSON):**
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

#### `changeover/events`

**Publisher:** ESP32  
**Frequency:** On event  
**QoS:** 1

**Payload (JSON):**
```json
{
  "timestamp": "2026-01-15T10:30:00Z",
  "event_type": "SWITCH",
  "event_data": {
    "from": "GRID",
    "to": "GENERATOR",
    "reason": "GRID_FAILURE"
  }
}
```

### Subscribed Topics

#### `changeover/control/switch_source`

**Subscriber:** ESP32  
**Payload:** String
- `"GRID"` - Switch to grid
- `"GENERATOR"` - Switch to generator
- `"AUTO"` - Enable automatic mode

#### `changeover/control/settings`

**Subscriber:** ESP32  
**Payload (JSON):**
```json
{
  "voltage_threshold_low": 180,
  "voltage_threshold_high": 200,
  "switch_delay_ms": 300,
  "grid_stable_time_ms": 5000
}
```

---

## REST API

### Base URL

```
http://<ESP32_IP>:80/api
```

### Endpoints

#### GET `/api/status`

Get current system status.

**Response:**
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

#### GET `/api/history`

Get historical data logs.

**Query Parameters:**
- `start` (optional): Start timestamp (ISO 8601)
- `end` (optional): End timestamp (ISO 8601)
- `limit` (optional): Maximum records (default: 100)

**Response:**
```json
{
  "records": [
    {
      "timestamp": "2026-01-15T10:30:00Z",
      "source": "GRID",
      "grid_voltage": 220.5,
      "generator_voltage": 0.0,
      "load_current": 15.2
    }
  ],
  "count": 100
}
```

#### GET `/api/events`

Get event log.

**Query Parameters:**
- `limit` (optional): Maximum records (default: 50)

**Response:**
```json
{
  "events": [
    {
      "timestamp": "2026-01-15T10:30:00Z",
      "event_type": "SWITCH",
      "event_data": {
        "from": "GRID",
        "to": "GENERATOR"
      }
    }
  ],
  "count": 50
}
```

#### POST `/api/control`

Send control command.

**Request Body:**
```json
{
  "command": "switch_source",
  "value": "GENERATOR"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Switched to GENERATOR"
}
```

#### GET `/api/config`

Get system configuration.

**Response:**
```json
{
  "voltage_threshold_low": 180,
  "voltage_threshold_high": 200,
  "switch_delay_ms": 300,
  "grid_stable_time_ms": 5000
}
```

#### POST `/api/config`

Update system configuration.

**Request Body:**
```json
{
  "voltage_threshold_low": 180,
  "voltage_threshold_high": 200,
  "switch_delay_ms": 300,
  "grid_stable_time_ms": 5000
}
```

**Response:**
```json
{
  "success": true,
  "message": "Configuration updated"
}
```

---

## Bluetooth Protocol

### Service UUID

```
Service: 12345678-1234-1234-1234-123456789abc
```

### Characteristics

#### Status Characteristic

- **UUID:** `12345678-1234-1234-1234-123456789abd`
- **Properties:** Read, Notify
- **Format:** JSON (same as MQTT status)

#### Control Characteristic

- **UUID:** `12345678-1234-1234-1234-123456789abe`
- **Properties:** Write
- **Format:** JSON command

---

## Data Formats

### Power Source Enum

```json
"GRID" | "GENERATOR" | "NONE"
```

### Status Values

```json
"NORMAL" | "FAULT" | "WARNING" | "ERROR"
```

### Event Types

```json
"SWITCH" | "FAULT" | "ALERT" | "STARTUP" | "SHUTDOWN"
```

### Timestamp Format

ISO 8601: `YYYY-MM-DDTHH:MM:SSZ`

---

**Last Updated**: [Current Date]
**Version**: 1.0



