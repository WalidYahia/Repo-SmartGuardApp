// lib/services/mqtt_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../models/apiResponse.dart';
import '../models/sensor_dto_mini.dart';
import 'package:flutter/foundation.dart'; // Add this import

// Add this helper function outside the class
List<SensorDTO_Mini> _parseDevices(String payload) {
  final List<dynamic> jsonData = json.decode(payload);
  return jsonData.map((json) => SensorDTO_Mini.fromJson(json)).toList();
}

class MqttService {

  // static const String hubId = "SmartGuard-WALID";
  // static const String clientId = 'MobileApp-Emulator';

  static const String hubId = "SmartGuard-000000002e5c0c51";
  static const String clientId = 'MobileApp-1';

  //   static const String hubId = "SmartGuard-000000002e5c0c51";
  // static const String clientId = 'Tablet-1';

  static const String broker = '5cb35f5ee0c643b58bc4c341167c1687.s1.eu.hivemq.cloud'; // Your MQTT broker IP
  static const int port = 8883;
  static const String username = 'smartGuard'; // Optional
  static const String password = 'WWyy_0106116'; // Optional
   static const bool useTls = true; // Set to false if not using TLS
  // Topics
  // static const String publishTopic = 'SmartGuard-WALID/RemoteAction';
  // static const String subscribeTopic = 'SmartGuard-WALID/RemoteAction_Ack';
  
  static String installedUnitsTopic = '$hubId/InstalledUnits';
  static const String publishTopic = '$hubId/RemoteAction';
  static const String remoteAckTopic = '$hubId/RemoteAction_Ack';

  static const Duration responseTimeout = Duration(seconds: 5);
  
  MqttServerClient? _client;
  bool _isConnected = false;
  
  // Map to track pending requests
  final Map<String, Completer<ApiResponse>> _pendingRequests = {};
  
  // Singleton pattern
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal();

  bool get isConnected => _isConnected;

  List<SensorDTO_Mini> _latestDevices = [];
  StreamController<List<SensorDTO_Mini>>? _devicesStreamController;

  // Get devices stream
  Stream<List<SensorDTO_Mini>> get devicesStream {
    _devicesStreamController ??= StreamController<List<SensorDTO_Mini>>.broadcast();
    return _devicesStreamController!.stream;
  }
  
  // Get latest devices list
  List<SensorDTO_Mini> get latestDevices => _latestDevices;

  // Connect to MQTT broker
  Future<bool> connect() async {
  if (_isConnected) return true;

  try {
    _client = MqttServerClient.withPort(broker, clientId, port);
    _client!.logging(on: false);
    _client!.keepAlivePeriod = 20;
    _client!.onDisconnected = _onDisconnected;
    _client!.onConnected = _onConnected;
    _client!.autoReconnect = true;
    _client!.setProtocolV311();

    // CRITICAL: Enable TLS for HiveMQ Cloud
    _client!.secure = true;
    _client!.securityContext = SecurityContext.defaultContext;
    _client!.onBadCertificate = (dynamic certificate) => true;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .authenticateAs(username, password)
        .keepAliveFor(20)
        .withWillQos(MqttQos.atMostOnce)
        .startClean();
    
    _client!.connectionMessage = connMessage;

    //print('Attempting MQTT connection to $broker:$port...');
    await _client!.connect();

    if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
      //print('MQTT Connected successfully');
      _isConnected = true;
      _subscribeToAckTopic();
      return true;
    } else {
      //print('MQTT Connection failed: ${_client!.connectionStatus}');
      _client!.disconnect();
      return false;
    }
  } catch (e) {
    print('MQTT Connection error: $e');
    _client?.disconnect();
    return false;
  }
}

  void _onConnected() {
    print('MQTT Connected');
    _isConnected = true;
    _subscribeToAckTopic();
  }

  void _onDisconnected() {
    print('MQTT Disconnected');
    _isConnected = false;
    
    // Fail all pending requests
    for (var completer in _pendingRequests.values) {
      if (!completer.isCompleted) {
        completer.completeError(Exception('Connection lost'));
      }
    }
    _pendingRequests.clear();
  }

  // void _subscribeToAckTopic() {
  //   if (_client == null || !_isConnected) return;

  //   _client!.subscribe(subscribeTopic, MqttQos.atLeastOnce);
    
  //   _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
  //     for (var message in messages) {
  //       final payload = MqttPublishPayload.bytesToStringAsString(
  //         (message.payload as MqttPublishMessage).payload.message,
  //       );
  //       _handleAckMessage(payload);
  //     }
  //   });
  // }

    void _subscribeToAckTopic() {
    if (_client == null || !_isConnected) return;

    // Subscribe to command acknowledgements
    _client!.subscribe(remoteAckTopic, MqttQos.atLeastOnce);
    
    // Subscribe to devices topic
    _client!.subscribe(installedUnitsTopic, MqttQos.atLeastOnce);
    
    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      for (var message in messages) {
        final topic = message.topic;
        final payload = MqttPublishPayload.bytesToStringAsString(
          (message.payload as MqttPublishMessage).payload.message,
        );
        
        if (topic == remoteAckTopic) {
          _handleAckMessage(payload);
        } else if (topic == installedUnitsTopic) {
          _handleDevicesMessage(payload);
        }
      }
    });
  }

