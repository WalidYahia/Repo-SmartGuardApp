// lib/services/smart_home_api_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sensor_dto.dart';
import '../models/apiResponse.dart';

class SmartHomeApiService {

  static const String baseUrl = 'http://192.168.1.2:5000/api';
  
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
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(json.decode(response.body));
      
      if (apiResponse.isSuccess) {
        final List<dynamic> jsonData = apiResponse.devicePayload ?? [];
        return jsonData.map((json) => SensorDTO.fromJson(json)).toList();
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
Future<SensorDTO?> toggleUnit(String sensorId, bool currentState) async {
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
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) 
      {
        final apiResponse = ApiResponse.fromJson(json.decode(response.body));
        
        if (apiResponse.isSuccess) 
        {
          if (apiResponse.devicePayload != null) 
          {
            return SensorDTO.fromJson(apiResponse.devicePayload);
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
}