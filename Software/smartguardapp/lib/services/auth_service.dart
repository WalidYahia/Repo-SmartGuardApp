// lib/services/auth_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Must match SyncroCloudService._baseUrl
  static String get _baseUrl =>
      kIsWeb ? 'http://localhost:5298/api' : 'http://10.0.2.2:5298/api';

  static const String _tokenKey = 'syncro_access_token';
  static const String _refreshKey = 'syncro_refresh_token';
  static const String _expiresAtKey = 'syncro_expires_at';

  // Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? _cachedToken;

  Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString(_tokenKey);
    return _cachedToken;
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// POST /api/auth/login — stores access + refresh tokens on success.
  Future<void> login(String emailOrPhone, String password) async {
    final http.Response response;

    try {
      response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'emailOrPhone': emailOrPhone,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      print(e);
      throw Exception('Could not reach the server. Check your connection.');
    }

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      await _storeTokens(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
        expiresAt: data['expiresAt'] as String,
      );
    } else if (response.statusCode == 401) {
      throw Exception('Invalid email/phone or password.');
    } else {
      throw Exception('Login failed (${response.statusCode}).');
    }
  }

  /// POST /api/auth/refresh — silently renews access token.
  /// Returns true on success, false if refresh token is invalid/expired.
  Future<bool> tryRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString(_refreshKey);
    if (refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refreshToken': refreshToken}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        await _storeTokens(
          accessToken: data['accessToken'] as String,
          refreshToken: data['refreshToken'] as String,
          expiresAt: data['expiresAt'] as String,
        );
        return true;
      }
    } catch (_) {}

    return false;
  }

  /// Clear all stored tokens (logout).
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_tokenKey),
      prefs.remove(_refreshKey),
      prefs.remove(_expiresAtKey),
    ]);
    _cachedToken = null;
  }

  Future<void> _storeTokens({
    required String accessToken,
    required String refreshToken,
    required String expiresAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_tokenKey, accessToken),
      prefs.setString(_refreshKey, refreshToken),
      prefs.setString(_expiresAtKey, expiresAt),
    ]);
    _cachedToken = accessToken;
  }
}
