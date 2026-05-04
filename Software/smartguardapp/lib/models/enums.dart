// lib/models/enums.dart

// ── Sensor / Unit ─────────────────────────────────────────

enum SwitchNo {
  non(-1),
  switch1(0),
  switch2(1),
  switch3(2),
  switch4(3),
  switch5(4),
  switch6(5),
  switch7(6),
  switch8(7);

  final int value;
  const SwitchNo(this.value);

  static SwitchNo fromInt(int v) =>
      SwitchNo.values.firstWhere((e) => e.value == v, orElse: () => SwitchNo.non);

  static SwitchNo fromJson(dynamic v) {
    if (v is int) return fromInt(v);
    switch (v?.toString().toLowerCase()) {
      case 'switch1': return SwitchNo.switch1;
      case 'switch2': return SwitchNo.switch2;
      case 'switch3': return SwitchNo.switch3;
      case 'switch4': return SwitchNo.switch4;
      case 'switch5': return SwitchNo.switch5;
      case 'switch6': return SwitchNo.switch6;
      case 'switch7': return SwitchNo.switch7;
      case 'switch8': return SwitchNo.switch8;
      default: return SwitchNo.non;
    }
  }

  int toJson() => value;
}

enum ConnectionProtocol {
  mqtt(0),
  http(1),
  coap(2),
  modbus(3),
  zigbee(4),
  zwave(5),
  ble(6),
  lora(7),
  rs485(8);

  final int value;
  const ConnectionProtocol(this.value);

  static ConnectionProtocol fromInt(int v) =>
      ConnectionProtocol.values.firstWhere((e) => e.value == v,
          orElse: () => ConnectionProtocol.mqtt);

  static ConnectionProtocol fromJson(dynamic v) {
    if (v is int) return fromInt(v);
    switch (v?.toString().toLowerCase()) {
      case 'mqtt':    return ConnectionProtocol.mqtt;
      case 'http':    return ConnectionProtocol.http;
      case 'coap':    return ConnectionProtocol.coap;
      case 'modbus':  return ConnectionProtocol.modbus;
      case 'zigbee':  return ConnectionProtocol.zigbee;
      case 'zwave':   return ConnectionProtocol.zwave;
      case 'ble':     return ConnectionProtocol.ble;
      case 'lora':    return ConnectionProtocol.lora;
      case 'rs485':   return ConnectionProtocol.rs485;
      default:        return ConnectionProtocol.mqtt;
    }
  }

  int toJson() => value;
}

// ── Alarm ─────────────────────────────────────────────────

enum AlarmCondition {
  greaterThan(0),
  greaterThanOrEqual(1),
  lessThan(2),
  lessThanOrEqual(3),
  equal(4),
  between(5);

  final int value;
  const AlarmCondition(this.value);

  static AlarmCondition fromInt(int v) =>
      AlarmCondition.values.firstWhere((e) => e.value == v,
          orElse: () => AlarmCondition.greaterThan);

  static AlarmCondition fromJson(dynamic v) {
    if (v is int) return fromInt(v);
    switch (v?.toString().toLowerCase()) {
      case 'greaterthan':        return AlarmCondition.greaterThan;
      case 'greaterthanorequal': return AlarmCondition.greaterThanOrEqual;
      case 'lessthan':           return AlarmCondition.lessThan;
      case 'lessthanorequal':    return AlarmCondition.lessThanOrEqual;
      case 'equal':              return AlarmCondition.equal;
      case 'between':            return AlarmCondition.between;
      default:                   return AlarmCondition.greaterThan;
    }
  }

  int toJson() => value;
}

enum AlarmSeverity {
  info(0),
  warning(1),
  critical(2);

  final int value;
  const AlarmSeverity(this.value);

  static AlarmSeverity fromInt(int v) =>
      AlarmSeverity.values.firstWhere((e) => e.value == v,
          orElse: () => AlarmSeverity.info);

  static AlarmSeverity fromJson(dynamic v) {
    if (v is int) return fromInt(v);
    switch (v?.toString().toLowerCase()) {
      case 'info':     return AlarmSeverity.info;
      case 'warning':  return AlarmSeverity.warning;
      case 'critical': return AlarmSeverity.critical;
      default:         return AlarmSeverity.info;
    }
  }

  int toJson() => value;
}

// ── Scenario ──────────────────────────────────────────────

enum SwitchOutletStatus {
  off(0),
  on(1);

  final int value;
  const SwitchOutletStatus(this.value);

  static SwitchOutletStatus fromInt(int v) =>
      v == 1 ? SwitchOutletStatus.on : SwitchOutletStatus.off;

  static SwitchOutletStatus fromJson(dynamic v) {
    if (v is int) return fromInt(v);
    switch (v?.toString().toLowerCase()) {
      case 'on':  return SwitchOutletStatus.on;
      default:    return SwitchOutletStatus.off;
    }
  }

  int toJson() => value;
}

enum ScenarioLogic {
  and(0),
  or(1);

  final int value;
  const ScenarioLogic(this.value);

  static ScenarioLogic fromInt(int v) =>
      v == 1 ? ScenarioLogic.or : ScenarioLogic.and;

