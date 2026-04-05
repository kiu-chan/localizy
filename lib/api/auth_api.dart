import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:localizy/api/main_api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  /// Sign in with Google via Firebase, then authenticate with backend.
  static Future<AuthUser> googleLogin() async {
    debugPrint('[AuthService.googleLogin] Launching Google sign-in picker...');
    final googleSignIn = GoogleSignIn();
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      debugPrint('[AuthService.googleLogin] User cancelled the sign-in dialog.');
      throw AuthException('Google sign-in cancelled');
    }
    debugPrint('[AuthService.googleLogin] Google user selected: ${googleUser.email}');

    final googleAuth = await googleUser.authentication;
    debugPrint('[AuthService.googleLogin] Got Google auth — accessToken=${googleAuth.accessToken != null ? 'present' : 'null'} idToken=${googleAuth.idToken != null ? 'present' : 'null'}');

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    debugPrint('[AuthService.googleLogin] Firebase sign-in OK — uid=${userCredential.user?.uid}');

    final idToken = await userCredential.user?.getIdToken();
    if (idToken == null) {
      debugPrint('[AuthService.googleLogin] Failed to get Firebase ID token.');
      throw AuthException('Could not get Firebase ID token');
    }
    debugPrint('[AuthService.googleLogin] Firebase ID token obtained, calling backend...');

    final resp = await MainApi.instance.postJson(
      'api/auth/google-login',
      {'idToken': idToken},
    );
    debugPrint('[AuthService.googleLogin] Backend response: ${resp.statusCode}');

    if (resp.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(resp.body);
      final user = AuthUser.fromJson(data);
      if (user.token.isNotEmpty) {
        await _storage.write(key: _tokenKey, value: user.token);
      }
      await _storage.write(key: _userKey, value: json.encode(data));
      return user;
    }

    String message = 'Google login failed';
    try {
      final body = json.decode(resp.body);
      if (body is Map && body['message'] != null) {
        message = body['message'].toString();
      }
    } catch (_) {}
    throw AuthException(message);
  }

  /// Request a password reset email.
  static Future<void> forgotPassword({required String email}) async {
    final resp = await MainApi.instance.postJson(
      'api/auth/forgot-password',
      {'email': email},
    );

    if (resp.statusCode == 200) return;

    String message = 'Failed to send reset email';
    try {
      final body = json.decode(resp.body);
      if (body is Map && body['message'] != null) {
        message = body['message'].toString();
      }
    } catch (_) {}
    throw AuthException(message);
  }

  /// Register FCM token with the server for push notifications.
  /// Call this after every login and when Firebase issues a new token.
  static Future<void> registerFcmToken(String fcmToken) async {
    final resp = await MainApi.instance.putJson(
      'api/auth/fcm-token',
      {'fcmToken': fcmToken},
    );
    if (resp.statusCode != 200) {
      debugPrint('[FCM] registerFcmToken failed: ${resp.statusCode} ${resp.body}');
    }
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