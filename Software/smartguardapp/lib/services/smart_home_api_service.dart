// lib/services/smart_home_api_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sensor_dto_mini.dart';
import '../models/apiResponse.dart';

class SmartHomeApiService {

  static const String baseUrl = 'http://smartGuard-000000002e5c0c51:5000/api';
  
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
Future<List<SensorDTO_Mini>> fetchUnits() async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/Devices/handleUserCommand'),
      headers: _getHeaders(),
      body: json.encode({'JsonCommandType': 7}),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(json.decode(response.body));
      
      if (apiResponse.isSuccess) {
        final List<dynamic> jsonData = apiResponse.devicePayload ?? [];
        return jsonData.map((json) => SensorDTO_Mini.fromJson(json)).toList();
      } else {
        throw Exception(apiResponse.errorMessage);
      }
    } else {
      throw Exception('Failed to load units: ${response.statusCode}');
    }
  }   
  on TimeoutException {
    throw Exception('Request timed out. Please check your connection.');
  }  
  catch (e) {
    throw Exception('Error fetching units: $e');
  }
}

// Toggle unit on/off and return updated sensor data
Future<SensorDTO_Mini?> toggleUnit(String sensorId, bool currentState) async {
  try {
      final response = await http.post(
        Uri.parse('$baseUrl/Devices/handleUserCommand'),
        headers: _getHeaders(),
        body: json.encode({
          'JsonCommandType': currentState ? 1 : 0,
          'CommandPayload': {
            'InstalledSensorId': sensorId
          }
        }),
      ).timeout(const Duration(seconds: 1));

      if (response.statusCode == 200) 
      {
        final apiResponse = ApiResponse.fromJson(json.decode(response.body));
        
        if (apiResponse.isSuccess) 
        {
          if (apiResponse.devicePayload != null) 
          {
            return SensorDTO_Mini.fromJson(apiResponse.devicePayload);
          }
          return null;
        } 
        else 
        {
          throw Exception(apiResponse.state.description);
        }
      } 
      else
      {
        if (response.statusCode == 404)
        {
          throw Exception("Server not found !");
        }
        else 
        {
          throw Exception("Server Error : $response");
        }
      }
    }
    on TimeoutException 
    {
      throw Exception('Request timed out');
    } 
    on http.ClientException catch (e) 
    {
      throw Exception('Network error: ${e.message}');
    } 
    catch (e) 
    {
      rethrow;
    }
  }

  // Update unit name via HTTP
Future<void> updateUnitName({
  required String sensorId,
  required String name,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/Devices/handleUserCommand'),
      headers: _getHeaders(),
      body: json.encode({
        'JsonCommandType': 6,
        'CommandPayload': {
          'InstalledSensorId': sensorId,
          'Name': name,
        }
      }),
    );

    if (response.statusCode == 200) {
      final generalResponse = ApiResponse.fromJson(json.decode(response.body));
      
      if (!generalResponse.isSuccess) {
        throw Exception(generalResponse.errorMessage);
      }
    } else {
      throw Exception('Failed to update name: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error updating name: $e');
  }
}

// Enable inching mode via HTTP
Future<void> enableInchingMode({
  required String sensorId,
  required String unitId,
  required int inchingTimeInMs,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/Devices/handleUserCommand'),
      headers: _getHeaders(),
      body: json.encode({
        'JsonCommandType': 2,
        'CommandPayload': {
          'InstalledSensorId': sensorId,
          'UnitId': unitId,
          'InchingTimeInMs': inchingTimeInMs,
        }
      }),
    );

    if (response.statusCode == 200) {
      final generalResponse = ApiResponse.fromJson(json.decode(response.body));
      
      if (!generalResponse.isSuccess) {
        throw Exception(generalResponse.errorMessage);
      }
    } else {
      throw Exception('Failed to enable inching mode: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error enabling inching mode: $e');
  }
}

// Disable inching mode via HTTP
Future<void> disableInchingMode({
  required String sensorId,
  required String unitId,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/Devices/handleUserCommand'),
      headers: _getHeaders(),
      body: json.encode({
        'JsonCommandType': 3,
        'CommandPayload': {
          'InstalledSensorId': sensorId,
          'UnitId': unitId,
        }
      }),
    );

    if (response.statusCode == 200) {
      final generalResponse = ApiResponse.fromJson(json.decode(response.body));
      
      if (!generalResponse.isSuccess) {
        throw Exception(generalResponse.errorMessage);
      }
    } else {
      throw Exception('Failed to disable inching mode: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error disabling inching mode: $e');
  }
}
}