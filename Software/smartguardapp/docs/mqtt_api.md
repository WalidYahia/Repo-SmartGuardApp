# SmartGuard MQTT API Reference

## Connection

| Parameter  | Value |
|------------|-------|
| Broker     | `5cb35f5ee0c643b58bc4c341167c1687.s1.eu.hivemq.cloud` |
| Port       | `8883` (TLS) |
| Username   | `smartGuard` |
| Protocol   | MQTT v3.1.1 |

---

## Topics

All topics are prefixed with the hub ID (e.g. `SmartGuard-000000002e5c0c51`).

| Topic | Direction | Description |
|-------|-----------|-------------|
| `{hubId}/RemoteAction` | Publish (app → hub) | Send commands to the hub |
| `{hubId}/RemoteAction_Ack` | Subscribe (hub → app) | Receive command acknowledgements |
| `{hubId}/InstalledUnits` | Subscribe (hub → app) | Live list of all installed sensors/units |
| `{hubId}/UserScenarios` | Subscribe (hub → app) | Live list of all user-defined scenarios |

---

## Command Envelope

Every message published to `{hubId}/RemoteAction` uses this JSON envelope:

```json
{
  "RequestId": "string",
  "JsonCommandType": 0,
  "CommandPayload": {}
}
```

| Field | Type | Description |
|-------|------|-------------|
| `RequestId` | string | Unique ID used to correlate the ACK response. Format: `{timestampMs}_{clientId}` |
| `JsonCommandType` | int | Command type code (see table below) |
| `CommandPayload` | object | Command-specific payload (omit if not required) |

---

## Command Types

### 0 — Turn Off Unit

```json
{
  "RequestId": "1234567890_MobileApp-1",
  "JsonCommandType": 0,
  "CommandPayload": {
    "InstalledSensorId": "sensor-uuid"
  }
}
```

### 1 — Turn On Unit

```json
{
  "RequestId": "1234567890_MobileApp-1",
  "JsonCommandType": 1,
  "CommandPayload": {
    "InstalledSensorId": "sensor-uuid"
  }
}
```

### 2 — Enable Inching Mode

```json
{
  "RequestId": "1234567890_MobileApp-1",
  "JsonCommandType": 2,
  "CommandPayload": {
    "InstalledSensorId": "sensor-uuid",
    "UnitId": "unit-uuid",
    "InchingTimeInMs": 1000
  }
}
```

### 3 — Disable Inching Mode

```json
{
  "RequestId": "1234567890_MobileApp-1",
  "JsonCommandType": 3,
  "CommandPayload": {
    "InstalledSensorId": "sensor-uuid",
    "UnitId": "unit-uuid"
  }
}
```

### 6 — Update Unit Name

```json
{
  "RequestId": "1234567890_MobileApp-1",
  "JsonCommandType": 6,
  "CommandPayload": {
    "InstalledSensorId": "sensor-uuid",
    "Name": "Living Room Light"
  }
}
```

### 10 — Save (Add / Update) Scenario

```json
{
  "RequestId": "1234567890_MobileApp-1",
  "JsonCommandType": 10,
  "CommandPayload": {
    "UserScenario": {
      "id": "scenario-uuid",
      "name": "Night Mode",
      "isEnabled": true,
      "targetSensorId": "sensor-uuid",
      "action": 0,
      "logicOfConditions": 0,
      "conditions": [
        {
          "condition": 1,
          "durationInSeconds": 0,
          "time": "22:00:00",
          "sensorsDependency": null
        }
      ]
    }
  }
}
```

### 11 — Delete Scenario

```json
{
  "RequestId": "1234567890_MobileApp-1",
  "JsonCommandType": 11,
  "CommandPayload": {
    "UserScenario": {
      "id": "scenario-uuid"
    }
  }
}
```

---

## ACK Response (`{hubId}/RemoteAction_Ack`)

```json
{
  "requestId": "1234567890_MobileApp-1",
  "state": 0,
  "devicePayload": {}
}
```

| Field | Type | Description |
|-------|------|-------------|
| `requestId` | string | Matches the `RequestId` from the request |
| `state` | int | Response state code (see table below) |
| `devicePayload` | any | Returned data (e.g. updated sensor object), or error message string |

### Response State Codes

| Code | Name | Description |
|------|------|-------------|
| 0 | ok | Success |
| 1 | error | Error — unit may not be connected |
| 3 | timeout | Network timeout |
| 4 | badRequest | Bad request |
| 5 | deviceDataIsRequired | Device data is required |
| 6 | deviceAlreadyRegistered | Device already registered |
| 7 | deviceNameAlreadyRegistered | Device name already registered |
| 8 | conflict | Conflict |
| 9 | inchingIntervalValidationError | Inching interval validation error |
| 10 | emptyPayload | Empty payload |
| 11 | noContent | No content |

---

## Push Data Schemas

### InstalledUnits payload — array of `SensorDTO_Mini`

Published by the hub on `{hubId}/InstalledUnits`:

```json
[
  {
    "sensorId": "sensor-uuid",
    "unitId": "unit-uuid",
    "name": "Kitchen Switch",
    "type": 0,
    "lastSeen": "2024-01-01T12:00:00.000Z",
    "isInInchingMode": false,
    "inchingModeWidthInMs": 0,
    "latestValue": true
  }
]
```

| Field | Type | Description |
|-------|------|-------------|
| `type` | int | `0` = SonoffMiniR3, `1` = SonoffMiniR4M |
| `latestValue` | bool / int / string | Current state: `true`/`1`/`"on"` = ON |

### UserScenarios payload — array of `UserScenario`

Published by the hub on `{hubId}/UserScenarios`:

```json
[
  {
    "id": "scenario-uuid",
    "name": "Night Mode",
    "isEnabled": true,
    "targetSensorId": "sensor-uuid",
    "action": 0,
    "logicOfConditions": 0,
    "conditions": [
      {
        "condition": 1,
        "durationInSeconds": 0,
        "time": "22:00:00",
        "sensorsDependency": [
          {
            "sensorId": "sensor-uuid",
            "sensorType": 0,
            "value": "1",
            "operator": 0
          }
        ]
      }
    ]
  }
]
```

#### Enum values

**`action`** (`SwitchOutletStatus`)

| Value | Meaning |
|-------|---------|
| 0 | off |
| 1 | on |

**`logicOfConditions`** (`ScenarioLogic`)

| Value | Meaning |
|-------|---------|
| 0 | AND |
| 1 | OR |

**`condition`** (`ScenarioCondition`)

| Value | Meaning |
|-------|---------|
| 0 | duration |
| 1 | onTime |
| 2 | onOtherSensorValue |

**`operator`** (`ScenarioOperator`)

| Value | Meaning |
|-------|---------|
| 0 | equals |
| 1 | notEquals |
| 2 | greaterThan |
| 3 | lessThan |
| 4 | greaterOrEqual |
| 5 | lessOrEqual |

**`sensorType`** (`UnitType`)

| Value | Meaning |
|-------|---------|
| -1 | unknown |
| 0 | SonoffMiniR3 |
| 1 | SonoffMiniR4M |
