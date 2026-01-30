import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:localizy/api/auth_api.dart';
import 'package:localizy/api/main_api.dart';

class UserProfileService {
  /// Fetch current user profile using stored userId.
  /// Returns parsed JSON Map.
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

  /// Update profile (multipart/form-data). All fields optional.
  /// avatar: File (dart:io) - include only on mobile/native platforms.
  /// Returns updated user object (parsed Map).
  static Future<Map<String, dynamic>> updateProfile({
    String? userId,
    String? fullName,
    String? email,
    String? phone,
    String? location,
    bool? isActive,
    String? role,
    File? avatar,
  }) async {
    userId ??= await AuthService.getStoredUserId();
    if (userId == null || userId.isEmpty) {
      throw Exception('No stored user id. Cannot update profile.');
    }

    // Build URL correctly (avoid double slash)
    final base = MainApi.instance.baseUrl.endsWith('/')
        ? MainApi.instance.baseUrl.substring(0, MainApi.instance.baseUrl.length - 1)
        : MainApi.instance.baseUrl;
    final uri = Uri.parse('$base/api/users/$userId');

    final req = http.MultipartRequest('PUT', uri);

    if (fullName != null) req.fields['fullName'] = fullName;
    if (email != null) req.fields['email'] = email;
    if (phone != null) req.fields['phone'] = phone;
    if (location != null) req.fields['location'] = location;
    if (isActive != null) req.fields['isActive'] = isActive.toString();
    if (role != null) req.fields['role'] = role;

    if (avatar != null) {
      // From path (mobile). Ensure file exists.
      if (await avatar.exists()) {
        final multipartFile = await http.MultipartFile.fromPath('avatar', avatar.path);
        req.files.add(multipartFile);
      } else {
        throw Exception('Avatar file does not exist: ${avatar.path}');
      }
    }

    // Attach Authorization header
    await MainApi.instance.attachAuthToMultipart(req);

    final streamed = await req.send();
    final resp = await http.Response.fromStream(streamed);

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final Map<String, dynamic> data = json.decode(resp.body);
      // Optionally update stored user payload if API returns useful fields (e.g. token/name)
      try {
        await AuthService.updateStoredUserPayload(data);
      } catch (_) {}
      return data;
    } else {
      String message = 'Failed to update profile: ${resp.statusCode}';
      try {
        final body = json.decode(resp.body);
        if (body is Map && body['message'] != null) message = body['message'].toString();
        else if (body is String && body.isNotEmpty) message = body;
      } catch (_) {}
      throw Exception(message);
    }
  }
}