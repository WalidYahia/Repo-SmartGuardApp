class SensorDTO {
  final String sensorId;
  final String unitId;
  final int switchNo;
  final String name;
  final String? url;
  final int type;
  final int protocol;
  final DateTime createdAt;
  final DateTime lastSeen;
  final bool isInInchingMode;
  final int inchingModeWidthInMs;
  final dynamic latestValue;
  final String? fwVersion;
  final String? rawResponse;

  SensorDTO({
    required this.sensorId,
    required this.unitId,
    required this.switchNo,
    required this.name,
    this.url,
    required this.type,
    required this.protocol,
    required this.createdAt,
    required this.lastSeen,
    required this.isInInchingMode,
    required this.inchingModeWidthInMs,
    this.latestValue,
    this.fwVersion,
    this.rawResponse,
  });

  factory SensorDTO.fromJson(Map<String, dynamic> json) {
    return SensorDTO(
      sensorId: json['sensorId'] ?? '',
      unitId: json['unitId'] ?? '',
      switchNo: json['switchNo'] ?? 0,
      name: json['name'] ?? '',
      url: json['url'],
      type: json['type'] ?? 0,
      protocol: json['protocol'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      lastSeen: DateTime.parse(json['lastSeen']),
      isInInchingMode: json['isInInchingMode'] ?? false,
      inchingModeWidthInMs: json['inchingModeWidthInMs'] ?? 0,
      latestValue: json['latestValue'],
      fwVersion: json['fwVersion'],
      rawResponse: json['rawResponse'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sensorId': sensorId,
      'unitId': unitId,
      'switchNo': switchNo,
      'name': name,
      'url': url,
      'type': type,
      'protocol': protocol,
      'createdAt': createdAt.toIso8601String(),
      'lastSeen': lastSeen.toIso8601String(),
      'isInInchingMode': isInInchingMode,
      'inchingModeWidthInMs': inchingModeWidthInMs,
      'latestValue': latestValue,
      'fwVersion': fwVersion,
      'rawResponse': rawResponse,
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