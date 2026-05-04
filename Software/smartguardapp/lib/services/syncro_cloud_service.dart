// lib/services/syncro_cloud_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/apiResponse.dart';
import '../models/sensor_dto_mini.dart';
import '../models/user_scenario.dart';
import 'auth_service.dart';

class SyncroCloudService {
  static String get _baseUrl =>
      kIsWeb ? 'http://localhost:5298/api' : 'http://10.0.2.2:5298/api';
  static const String _hubId = 'SmartGuard-WALID';

  // Singleton pattern
  static final SyncroCloudService _instance = SyncroCloudService._internal();
  factory SyncroCloudService() => _instance;
  SyncroCloudService._internal();

  Future<Map<String, String>> _headers() async {
    final token = await AuthService().getToken();
    final h = {'Content-Type': 'application/json'};
    if (token != null) h['Authorization'] = 'Bearer $token';
    return h;
  }

  SensorDTO_Mini _mapSensor(Map<String, dynamic> j) => SensorDTO_Mini.fromJson(j);

  Future<void> ping() async {
    try {
      await http
          .get(
            Uri.parse('$_baseUrl/devicesensors/device/$_hubId'),
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 5));
    } on TimeoutException {
      throw Exception('Cloud API timeout');
    }
  }

  Future<List<SensorDTO_Mini>> fetchUnits() async {
    final response = await http
        .get(
          Uri.parse('$_baseUrl/devicesensors/device/$_hubId'),
          headers: await _headers(),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data.map((e) => _mapSensor(e as Map<String, dynamic>)).toList();
    }
    _throwHttpError(response);
  }

  Future<List<UserScenario>> fetchScenarios() async {
    final response = await http
        .get(
          Uri.parse('$_baseUrl/devicescenarios/device/$_hubId'),
          headers: await _headers(),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      final result = <UserScenario>[];
      for (final item in data) {
        try {
          final payloadStr =
              (item as Map<String, dynamic>)['payload'] as String? ?? '';
          if (payloadStr.isNotEmpty) {
            final payloadJson =
                json.decode(payloadStr) as Map<String, dynamic>;
            result.add(UserScenario.fromJson(payloadJson));
          }
        } catch (_) {
          // skip entries that can't be parsed
        }
      }
      return result;
    }
    _throwHttpError(response);
  }

  Future<SensorDTO_Mini?> toggleUnit(String sensorId, bool newState) async {
    final action = newState ? 'turn-on' : 'turn-off';
    try {
      final response = await http
          .post(
            Uri.parse(
                '$_baseUrl/remote-actions/$_hubId/sensors/$sensorId/$action'),
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(json.decode(response.body));
        if (apiResponse.isSuccess) {
          if (apiResponse.devicePayload != null) {
            return SensorDTO_Mini.fromJson(apiResponse.devicePayload);
          }
          return null;
        } else {
          throw Exception(apiResponse.errorMessage);
        }
      } else if (response.statusCode == 404) {
        throw Exception('Server not found!');
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Request timed out');
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUnitName({
    required String sensorId,
    required String name,
  }) async {
    final response = await http
        .put(
          Uri.parse(
              '$_baseUrl/remote-actions/$_hubId/sensors/$sensorId/name'),
          headers: await _headers(),
          body: json.encode({'name': name}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 204) return;
    if (response.statusCode == 404) throw Exception('Sensor not found');
    _throwRemoteActionError(response);
  }

  Future<void> enableInchingMode({
    required String sensorId,
    required String unitId,
    required int inchingTimeInMs,
  }) async {
    final response = await http
        .post(
          Uri.parse(
              '$_baseUrl/remote-actions/$_hubId/sensors/$sensorId/inching/enable'),
          headers: await _headers(),
          body: json.encode({
            'unitId': unitId,
            'inchingTimeInMs': inchingTimeInMs,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) return;
    _throwRemoteActionError(response);
  }

  Future<void> disableInchingMode({
    required String sensorId,
    required String unitId,
  }) async {
    final response = await http
        .post(
          Uri.parse(
              '$_baseUrl/remote-actions/$_hubId/sensors/$sensorId/inching/disable'),
          headers: await _headers(),
          body: json.encode({'unitId': unitId}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) return;
    _throwRemoteActionError(response);
  }

  Future<UserScenario?> saveScenario(UserScenario scenario) async {
    final response = await http
        .put(
          Uri.parse('$_baseUrl/remote-actions/$_hubId/scenarios'),
          headers: await _headers(),
          body: json.encode(scenario.toJson()),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) return null;
    _throwRemoteActionError(response);
  }

  Future<void> deleteScenario(String scenarioId) async {
    final response = await http
        .delete(
          Uri.parse(
              '$_baseUrl/remote-actions/$_hubId/scenarios/$scenarioId'),
          headers: await _headers(),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) return;
    _throwRemoteActionError(response);
  }

  Never _throwHttpError(http.Response response) {
    if (response.statusCode == 401) throw Exception('Unauthorized. Please log in again.');
    throw Exception('Request failed: ${response.statusCode}');
  }

  Never _throwRemoteActionError(http.Response response) {
    switch (response.statusCode) {
      case 401:
        throw Exception('Unauthorized. Please log in again.');
      case 422:
        throw Exception('Hub rejected the command');
      case 503:
        throw Exception('Hub is offline');
      case 504:
        throw Exception('Hub did not respond in time');
      default:
        throw Exception('Remote action failed: ${response.statusCode}');
    }
  }
}
