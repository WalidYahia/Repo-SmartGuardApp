// lib/services/unified_smart_home_service.dart

import 'dart:async';
import 'package:smartguardapp/models/user_scenario.dart';

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
  Timer? _healthCheckTimer;
  static const Duration _healthCheckInterval = Duration(seconds: 10);

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

  /// Subscribe to devices stream (only in MQTT mode)
  /// Returns StreamSubscription to allow caller to cancel if needed
  StreamSubscription<List<SensorDTO_Mini>>? subscribeToDevicesStream(Function(List<SensorDTO_Mini>) onData) {
    if (_selectedMode == ConnectionMode.mqtt) {
      return _mqttService.devicesStream.listen(onData);
    }
    return null;
  }

    StreamSubscription<List<UserScenario>>? subscribeToUserScenario(Function(List<UserScenario>) onData) {
    if (_selectedMode == ConnectionMode.mqtt) {
      return _mqttService.userScenariosStream.listen(onData);
    }
    return null;
  }


  /// Initialize the service by detecting available connection mode
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _httpService.ping().timeout(const Duration(seconds: 5));
      _selectedMode = ConnectionMode.http;
    } catch (_) {
      final connected = await _mqttService.connect();
      if (!connected) {
        throw Exception('No available connection mode');
      }
      _selectedMode = ConnectionMode.mqtt;
    }

    _isInitialized = true;
    _startHealthCheck();
  }

  /// Start periodic health check to detect connection failures and auto-switch
  void _startHealthCheck() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(_healthCheckInterval, (_) async {
      await _performHealthCheck();
    });
  }

  /// Check current connection and auto-switch if needed
  Future<void> _performHealthCheck() async {
    if (!_isInitialized || _selectedMode == null) return;

    try {
      if (_selectedMode == ConnectionMode.http) {
        // Test HTTP connection
        await _httpService.ping().timeout(const Duration(seconds: 5));
      } else {
        // Test MQTT connection
        if (!_mqttService.isConnected) {
          throw Exception('MQTT disconnected');
        }
      }
    } catch (e) {
      // Current connection failed, try to switch to the other mode
      await _autoSwitchMode();
    }
  }

  /// Automatically switch to available connection mode
  Future<void> _autoSwitchMode() async {
    final currentMode = _selectedMode;

    try {
      if (currentMode == ConnectionMode.http) {
        // HTTP failed, try MQTT
        print('HTTP connection lost, switching to MQTT...');
        final connected = await _mqttService.connect();
        if (connected) {
          _selectedMode = ConnectionMode.mqtt;
          print('Successfully switched to MQTT');
          return;
        }
      } else if (currentMode == ConnectionMode.mqtt) {
        // MQTT failed, try HTTP
        print('MQTT connection lost, switching to HTTP...');
        try {
          await _httpService.ping().timeout(const Duration(seconds: 5));
          _selectedMode = ConnectionMode.http;
          print('Successfully switched to HTTP');
          return;
        } catch (_) {}
      }
    } catch (e) {
      print('Failed to auto-switch connection mode: $e');
    }
  }

  /// Waits until service is initialized and connection mode is selected
  Future<void> _ensureInitialized() async {
    const maxAttempts = 100; // 5 seconds max (100 * 50ms)
    int attempts = 0;
    while (!_isInitialized || _selectedMode == null) {
      if (attempts++ > maxAttempts) {
        throw Exception('Service initialization timed out');
      }
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  /// Ensures MQTT connection is active (connects if needed)
  Future<void> _ensureMqttConnected() async {
    if (!_mqttService.isConnected) {
      final connected = await _mqttService.connect();
      if (!connected) {
        throw Exception('Could not connect to the server');
      }
    }
  }

  /// Fetch all units using the selected connection mode
  Future<List<UserScenario>> fetchScenarios() async {
    await _ensureInitialized();

    if (_selectedMode == ConnectionMode.http) {
      return await _httpService.fetchScenarios();
    } else {
      await _ensureMqttConnected();
      return await _mqttService.fetchScenarios();
    }
  }

  /// Fetch all units using the selected connection mode
  Future<List<SensorDTO_Mini>> fetchUnits() async {
    await _ensureInitialized();

    if (_selectedMode == ConnectionMode.http) {
      return await _httpService.fetchUnits();
    } else {
      await _ensureMqttConnected();
      return await _mqttService.fetchUnits();
    }
  }

/// Save (add or update) scenario and return saved scenario if available
Future<UserScenario?> saveScenario(UserScenario scenario) async {
  await _ensureInitialized();

  if (_selectedMode == ConnectionMode.http) {
    return await _httpService.saveScenario(scenario);
  } else {
    await _ensureMqttConnected();
    return await _mqttService.saveScenario(scenario);
  }
}

/// Add scenario (wrapper)
Future<UserScenario?> addScenario(UserScenario scenario) async {
  return await saveScenario(scenario);
}

/// Update scenario (wrapper)
Future<UserScenario?> updateScenario(UserScenario scenario) async {
  return await saveScenario(scenario);
}

/// Delete scenario
Future<void> deleteScenario(String scenarioId) async {
  await _ensureInitialized();

  if (_selectedMode == ConnectionMode.http) {
    await _httpService.deleteScenario(scenarioId);
  } else {
    await _ensureMqttConnected();
    await _mqttService.deleteScenario(scenarioId);
  }
}

  /// Toggle unit on/off using the selected connection mode
  Future<SensorDTO_Mini?> toggleUnit(String sensorId, bool newState) async {
    await _ensureInitialized();

    if (_selectedMode == ConnectionMode.http) {
      return await _httpService.toggleUnit(sensorId, newState);
    } else {
      await _ensureMqttConnected();
      return await _mqttService.toggleUnit(sensorId, newState);
    }
  }

  /// Update unit name
  Future<void> updateUnitName({
    required String sensorId,
    required String name,
  }) async {
    await _ensureInitialized();

    if (_selectedMode == ConnectionMode.http) {
      await _httpService.updateUnitName(sensorId: sensorId, name: name);
    } else {
      await _ensureMqttConnected();
      await _mqttService.updateUnitName(sensorId: sensorId, name: name);
    }
  }

  /// Enable inching mode
  Future<void> enableInchingMode({
    required String sensorId,
    required String unitId,
    required int inchingTimeInMs,
  }) async {
    await _ensureInitialized();

    if (_selectedMode == ConnectionMode.http) {
      await _httpService.enableInchingMode(
        sensorId: sensorId,
        unitId: unitId,
        inchingTimeInMs: inchingTimeInMs,
      );
    } else {
      await _ensureMqttConnected();
      await _mqttService.enableInchingMode(
        sensorId: sensorId,
        unitId: unitId,
        inchingTimeInMs: inchingTimeInMs,
      );
    }
  }

  /// Disable inching mode
  Future<void> disableInchingMode({
    required String sensorId,
    required String unitId,
  }) async {
    await _ensureInitialized();

    if (_selectedMode == ConnectionMode.http) {
      await _httpService.disableInchingMode(sensorId: sensorId, unitId: unitId);
    } else {
      await _ensureMqttConnected();
      await _mqttService.disableInchingMode(sensorId: sensorId, unitId: unitId);
    }
  }

  /// Manually switch connection mode (disconnect/connect as needed)
  Future<void> switchMode(ConnectionMode mode) async {
    if (_selectedMode == mode) return;

    if (_selectedMode == ConnectionMode.mqtt) {
      _mqttService.disconnect();
    }

    _selectedMode = mode;

    if (mode == ConnectionMode.mqtt) {
      final connected = await _mqttService.connect();
      if (!connected) throw Exception('Could not connect to MQTT');
    }
  }

  /// Reset and reinitialize service (useful for troubleshooting)
  Future<void> reset() async {
    _healthCheckTimer?.cancel();
    _isInitialized = false;
    _selectedMode = null;
    _mqttService.disconnect();
    await initialize();
  }

  /// Disconnect MQTT connection
  void disconnect() {
    _healthCheckTimer?.cancel();
    _mqttService.disconnect();
  }
}
