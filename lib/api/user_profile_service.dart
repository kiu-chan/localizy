import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:localizy/api/auth_api.dart';
import 'package:localizy/api/main_api.dart';

class UserProfileService {
  /// Fetch current user profile using stored userId.
  /// Returns parsed JSON Map with fields: id, name, email, phone, avatarUrl, role, dateOfBirth, etc.
  static Future<Map<String, dynamic>> fetchCurrentUserProfile() async {
    final userId = await AuthService.getStoredUserId();
    if (userId == null || userId.isEmpty) {
      throw Exception('No stored user id. User might not be logged in.');
    }
    final dynamic jsonResp = await MainApi.instance.getJson('api/users/$userId');
    if (jsonResp is Map<String, dynamic>) {
      return jsonResp;
    }
    throw Exception('Unexpected response from user profile API');
  }

  /// Update profile via JSON body. All fields optional.
  /// PUT /api/users/{id}
  /// Fields: name, dateOfBirth, phone, email
  static Future<Map<String, dynamic>> updateProfile({
    String? userId,
    String? name,
    String? dateOfBirth,
    String? phone,
    String? email,
  }) async {
    userId ??= await AuthService.getStoredUserId();
    if (userId == null || userId.isEmpty) {
      throw Exception('No stored user id. Cannot update profile.');
    }

    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (dateOfBirth != null) body['dateOfBirth'] = dateOfBirth;
    if (phone != null) body['phone'] = phone;
    if (email != null) body['email'] = email;

    final resp = await MainApi.instance.putJson('api/users/$userId', body);

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final Map<String, dynamic> data = json.decode(resp.body);
      try {
        await AuthService.updateStoredUserPayload(data);
      } catch (_) {}
      return data;
    } else {
      String message = 'Failed to update profile: ${resp.statusCode}';
      try {
        final body = json.decode(resp.body);
        if (body is Map && body['message'] != null) { message = body['message'].toString(); }
        else if (body is String && body.isNotEmpty) { message = body; }
      } catch (_) {}
      throw Exception(message);
    }
  }

  /// Upload avatar via multipart POST.
  /// POST /api/users/{id}/avatar
  /// Returns updated user object (with avatarUrl updated).
  static Future<Map<String, dynamic>> uploadAvatar({
    String? userId,
    required File avatarFile,
  }) async {
    userId ??= await AuthService.getStoredUserId();
    if (userId == null || userId.isEmpty) {
      throw Exception('No stored user id. Cannot upload avatar.');
    }

    final base = MainApi.instance.baseUrl.endsWith('/')
        ? MainApi.instance.baseUrl.substring(0, MainApi.instance.baseUrl.length - 1)
        : MainApi.instance.baseUrl;
    final uri = Uri.parse('$base/api/users/$userId/avatar');

    final req = http.MultipartRequest('POST', uri);

    if (!await avatarFile.exists()) {
      throw Exception('Avatar file does not exist: ${avatarFile.path}');
    }
    final multipartFile = await http.MultipartFile.fromPath('avatar', avatarFile.path);
    req.files.add(multipartFile);

    await MainApi.instance.attachAuthToMultipart(req);

    final streamed = await req.send();
    final resp = await http.Response.fromStream(streamed);

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final Map<String, dynamic> data = json.decode(resp.body);
      try {
        await AuthService.updateStoredUserPayload(data);
      } catch (_) {}
      return data;
    } else {
      String message = 'Failed to upload avatar: ${resp.statusCode}';
      try {
        final body = json.decode(resp.body);
        if (body is Map && body['message'] != null) { message = body['message'].toString(); }
        else if (body is String && body.isNotEmpty) { message = body; }
      } catch (_) {}
      throw Exception(message);
    }
  }
}
