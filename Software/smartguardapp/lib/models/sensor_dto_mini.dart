import 'enums.dart';

String? _stripQuotes(String? v) {
  if (v == null) return null;
  if (v.length >= 2 && v.startsWith('"') && v.endsWith('"')) {
    return v.substring(1, v.length - 1);
  }
  return v;
}

class SensorDTO_Mini {
  final String sensorConfigId;
  final String deviceId;
  final String sensorId_fk;
  final String unitId;
  final String displayName;
  final UnitType sensorType;
  final bool isInInchingMode;
  final int inchingModeWidthInMs;
  final dynamic lastReading;
  final DateTime lastSeen;


  SensorDTO_Mini({
    required this.sensorConfigId,
    required this.deviceId,
    required this.sensorId_fk,
    required this.unitId,
    required this.displayName,
    required this.sensorType,
    required this.isInInchingMode,
    required this.inchingModeWidthInMs,
    this.lastReading,
    required this.lastSeen,
  });

  String get name => displayName;

  factory SensorDTO_Mini.fromJson(Map<String, dynamic> json) {
    return SensorDTO_Mini(
      sensorConfigId: json['id'] ?? '',
      deviceId: json['deviceId'] ?? '',
      sensorId_fk: json['sensorId'] ?? '',
      unitId: json['unitId'] ?? '',
      displayName: json['displayName'] ?? '',
      sensorType: UnitType.fromJson(json['sensorType'] ?? -1),
      isInInchingMode: json['isInInchingMode'] ?? false,
      inchingModeWidthInMs: json['inchingModeWidthInMs'] ?? 0,
      lastReading: _stripQuotes(json['lastReading']?.toString()),
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': sensorConfigId,
      'deviceId': deviceId,
      'sensorId': sensorId_fk,
      'unitId': unitId,
      'displayName': displayName,
      'sensorType': sensorType.toJson(),
      'isInInchingMode': isInInchingMode,
      'inchingModeWidthInMs': inchingModeWidthInMs,
      'lastReading': lastReading,
      'lastSeen': lastSeen.toIso8601String(),
    };
  }

  bool get isOn {
    if (lastReading is bool) return lastReading;
    if (lastReading is String) {
      final v = (lastReading as String).toLowerCase();
      return v == 'on' || v == '1' || v == 'true';
    }
    if (lastReading is int) return lastReading == 1;
    return false;
  }

  SensorDTO_Mini copyWith({dynamic lastReading}) {
    return SensorDTO_Mini(
      sensorConfigId: sensorConfigId,
      deviceId: deviceId,
      sensorId_fk: sensorId_fk,
      unitId: unitId,
      displayName: displayName,
      sensorType: sensorType,
      isInInchingMode: isInInchingMode,
      inchingModeWidthInMs: inchingModeWidthInMs,
      lastReading: lastReading ?? this.lastReading,
      lastSeen: lastSeen,
    );
  }
}
