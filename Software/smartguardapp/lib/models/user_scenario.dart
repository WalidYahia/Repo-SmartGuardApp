// lib/models/user_scenario.dart

import 'enums.dart';
export 'enums.dart'
    show
        SwitchOutletStatus,
        ScenarioLogic,
        ScenarioCondition,
        ScenarioOperator,
        UnitType;

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
      sensorType: UnitType.fromJson(json['sensorType'] ?? -1),
      value: json['value']?.toString() ?? '',
      operator: ScenarioOperator.fromJson(json['operator'] ?? 0),
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
      condition: ScenarioCondition.fromJson(json['condition'] ?? 0),
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
      'sensorsDependency': sensorsDependency?.map((s) => s.toJson()).toList(),
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
      action: SwitchOutletStatus.fromJson(json['action'] ?? 0),
      logicOfConditions: ScenarioLogic.fromJson(json['logicOfConditions'] ?? 0),
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
