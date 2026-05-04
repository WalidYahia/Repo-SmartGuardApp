// lib/services/unified_smart_home_service.dart

import 'dart:async';
import 'package:smartguardapp/models/user_scenario.dart';
import '../models/sensor_dto_mini.dart';
import 'smart_home_api_service.dart';
import 'syncro_cloud_service.dart';

enum ConnectionMode {
  http,   // Direct HTTP to local hub (LAN)
  cloud,  // SyncroCloud REST API (remote)
}

class UnifiedSmartHomeService {
  final SmartHomeApiService _httpService = SmartHomeApiService();
  final SyncroCloudService _cloudService = SyncroCloudService();

  ConnectionMode? _selectedMode;
  bool _isInitialized = false;
  Timer? _healthCheckTimer;
  static const Duration _healthCheckInterval = Duration(seconds: 30);

  // Singleton pattern
  static final UnifiedSmartHomeService _instance =
      UnifiedSmartHomeService._internal();
  factory UnifiedSmartHomeService() => _instance;
  UnifiedSmartHomeService._internal();

  ConnectionMode? get selectedMode => _selectedMode;
  bool get isInitialized => _isInitialized;

  // Cloud mode has no push stream — callers should poll on refresh
  StreamSubscription<List<SensorDTO_Mini>>? subscribeToDevicesStream(
          Function(List<SensorDTO_Mini>) onData) =>
      null;

  StreamSubscription<List<UserScenario>>? subscribeToUserScenario(
          Function(List<UserScenario>) onData) =>
      null;

  /// Detect the best available connection: local hub first, cloud fallback.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _httpService.ping().timeout(const Duration(seconds: 5));
      _selectedMode = ConnectionMode.http;
    } catch (_) {
      try {
        await _cloudService.ping().timeout(const Duration(seconds: 10));
        _selectedMode = ConnectionMode.cloud;
      } catch (_) {
        throw Exception('No available connection mode');
      }
    }

    _isInitialized = true;
    _startHealthCheck();
  }

  void _startHealthCheck() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer =
        Timer.periodic(_healthCheckInterval, (_) => _performHealthCheck());
  }

  Future<void> _performHealthCheck() async {
    if (!_isInitialized || _selectedMode == null) return;

    try {
      if (_selectedMode == ConnectionMode.http) {
        await _httpService.ping().timeout(const Duration(seconds: 5));
      } else {
        await _cloudService.ping().timeout(const Duration(seconds: 10));
      }
    } catch (_) {
      await _autoSwitchMode();
    }
  }

  Future<void> _autoSwitchMode() async {
    try {
      if (_selectedMode == ConnectionMode.http) {
        await _cloudService.ping().timeout(const Duration(seconds: 10));
        _selectedMode = ConnectionMode.cloud;
      } else {
        await _httpService.ping().timeout(const Duration(seconds: 5));
        _selectedMode = ConnectionMode.http;
      }
    } catch (_) {
      // both unreachable — keep current mode, retry on next tick
    }
  }

  Future<void> _ensureInitialized() async {
    const maxAttempts = 100;
    int attempts = 0;
    while (!_isInitialized || _selectedMode == null) {
      if (attempts++ > maxAttempts) {
        throw Exception('Service initialization timed out');
      }
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  Future<List<SensorDTO_Mini>> fetchUnits() async {
    await _ensureInitialized();
    return _selectedMode == ConnectionMode.http
        ? await _httpService.fetchUnits()
        : await _cloudService.fetchUnits();
  }

  Future<List<UserScenario>> fetchScenarios() async {
    await _ensureInitialized();
    return _selectedMode == ConnectionMode.http
        ? await _httpService.fetchScenarios()
        : await _cloudService.fetchScenarios();
  }

  Future<UserScenario?> saveScenario(UserScenario scenario) async {
    await _ensureInitialized();
    return _selectedMode == ConnectionMode.http
        ? await _httpService.saveScenario(scenario)
        : await _cloudService.saveScenario(scenario);
  }

  Future<UserScenario?> addScenario(UserScenario scenario) =>
      saveScenario(scenario);

  Future<UserScenario?> updateScenario(UserScenario scenario) =>
      saveScenario(scenario);

  Future<void> deleteScenario(String scenarioId) async {
    await _ensureInitialized();
    if (_selectedMode == ConnectionMode.http) {
      await _httpService.deleteScenario(scenarioId);
    } else {
      await _cloudService.deleteScenario(scenarioId);
    }
  }

  Future<SensorDTO_Mini?> toggleUnit(String sensorId, bool newState) async {
    await _ensureInitialized();
    return _selectedMode == ConnectionMode.http
        ? await _httpService.toggleUnit(sensorId, newState)
        : await _cloudService.toggleUnit(sensorId, newState);
  }

  Future<void> updateUnitName({
    required String sensorId,
    required String name,
  }) async {
    await _ensureInitialized();
    if (_selectedMode == ConnectionMode.http) {
      await _httpService.updateUnitName(sensorId: sensorId, name: name);
    } else {
      await _cloudService.updateUnitName(sensorId: sensorId, name: name);
    }
  }

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
          inchingTimeInMs: inchingTimeInMs);
    } else {
      await _cloudService.enableInchingMode(
          sensorId: sensorId,
          unitId: unitId,
          inchingTimeInMs: inchingTimeInMs);
    }
  }

  Future<void> disableInchingMode({
    required String sensorId,
    required String unitId,
  }) async {
    await _ensureInitialized();
    if (_selectedMode == ConnectionMode.http) {
      await _httpService.disableInchingMode(sensorId: sensorId, unitId: unitId);
    } else {
      await _cloudService.disableInchingMode(
          sensorId: sensorId, unitId: unitId);
    }
  }

  Future<void> switchMode(ConnectionMode mode) async {
    if (_selectedMode == mode) return;
    _selectedMode = mode;
  }

  Future<void> reset() async {
    _healthCheckTimer?.cancel();
    _isInitialized = false;
    _selectedMode = null;
    await initialize();
  }

  void disconnect() {
    _healthCheckTimer?.cancel();
  }
}
