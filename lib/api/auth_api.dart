import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:localizy/api/main_api.dart';

class AuthException implements Exception {
  final String message;
  AuthException([this.message = 'Authentication failed']);
  @override
  String toString() => 'AuthException: $message';
}

class AuthUser {
  final String token;
  final String email;
  final String fullName;
  final String role;
  final String userId;

  AuthUser({
    required this.token,
    required this.email,
    required this.fullName,
    required this.role,
    required this.userId,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      token: json['token'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      role: json['role'] ?? '',
      userId: json['userId'] ?? '',
    );
  }
}

class AuthService {
  static const _tokenKey = 'auth_token';
  static final _storage = const FlutterSecureStorage();

  /// Login and persist token if returned.
  static Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final resp = await MainApi.instance.postJson(
      'api/auth/login',
      {'email': email, 'password': password},
    );

    if (resp.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(resp.body);
      final user = AuthUser.fromJson(data);
      if (user.token.isNotEmpty) {
        await _storage.write(key: _tokenKey, value: user.token);
      }
      return user;
    }

    String message = 'Login failed';
    try {
      final body = json.decode(resp.body);
      if (body is Map && body['message'] != null) {
        message = body['message'].toString();
      } else if (body is String && body.isNotEmpty) {
        message = body;
      }
    } catch (_) {}
    throw AuthException(message);
  }

  /// Register a new user using API and persist returned token.
  static Future<AuthUser> register({
    required String email,
    required String fullName,
    required String password,
  }) async {
    final resp = await MainApi.instance.postJson(
      'api/auth/register',
      {'email': email, 'fullName': fullName, 'password': password},
    );

    if (resp.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(resp.body);
      final user = AuthUser.fromJson(data);
      if (user.token.isNotEmpty) {
        await _storage.write(key: _tokenKey, value: user.token);
      }
      return user;
    }

    String message = 'Register failed';
    try {
      final body = json.decode(resp.body);
      if (body is Map && body['message'] != null) {
        message = body['message'].toString();
      } else if (body is String && body.isNotEmpty) {
        message = body;
      }
    } catch (_) {}
    throw AuthException(message);
  }

  /// Remove stored token (logout).
  static Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Get currently stored token (if any).
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }
}