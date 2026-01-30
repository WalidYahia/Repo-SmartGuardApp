// lib/models/user_scenario.dart

enum SwitchOutletStatus {
  off(0),
  on(1);

  final int value;
  const SwitchOutletStatus(this.value);

  static SwitchOutletStatus fromInt(int v) =>
      v == 1 ? SwitchOutletStatus.on : SwitchOutletStatus.off;

  int toJson() => value;
}

enum ScenarioLogic {
  and(0),
  or(1);

  final int value;
  const ScenarioLogic(this.value);

  static ScenarioLogic fromInt(int v) =>
      v == 1 ? ScenarioLogic.or : ScenarioLogic.and;

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
      case 1:
        return ScenarioCondition.onTime;
      case 2:
        return ScenarioCondition.onOtherSensorValue;
      default:
        return ScenarioCondition.duration;
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

  static ScenarioOperator fromInt(int v) {
    switch (v) {
      case 1:
        return ScenarioOperator.notEquals;
      case 2:
        return ScenarioOperator.greaterThan;
      case 3:
        return ScenarioOperator.lessThan;
      case 4:
        return ScenarioOperator.greaterOrEqual;
      case 5:
        return ScenarioOperator.lessOrEqual;
      default:
        return ScenarioOperator.equals;
    }
  }

  int toJson() => value;
}

enum UnitType {
  unknown(-1),
  sonoffMiniR3(0),
  sonoffMiniR4M(1);

  final int value;
  const UnitType(this.value);

  static UnitType fromInt(int v) {
    switch (v) {
      case 0:
        return UnitType.sonoffMiniR3;
      case 1:
        return UnitType.sonoffMiniR4M;
      default:
        return UnitType.unknown;
    }
  }

  int toJson() => value;
}

class UserScenarioSensor {
  final String sensorId;
  final UnitType sensorType;
  final String value;
  final ScenarioOperator operator;

  UserScenarioSensor({
    required this.sensorId,
    required this.sensorType,
    required this.value,
    required this.operator,
  });

  factory UserScenarioSensor.fromJson(Map<String, dynamic> json) {
    return UserScenarioSensor(
      sensorId: json['sensorId'] ?? '',
      sensorType: UnitType.fromInt(json['sensorType'] ?? -1),
      value: json['value']?.toString() ?? '',
      operator: ScenarioOperator.fromInt(json['operator'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sensorId': sensorId,
      'sensorType': sensorType.toJson(),
      'value': value,
      'operator': operator.toJson(),
    };
  }
}

class UserScenarioCondition {
  final ScenarioCondition condition;
  final int durationInSeconds;
  final String time;
  final List<UserScenarioSensor>? sensorsDependency;

  UserScenarioCondition({
    required this.condition,
    required this.durationInSeconds,
    required this.time,
    this.sensorsDependency,
  });

  factory UserScenarioCondition.fromJson(Map<String, dynamic> json) {
    return UserScenarioCondition(
      condition: ScenarioCondition.fromInt(json['condition'] ?? 0),
      durationInSeconds: json['durationInSeconds'] ?? 0,
      time: json['time'] ?? '00:00:00',
      sensorsDependency: json['sensorsDependency'] != null
          ? (json['sensorsDependency'] as List)
              .map((s) => UserScenarioSensor.fromJson(s))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'condition': condition.toJson(),
      'durationInSeconds': durationInSeconds,
      'time': time,
      'sensorsDependency':
          sensorsDependency?.map((s) => s.toJson()).toList(),
    };
  }
}

class UserScenario {
  final String id;
  final String name;
  final bool isEnabled;
  final String targetSensorId;
  final SwitchOutletStatus action;
  final ScenarioLogic logicOfConditions;
  final List<UserScenarioCondition> conditions;

  UserScenario({
    required this.id,
    required this.name,
    required this.isEnabled,
    required this.targetSensorId,
    required this.action,
    required this.logicOfConditions,
    required this.conditions,
  });

  factory UserScenario.fromJson(Map<String, dynamic> json) {
    return UserScenario(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      isEnabled: json['isEnabled'] ?? false,
      targetSensorId: json['targetSensorId'] ?? '',
      action: SwitchOutletStatus.fromInt(json['action'] ?? 0),
      logicOfConditions:
          ScenarioLogic.fromInt(json['logicOfConditions'] ?? 0),
      conditions: (json['conditions'] as List? ?? [])
          .map((c) => UserScenarioCondition.fromJson(c))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isEnabled': isEnabled,
      'targetSensorId': targetSensorId,
      'action': action.toJson(),
      'logicOfConditions': logicOfConditions.toJson(),
      'conditions': conditions.map((c) => c.toJson()).toList(),
    };
  }

  UserScenario copyWith({
    String? id,
    String? name,
    bool? isEnabled,
    String? targetSensorId,
    SwitchOutletStatus? action,
    ScenarioLogic? logicOfConditions,
    List<UserScenarioCondition>? conditions,
  }) {
    return UserScenario(
      id: id ?? this.id,
      name: name ?? this.name,
      isEnabled: isEnabled ?? this.isEnabled,
      targetSensorId: targetSensorId ?? this.targetSensorId,
      action: action ?? this.action,
      logicOfConditions: logicOfConditions ?? this.logicOfConditions,
      conditions: conditions ?? this.conditions,
    );
  }
}
