import 'enums.dart';

String? _stripQuotes(String? v) {
  if (v == null) return null;
  if (v.length >= 2 && v.startsWith('"') && v.endsWith('"')) {
    return v.substring(1, v.length - 1);
  }
  return v;
}

class SensorDTO_Mini {
  final String id;
  final String deviceId;
  final String sensorId;
  final String unitId;
  final SwitchNo switchNo;
  final String? address;
  final int? port;
  final String displayName;
  final String? url;
  final UnitType sensorType;
  final ConnectionProtocol protocol;
  final String? baseUrl;
  final String? portNo;
  final bool isInInchingMode;
  final int inchingModeWidthInMs;
  final bool isActive;
  final bool isOnline;
  final dynamic lastReading;
  final DateTime lastSeen;
  final DateTime? lastTimeValueSet;

  SensorDTO_Mini({
    required this.id,
    required this.deviceId,
    required this.sensorId,
    required this.unitId,
    required this.switchNo,
    this.address,
    this.port,
    required this.displayName,
    this.url,
    required this.sensorType,
    required this.protocol,
    this.baseUrl,
    this.portNo,
    required this.isInInchingMode,
    required this.inchingModeWidthInMs,
    required this.isActive,
    required this.isOnline,
    this.lastReading,
    required this.lastSeen,
    this.lastTimeValueSet,
  });

  String get name => displayName;

  factory SensorDTO_Mini.fromJson(Map<String, dynamic> json) {
    return SensorDTO_Mini(
      id: json['id'] ?? '',
      deviceId: json['deviceId'] ?? '',
      sensorId: json['sensorId'] ?? '',
      unitId: json['unitId'] ?? '',
      switchNo: SwitchNo.fromJson(json['switchNo'] ?? -1),
      address: json['address'],
      port: json['port'],
      displayName: json['displayName'] ?? '',
      url: json['url'],
      sensorType: UnitType.fromJson(json['sensorType'] ?? -1),
      protocol: ConnectionProtocol.fromJson(json['protocol'] ?? 0),
      baseUrl: json['baseUrl'],
      portNo: json['portNo'],
      isInInchingMode: json['isInInchingMode'] ?? false,
      inchingModeWidthInMs: json['inchingModeWidthInMs'] ?? 0,
      isActive: json['isActive'] ?? true,
      isOnline: json['isOnline'] ?? false,
      lastReading: _stripQuotes(json['lastReading']?.toString()),
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'])
          : DateTime.now(),
      lastTimeValueSet: json['lastTimeValueSet'] != null
          ? DateTime.parse(json['lastTimeValueSet'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceId': deviceId,
      'sensorId': sensorId,
      'unitId': unitId,
      'switchNo': switchNo.toJson(),
      'address': address,
      'port': port,
      'displayName': displayName,
      'url': url,
      'sensorType': sensorType.toJson(),
      'protocol': protocol.toJson(),
      'baseUrl': baseUrl,
      'portNo': portNo,
      'isInInchingMode': isInInchingMode,
      'inchingModeWidthInMs': inchingModeWidthInMs,
      'isActive': isActive,
      'isOnline': isOnline,
      'lastReading': lastReading,
      'lastSeen': lastSeen.toIso8601String(),
      'lastTimeValueSet': lastTimeValueSet?.toIso8601String(),
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
      id: id,
      deviceId: deviceId,
      sensorId: sensorId,
      unitId: unitId,
      switchNo: switchNo,
      address: address,
      port: port,
      displayName: displayName,
      url: url,
      sensorType: sensorType,
      protocol: protocol,
      baseUrl: baseUrl,
      portNo: portNo,
      isInInchingMode: isInInchingMode,
      inchingModeWidthInMs: inchingModeWidthInMs,
      isActive: isActive,
      isOnline: isOnline,
      lastReading: lastReading ?? this.lastReading,
      lastSeen: lastSeen,
      lastTimeValueSet: lastTimeValueSet,
    );
  }
}
