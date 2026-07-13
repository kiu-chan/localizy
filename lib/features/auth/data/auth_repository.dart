import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:localizy/core/network/api_client.dart';

import '../domain/auth_exception.dart';
import '../domain/user.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiClientProvider)),
);

/// Gom AuthService + UserProfileService + LogoutService cũ:
/// đăng nhập/đăng ký, phiên (token + user trong secure storage) và profile.
class AuthRepository {
  AuthRepository(this._client, {FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  // ── Tương thích ngược cho code chưa migrate (gỡ ở Giai đoạn 6) ──────────────
  static AuthRepository? _instance;
  static AuthRepository get instance =>
      _instance ??= AuthRepository(ApiClient.instance);

  final ApiClient _client;
  final FlutterSecureStorage _storage;

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  // ── Đăng nhập / đăng ký ────────────────────────────────────────────────────

  Future<User> login({required String email, required String password}) async {
    final resp = await _client.postJson(
      'api/auth/login',
      {'email': email, 'password': password},
    );
    return _handleAuthResponse(resp, 'Login failed');
  }

  Future<User> register({
    required String email,
    required String fullName,
    required String password,
  }) async {
    final resp = await _client.postJson(
      'api/auth/register',
      {'email': email, 'fullName': fullName, 'password': password},
    );
    return _handleAuthResponse(resp, 'Register failed');
  }

  static bool _googleSignInInitialized = false;

  /// Đăng nhập Google qua Firebase rồi xác thực với backend.
  Future<User> googleLogin() async {
    final googleSignIn = GoogleSignIn.instance;
    if (!_googleSignInInitialized) {
      await googleSignIn.initialize();
      _googleSignInInitialized = true;
    }

    final GoogleSignInAccount googleUser;
    try {
      googleUser = await googleSignIn.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw AuthException('Google sign-in cancelled');
      }
      debugPrint('[AuthRepository.googleLogin] Google sign-in failed: $e');
      throw AuthException('Google sign-in failed');
    }

    final credential = GoogleAuthProvider.credential(
      idToken: googleUser.authentication.idToken,
    );
    final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    final idToken = await userCredential.user?.getIdToken();
    if (idToken == null) {
      throw AuthException('Could not get Firebase ID token');
    }

    final resp = await _client.postJson(
      'api/auth/google-login',
      {'idToken': idToken},
    );
    return _handleAuthResponse(resp, 'Google login failed');
  }

  Future<void> forgotPassword({required String email}) async {
    final resp = await _client.postJson(
      'api/auth/forgot-password',
      {'email': email},
    );
    if (resp.statusCode == 200) return;
    throw AuthException(
        _errorMessage(resp.body, 'Failed to send reset email'));
  }

  /// Đăng ký FCM token với server. Gọi sau mỗi lần đăng nhập
  /// và khi Firebase cấp token mới.
  Future<void> registerFcmToken(String fcmToken) async {
    final resp = await _client.putJson(
      'api/auth/fcm-token',
      {'fcmToken': fcmToken},
    );
    if (resp.statusCode != 200) {
      debugPrint(
          '[FCM] registerFcmToken failed: ${resp.statusCode} ${resp.body}');
    }
  }

  // ── Phiên đăng nhập ────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<User?> getStoredUser() async {
    try {
      final s = await _storage.read(key: _userKey);
      if (s == null) return null;
      return User.fromJson(json.decode(s) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<String?> getStoredUserId() async => (await getStoredUser())?.userId;

  /// Ghi đè payload user đã lưu (sau khi cập nhật profile).
  Future<void> updateStoredUserPayload(Map<String, dynamic> newPayload) async {
    try {
      await _storage.write(key: _userKey, value: json.encode(newPayload));
      final token = newPayload['token'];
      if (token is String && token.isNotEmpty) {
        await _storage.write(key: _tokenKey, value: token);
      }
    } catch (_) {}
  }

  // ── Profile (từ UserProfileService cũ) ─────────────────────────────────────

  /// GET /api/users/{id} — profile đầy đủ của user hiện tại.
  Future<Map<String, dynamic>> fetchCurrentUserProfile() async {
    final userId = await getStoredUserId();
    if (userId == null || userId.isEmpty) {
      throw Exception('No stored user id. User might not be logged in.');
    }
    final jsonResp = await _client.getJson('api/users/$userId');
    if (jsonResp is Map<String, dynamic>) return jsonResp;
    throw Exception('Unexpected response from user profile API');
  }

  /// PUT /api/users/{id} — các field đều tùy chọn.
  Future<Map<String, dynamic>> updateProfile({
    String? userId,
    String? name,
    String? dateOfBirth,
    String? phone,
    String? email,
  }) async {
    userId ??= await getStoredUserId();
    if (userId == null || userId.isEmpty) {
      throw Exception('No stored user id. Cannot update profile.');
    }

    final body = <String, dynamic>{
      'name': ?name,
      'dateOfBirth': ?dateOfBirth,
      'phone': ?phone,
      'email': ?email,
    };

    final resp = await _client.putJson('api/users/$userId', body);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final data = json.decode(resp.body) as Map<String, dynamic>;
      await updateStoredUserPayload(data);
      return data;
    }
    throw Exception(_errorMessage(
        resp.body, 'Failed to update profile: ${resp.statusCode}'));
  }

  /// POST /api/users/{id}/avatar (multipart) — trả về user đã cập nhật.
  Future<Map<String, dynamic>> uploadAvatar({
    String? userId,
    required File avatarFile,
  }) async {
    userId ??= await getStoredUserId();
    if (userId == null || userId.isEmpty) {
      throw Exception('No stored user id. Cannot upload avatar.');
    }
    if (!await avatarFile.exists()) {
      throw Exception('Avatar file does not exist: ${avatarFile.path}');
    }

    final base = _client.baseUrl.endsWith('/')
        ? _client.baseUrl.substring(0, _client.baseUrl.length - 1)
        : _client.baseUrl;
    final req = http.MultipartRequest(
        'POST', Uri.parse('$base/api/users/$userId/avatar'));
    req.files.add(await http.MultipartFile.fromPath('avatar', avatarFile.path));
    await _client.attachAuthToMultipart(req);

    final resp = await http.Response.fromStream(await req.send());
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final data = json.decode(resp.body) as Map<String, dynamic>;
      await updateStoredUserPayload(data);
      return data;
    }
    throw Exception(_errorMessage(
        resp.body, 'Failed to upload avatar: ${resp.statusCode}'));
  }

  /// POST /api/users/{id}/change-password — đổi mật khẩu user hiện tại.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final userId = await getStoredUserId();
    if (userId == null || userId.isEmpty) {
      throw Exception('Not logged in');
    }
    final resp = await _client.postJson('api/users/$userId/change-password', {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
    if (resp.statusCode >= 200 && resp.statusCode < 300) return;
    throw Exception(
        _errorMessage(resp.body, 'Error ${resp.statusCode}'));
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Parse response 200 → lưu phiên → trả User; ngược lại ném AuthException.
  Future<User> _handleAuthResponse(
      http.Response resp, String fallbackMessage) async {
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body) as Map<String, dynamic>;
      final user = User.fromJson(data);
      if (user.token.isNotEmpty) {
        await _storage.write(key: _tokenKey, value: user.token);
      }
      // Lưu nguyên payload để nơi khác dùng userId, name, avatarUrl...
      await _storage.write(key: _userKey, value: json.encode(data));
      return user;
    }
    throw AuthException(_errorMessage(resp.body, fallbackMessage));
  }

  static String _errorMessage(String body, String fallback) {
    try {
      final parsed = json.decode(body);
      if (parsed is Map && parsed['message'] != null) {
        return parsed['message'].toString();
      }
      if (parsed is String && parsed.isNotEmpty) return parsed;
    } catch (_) {}
    return fallback;
  }
}
