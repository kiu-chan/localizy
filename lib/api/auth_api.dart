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
      userId: json['userId'] ?? json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'email': email,
      'fullName': fullName,
      'role': role,
      'userId': userId,
    };
  }
}

class AuthService {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';
  static final _storage = const FlutterSecureStorage();

  /// Login and persist token + returned user info.
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
      // store full user payload so other parts can use userId, name, email, ...
      await _storage.write(key: _userKey, value: json.encode(data));
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

  /// Register a new user using API and persist returned token + user info.
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
      await _storage.write(key: _userKey, value: json.encode(data));
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

  /// Remove stored token and user (logout).
  static Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  /// Get currently stored token (if any).
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Get stored user payload (if any).
  static Future<AuthUser?> getStoredUser() async {
    try {
      final s = await _storage.read(key: _userKey);
      if (s == null) return null;
      final Map<String, dynamic> data = json.decode(s);
      return AuthUser.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  /// Convenience: get stored userId if available.
  static Future<String?> getStoredUserId() async {
    final u = await getStoredUser();
    return u?.userId;
  }

  /// Update stored user payload (replace with new payload). Useful after profile update.
  static Future<void> updateStoredUserPayload(Map<String, dynamic> newPayload) async {
    try {
      await _storage.write(key: _userKey, value: json.encode(newPayload));
      // If token is part of new payload, update token too
      if (newPayload['token'] != null && (newPayload['token'] as String).isNotEmpty) {
        await _storage.write(key: _tokenKey, value: newPayload['token'] as String);
      }
    } catch (_) {}
  }
}