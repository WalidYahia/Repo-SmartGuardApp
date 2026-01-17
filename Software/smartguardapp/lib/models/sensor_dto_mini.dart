class SensorDTO_Mini {
  final String sensorId;
  final String unitId;
  final String name;
  final int type;
  final DateTime lastSeen;
  final bool isInInchingMode;
  final int inchingModeWidthInMs;
  final dynamic latestValue;

  SensorDTO_Mini({
    required this.sensorId,
    required this.unitId,
    required this.name,
    required this.type,
    required this.lastSeen,
    required this.isInInchingMode,
    required this.inchingModeWidthInMs,
    this.latestValue,
  });

  factory SensorDTO_Mini.fromJson(Map<String, dynamic> json) {
    return SensorDTO_Mini(
      sensorId: json['sensorId'] ?? '',
      unitId: json['unitId'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 0,
      lastSeen: DateTime.parse(json['lastSeen']),
      isInInchingMode: json['isInInchingMode'] ?? false,
      inchingModeWidthInMs: json['inchingModeWidthInMs'] ?? 0,
      latestValue: json['latestValue'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sensorId': sensorId,
      'unitId': unitId,
      'name': name,
      'type': type,
      'lastSeen': lastSeen.toIso8601String(),
      'isInInchingMode': isInInchingMode,
      'inchingModeWidthInMs': inchingModeWidthInMs,
      'latestValue': latestValue,
    };
  }

  // Get current switch state from latestValue
  bool get isOn {
    if (latestValue is bool) return latestValue;
    if (latestValue is String) {
      return latestValue.toLowerCase() == 'on' || latestValue == '1';
    }
    if (latestValue is int) return latestValue == 1;
    return false;
  }
}