void _handleDevicesMessage(String payload) async {
  try {
    // ✅ Parse on background thread
    final devices = await compute(_parseDevices, payload);
    _latestDevices = devices;
    
    _devicesStreamController ??= StreamController<List<SensorDTO_Mini>>.broadcast();
    _devicesStreamController!.add(_latestDevices);
  } catch (e) {
    print('Error parsing devices message: $e');
  }
}

  void _handleAckMessage(String payload) {
    try {
      final jsonData = json.decode(payload);
      final response = ApiResponse.fromJson(jsonData);
      
      final requestId = response.requestId;
      if (requestId != null && _pendingRequests.containsKey(requestId)) {
        final completer = _pendingRequests[requestId];
        if (!completer!.isCompleted) {
          completer.complete(response);
        }
        _pendingRequests.remove(requestId);
      }
    } catch (e) {
      print('Error parsing ACK message: $e');
    }
  }

  // Generate unique request ID
  String _generateRequestId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${clientId}';
  }

  // Publish command and wait for response
  Future<ApiResponse> publishCommand({
    required int jsonCommandType,
    Map<String, dynamic>? commandPayload,
  }) async {
    // Check connection
    if (!_isConnected) {
      final connected = await connect();
      if (!connected) {
        throw Exception('Could not connect to the server');
      }
    }

    final requestId = _generateRequestId();
    final completer = Completer<ApiResponse>();
    _pendingRequests[requestId] = completer;

    // Build message
    final message = {
      'RequestId': requestId,
      'JsonCommandType': jsonCommandType,
      if (commandPayload != null) 'CommandPayload': commandPayload,
    };

    try {
      // Publish message
      final builder = MqttClientPayloadBuilder();
      builder.addString(json.encode(message));
      _client!.publishMessage(
        publishTopic,
        MqttQos.atLeastOnce,
        builder.payload!,
      );

      // Wait for response with timeout
      final response = await completer.future.timeout(
        responseTimeout,
        onTimeout: () {
          _pendingRequests.remove(requestId);
          throw TimeoutException('No response from the device');
        },
      );

      return response;
    } catch (e) {
      _pendingRequests.remove(requestId);
      if (e is TimeoutException) {
        throw Exception('No response from the device');
      }
      throw Exception('Could not connect to the server');
    }
  }

  // // Fetch all units via MQTT
  // Future<List<SensorDTO_Mini>> fetchUnits() async {
  //   try {
  //     final response = await publishCommand(jsonCommandType: 7);

  //     if (response.isSuccess) {
  //       final List<dynamic> jsonData = response.devicePayload ?? [];
  //       return jsonData.map((json) => SensorDTO_Mini.fromJson(json)).toList();
  //     } else {
  //       throw Exception(response.errorMessage);
  //     }
  //   } catch (e) {
  //     rethrow;
  //   }
  // }
  Future<List<SensorDTO_Mini>> fetchUnits() async {
    try {
      // Ensure MQTT is connected
      if (!_isConnected) {
        final connected = await connect();
        if (!connected) {
          throw Exception('Could not connect to the server');
        }
      }
      
      // Wait a moment for initial data if devices list is empty
      if (_latestDevices.isEmpty) {
        await Future.delayed(const Duration(seconds: 2));
      }
      
      // Return the latest devices list
      if (_latestDevices.isEmpty) {
        throw Exception('No devices available');
      }
      
      return _latestDevices;
    } catch (e) {
      rethrow;
    }
  }


  // Toggle unit via MQTT
  Future<SensorDTO_Mini?> toggleUnit(String sensorId, bool newState) async {
    try {
      final response = await publishCommand(
        jsonCommandType: newState ? 1 : 0,
        commandPayload: {'InstalledSensorId': sensorId},
      );

      if (response.isSuccess) {
        if (response.devicePayload != null) {
          return SensorDTO_Mini.fromJson(response.devicePayload);
        }
        return null;
      } else {
        throw Exception(response.errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update unit name via MQTT
Future<void> updateUnitName({
  required String sensorId,
  required String name,
}) async {
  try {
    final response = await publishCommand(
      jsonCommandType: 6,
      commandPayload: {
        'InstalledSensorId': sensorId,
        'Name': name,
      },
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage);
    }
  } catch (e) {
    rethrow;
  }
}

// Enable inching mode via MQTT
Future<void> enableInchingMode({
  required String sensorId,
  required String unitId,
  required int inchingTimeInMs,
}) async {
  try {
    final response = await publishCommand(
      jsonCommandType: 2,
      commandPayload: {
        'InstalledSensorId': sensorId,
        'UnitId': unitId,
        'InchingTimeInMs': inchingTimeInMs,
      },
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage);
    }
  } catch (e) {
    rethrow;
  }
}

// Disable inching mode via MQTT
Future<void> disableInchingMode({
  required String sensorId,
  required String unitId,
}) async {
  try {
    final response = await publishCommand(
      jsonCommandType: 3,
      commandPayload: {
        'InstalledSensorId': sensorId,
        'UnitId': unitId,
      },
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage);
    }
  } catch (e) {
    rethrow;
  }
}

  // Disconnect from broker
  void disconnect() {
    _client?.disconnect();
    _isConnected = false;
    _pendingRequests.clear();
    _devicesStreamController?.close();
    _devicesStreamController = null;
  }
}