  static ScenarioLogic fromJson(dynamic v) {
    if (v is int) return fromInt(v);
    switch (v?.toString().toLowerCase()) {
      case 'or':  return ScenarioLogic.or;
      default:    return ScenarioLogic.and;
    }
  }

  int toJson() => value;
}

enum ScenarioCondition {
  duration(0),
  onTime(1),
  onOtherSensorValue(2);

  final int value;
  const ScenarioCondition(this.value);

  static ScenarioCondition fromInt(int v) {
    switch (v) {
      case 1:  return ScenarioCondition.onTime;
      case 2:  return ScenarioCondition.onOtherSensorValue;
      default: return ScenarioCondition.duration;
    }
  }

  static ScenarioCondition fromJson(dynamic v) {
    if (v is int) return fromInt(v);
    switch (v?.toString().toLowerCase()) {
      case 'ontime':              return ScenarioCondition.onTime;
      case 'onothersensorvalue':  return ScenarioCondition.onOtherSensorValue;
      default:                    return ScenarioCondition.duration;
    }
  }

  int toJson() => value;
}

enum ScenarioOperator {
  equals(0),
  notEquals(1),
  greaterThan(2),
  lessThan(3),
  greaterOrEqual(4),
  lessOrEqual(5);

  final int value;
  const ScenarioOperator(this.value);

  static ScenarioOperator fromInt(int v) =>
      ScenarioOperator.values.firstWhere((e) => e.value == v,
          orElse: () => ScenarioOperator.equals);

  static ScenarioOperator fromJson(dynamic v) {
    if (v is int) return fromInt(v);
    switch (v?.toString().toLowerCase()) {
      case 'equals':        return ScenarioOperator.equals;
      case 'notequals':     return ScenarioOperator.notEquals;
      case 'greaterthan':   return ScenarioOperator.greaterThan;
      case 'lessthan':      return ScenarioOperator.lessThan;
      case 'greaterorequal': return ScenarioOperator.greaterOrEqual;
      case 'lessorequal':   return ScenarioOperator.lessOrEqual;
      default:              return ScenarioOperator.equals;
    }
  }

  int toJson() => value;
}

// ── Unit Type (hardware) ───────────────────────────────────

enum UnitType {
  unknown(-1),
  sonoffMiniR3(0),
  sonoffMiniR4M(1);

  final int value;
  const UnitType(this.value);

  static UnitType fromInt(int v) =>
      UnitType.values.firstWhere((e) => e.value == v,
          orElse: () => UnitType.unknown);

  static UnitType fromJson(dynamic v) {
    if (v is int) return fromInt(v);
    switch (v?.toString().toLowerCase()) {
      case 'sonoffminir3':
      case 'sonoffminir3swich': return UnitType.sonoffMiniR3;
      case 'sonoffminir4m': return UnitType.sonoffMiniR4M;
      default:              return UnitType.unknown;
    }
  }

  int toJson() => value;
}

// ── Remote Action ─────────────────────────────────────────

enum JsonCommandType {
  turnOff(0),
  turnOn(1),
  enableInching(2),
  disableInching(3),
  updateUnitName(6),
  saveScenario(10),
  deleteScenario(11);

  final int value;
  const JsonCommandType(this.value);

  int toJson() => value;
}

enum RemoteActionState {
  ok(0, 'Success'),
  error(1, 'Error, unit may be not connected'),
  timeout(3, 'Network Timeout'),
  badRequest(4, 'Bad Request'),
  deviceDataIsRequired(5, 'Device Data Is Required'),
  deviceAlreadyRegistered(6, 'Device Already Registered'),
  deviceNameAlreadyRegistered(7, 'Device Name Already Registered'),
  conflict(8, 'Conflict'),
  inchingIntervalValidationError(9, 'Inching Interval Validation Error'),
  emptyPayload(10, 'Empty Payload'),
  noContent(11, 'No Content');

  final int value;
  final String description;
  const RemoteActionState(this.value, this.description);

  static RemoteActionState fromInt(int v) =>
      RemoteActionState.values.firstWhere((e) => e.value == v,
          orElse: () => RemoteActionState.error);

  static RemoteActionState fromJson(dynamic v) {
    if (v is int) return fromInt(v);
    switch (v?.toString().toLowerCase()) {
      case 'ok':                           return RemoteActionState.ok;
      case 'timeout':                      return RemoteActionState.timeout;
      case 'badrequest':                   return RemoteActionState.badRequest;
      case 'devicedataisrequired':         return RemoteActionState.deviceDataIsRequired;
      case 'devicealreadyregistered':      return RemoteActionState.deviceAlreadyRegistered;
      case 'devicenamealreadyregistered':  return RemoteActionState.deviceNameAlreadyRegistered;
      case 'conflict':                     return RemoteActionState.conflict;
      case 'inchingintervalvalidationerror': return RemoteActionState.inchingIntervalValidationError;
      case 'emptypayload':                 return RemoteActionState.emptyPayload;
      case 'nocontent':                    return RemoteActionState.noContent;
      default:                             return RemoteActionState.error;
    }
  }

  int toJson() => value;
}
