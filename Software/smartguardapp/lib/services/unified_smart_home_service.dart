// lib/services/unified_smart_home_service.dart

import '../models/sensor_dto_mini.dart';
import 'smart_home_api_service.dart';
import 'mqtt_service.dart';

enum ConnectionMode {
  http,  // Direct HTTP calls to local hub
  mqtt,  // MQTT broker communication
}

class UnifiedSmartHomeService {
  final SmartHomeApiService _httpService = SmartHomeApiService();
  final MqttService _mqttService = MqttService();
  
  ConnectionMode? _selectedMode;
  bool _isInitialized = false;

  // Singleton pattern
  static final UnifiedSmartHomeService _instance = UnifiedSmartHomeService._internal();
  factory UnifiedSmartHomeService() => _instance;
  UnifiedSmartHomeService._internal();

  // Get current connection mode
  ConnectionMode? get selectedMode => _selectedMode;
  
  // Check if service is initialized
  bool get isInitialized => _isInitialized;

  // Check if MQTT is connected
  bool get isMqttConnected => _mqttService.isConnected;

  // Subscribe to devices stream (for MQTT mode)
  void subscribeToDevicesStream(Function(List<SensorDTO_Mini>) onData) {
    if (_selectedMode == ConnectionMode.mqtt) {
      _mqttService.devicesStream.listen(onData);
    }
  }

  // Initialize and determine connection mode (call once on app startup)
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Try HTTP first
    try {
      await _httpService.fetchUnits().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('HTTP timeout'),
      );
      _selectedMode = ConnectionMode.http;
      _isInitialized = true;
      return;
    } catch (httpError) {
      // HTTP failed, try MQTT
      try {
        final connected = await _mqttService.connect();
        if (connected) {
          _selectedMode = ConnectionMode.mqtt;
          _isInitialized = true;
          return;
        }
      } catch (mqttError) {
        // Both failed
      }
    }

    // If both failed, default to MQTT and let individual calls handle errors
    _selectedMode = ConnectionMode.mqtt;
    _isInitialized = true;
  }

  // Fetch all units using selected mode
  Future<List<SensorDTO_Mini>> fetchUnits() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_selectedMode == ConnectionMode.http) {
      return await _httpService.fetchUnits();
    } else {
      // Ensure MQTT is connected
      if (!_mqttService.isConnected) {
        final connected = await _mqttService.connect();
        if (!connected) {
          throw Exception('Could not connect to the server');
        }
      }
      return await _mqttService.fetchUnits();
    }
  }

  // Toggle unit using selected mode
  Future<SensorDTO_Mini?> toggleUnit(String sensorId, bool newState) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_selectedMode == ConnectionMode.http) {
      return await _httpService.toggleUnit(sensorId, newState);
    } else {
      // Ensure MQTT is connected
      if (!_mqttService.isConnected) {
        final connected = await _mqttService.connect();
        if (!connected) {
          throw Exception('Could not connect to the server');
        }
      }
      return await _mqttService.toggleUnit(sensorId, newState);
    }
  }

 // Update unit name
  Future<void> updateUnitName({
    required String sensorId,
    required String name,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_selectedMode == ConnectionMode.http) {
      await _httpService.updateUnitName(sensorId: sensorId, name: name);
    } else {
      // Ensure MQTT is connected
      if (!_mqttService.isConnected) {
        final connected = await _mqttService.connect();
        if (!connected) {
          throw Exception('Could not connect to the server');
        }
      }
      await _mqttService.updateUnitName(sensorId: sensorId, name: name);
    }
  }

  // Enable inching mode
  Future<void> enableInchingMode({
    required String sensorId,
    required String unitId,
    required int inchingTimeInMs,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_selectedMode == ConnectionMode.http) {
      await _httpService.enableInchingMode(
        sensorId: sensorId,
        unitId: unitId,
        inchingTimeInMs: inchingTimeInMs,
      );
    } else {
      // Ensure MQTT is connected
      if (!_mqttService.isConnected) {
        final connected = await _mqttService.connect();
        if (!connected) {
          throw Exception('Could not connect to the server');
        }
      }
      await _mqttService.enableInchingMode(
        sensorId: sensorId,
        unitId: unitId,
        inchingTimeInMs: inchingTimeInMs,
      );
    }
  }

  // Disable inching mode
  Future<void> disableInchingMode({
    required String sensorId,
    required String unitId,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_selectedMode == ConnectionMode.http) {
      await _httpService.disableInchingMode(sensorId: sensorId, unitId: unitId);
    } else {
      // Ensure MQTT is connected
      if (!_mqttService.isConnected) {
        final connected = await _mqttService.connect();
        if (!connected) {
          throw Exception('Could not connect to the server');
        }
      }
      await _mqttService.disableInchingMode(sensorId: sensorId, unitId: unitId);
    }
  }

  // Manually switch connection mode (optional)
  void switchMode(ConnectionMode mode) {
    _selectedMode = mode;
  }

  // Reset and reinitialize (useful for troubleshooting)
  Future<void> reset() async {
    _isInitialized = false;
    _selectedMode = null;
    _mqttService.disconnect();
    await initialize();
  }

  // Disconnect MQTT
  void disconnect() {
    _mqttService.disconnect();
  }
}