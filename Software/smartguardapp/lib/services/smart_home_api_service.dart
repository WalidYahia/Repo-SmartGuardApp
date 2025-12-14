// lib/services/smart_home_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sensor_dto.dart';

class SmartHomeApiService {

  static const String baseUrl = 'http://192.168.1.4:5000/api';
  
  static const String? authToken = null;

  // Get headers with authentication if needed
  Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    return headers;
  }

  // Fetch all units/sensors
Future<List<SensorDTO>> fetchUnits() async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/Devices/handleUserCommand'),
      headers: _getHeaders(),
      body: json.encode({'JsonCommandType': 7}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> jsonData = jsonResponse['devicePayload'] ?? [];
      return jsonData.map((json) => SensorDTO.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load units: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching units: $e');
  }
}

  // Toggle unit on/off
  Future<bool> toggleUnit(String sensorId, bool newState) async {
    try {
      // TODO: Adjust the endpoint and body structure based on your API
      final response = await http.post(
        Uri.parse('$baseUrl/sensors/$sensorId/toggle'),
        headers: _getHeaders(),
        body: json.encode({'state': newState}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to toggle unit: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error toggling unit: $e');
    }
  }

  // Alternative: Set unit state (if your API uses PUT/PATCH)
  Future<bool> setUnitState(String sensorId, bool state) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/sensors/$sensorId/state'),
        headers: _getHeaders(),
        body: json.encode({'isOn': state}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to set unit state: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error setting unit state: $e');
    }
  }
}