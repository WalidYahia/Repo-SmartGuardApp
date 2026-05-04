import 'enums.dart';

class SensorDTO {
  final String id;
  final String deviceId;
  final String sensorId;
  final SwitchNo switchNo;
  final String unitId;
  final String? address;
  final int? port;
  final String displayName;
  final String? url;
  final UnitType sensorType;
  final ConnectionProtocol protocol;
  final String? baseUrl;
  final String? portNo;
  final String? dataPath;
  final String? infoPath;
  final String? inchingPath;
  final int syncPeriodicity;
  final bool eventChangeSync;
  final double eventChangeDelta;
  final bool isInInchingMode;
  final int inchingModeWidthInMs;
  final DateTime installedAt;
  final bool isActive;
  final String? notes;
  final String? lastReading;
  final bool isOnline;
  final DateTime lastSeen;
  final DateTime? lastTimeValueSet;

  SensorDTO({
    required this.id,
    required this.deviceId,
    required this.sensorId,
    required this.switchNo,
    required this.unitId,
    this.address,
    this.port,
    required this.displayName,
    this.url,
    required this.sensorType,
    required this.protocol,
    this.baseUrl,
    this.portNo,
    this.dataPath,
    this.infoPath,
    this.inchingPath,
    required this.syncPeriodicity,
    required this.eventChangeSync,
    required this.eventChangeDelta,
    required this.isInInchingMode,
    required this.inchingModeWidthInMs,
    required this.installedAt,
    required this.isActive,
    this.notes,
    this.lastReading,
    required this.isOnline,
    required this.lastSeen,
    this.lastTimeValueSet,
  });

  String get name => displayName;

  factory SensorDTO.fromJson(Map<String, dynamic> json) {
    return SensorDTO(
      id: json['id'] ?? '',
      deviceId: json['deviceId'] ?? '',
      sensorId: json['sensorId'] ?? '',
      switchNo: SwitchNo.fromJson(json['switchNo'] ?? -1),
      unitId: json['unitId'] ?? '',
      address: json['address'],
      port: json['port'],
      displayName: json['displayName'] ?? '',
      url: json['url'],
      sensorType: UnitType.fromJson(json['sensorType'] ?? -1),
      protocol: ConnectionProtocol.fromJson(json['protocol'] ?? 0),
      baseUrl: json['baseUrl'],
      portNo: json['portNo'],
      dataPath: json['dataPath'],
      infoPath: json['infoPath'],
      inchingPath: json['inchingPath'],
      syncPeriodicity: json['syncPeriodicity'] ?? 10,
      eventChangeSync: json['eventChangeSync'] ?? true,
      eventChangeDelta: (json['eventChangeDelta'] ?? 1).toDouble(),
      isInInchingMode: json['isInInchingMode'] ?? false,
      inchingModeWidthInMs: json['inchingModeWidthInMs'] ?? 0,
      installedAt: json['installedAt'] != null
          ? DateTime.parse(json['installedAt'])
          : DateTime.now(),
      isActive: json['isActive'] ?? true,
      notes: json['notes'],
      lastReading: json['lastReading']?.toString(),
      isOnline: json['isOnline'] ?? false,
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
      'switchNo': switchNo.toJson(),
      'unitId': unitId,
      'address': address,
      'port': port,
      'displayName': displayName,
      'url': url,
      'sensorType': sensorType.toJson(),
      'protocol': protocol.toJson(),
      'baseUrl': baseUrl,
      'portNo': portNo,
      'dataPath': dataPath,
      'infoPath': infoPath,
      'inchingPath': inchingPath,
      'syncPeriodicity': syncPeriodicity,
      'eventChangeSync': eventChangeSync,
      'eventChangeDelta': eventChangeDelta,
      'isInInchingMode': isInInchingMode,
      'inchingModeWidthInMs': inchingModeWidthInMs,
      'installedAt': installedAt.toIso8601String(),
      'isActive': isActive,
      'notes': notes,
      'lastReading': lastReading,
      'isOnline': isOnline,
      'lastSeen': lastSeen.toIso8601String(),
      'lastTimeValueSet': lastTimeValueSet?.toIso8601String(),
    };
  }

  bool get isOn {
    if (lastReading == null) return false;
    final v = lastReading!.toLowerCase();
    return v == 'true' || v == 'on' || v == '1';
  }
}
