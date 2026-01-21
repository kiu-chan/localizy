import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:localizy/api/main_api.dart';

class SubAccount {
  final String id;
  final String email;
  final String fullName;
  final String phone;
  final String location;
  final String role;
  final bool isActive;
  final String parentBusinessId;
  final String parentBusinessName;
  final String createdAt;

  SubAccount({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.location,
    required this.role,
    required this.isActive,
    required this.parentBusinessId,
    required this.parentBusinessName,
    required this.createdAt,
  });

  factory SubAccount.fromJson(Map<String, dynamic> json) {
    return SubAccount(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? json['full_name'] ?? '',
      phone: json['phone'] ?? '',
      location: json['location'] ?? '',
      role: json['role'] ?? '',
      isActive: json['isActive'] == null ? true : (json['isActive'] == true),
      parentBusinessId: json['parentBusinessId'] ?? '',
      parentBusinessName: json['parentBusinessName'] ?? '',
      createdAt: json['createdAt'] ?? json['createdDate'] ?? '',
    );
  }
}

class SubAccountApi {
  /// GET /api/users/my-sub-accounts
  /// Uses MainApi.instance.getJson so headers/auth are handled by MainApi.
  static Future<List<SubAccount>> getMySubAccounts() async {
    try {
      debugPrint('SubAccountApi: GET api/users/my-sub-accounts');
      final data = await MainApi.instance.getJson('api/users/my-sub-accounts');

      if (data is List) {
        return data
            .map((e) => SubAccount.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Unexpected response format: expected list');
      }
    } catch (e) {
      debugPrint('SubAccountApi.getMySubAccounts error: $e');
      rethrow;
    }
  }

  /// POST /api/users/sub-accounts
  /// Uses MainApi.instance.postJson so headers/auth are handled by MainApi.
  static Future<SubAccount> createSubAccount({
    required String email,
    required String fullName,
    required String password,
    String? phone,
    String? location,
  }) async {
    final body = <String, dynamic>{
      'email': email,
      'fullName': fullName,
      'password': password,
    };
    if (phone != null && phone.isNotEmpty) body['phone'] = phone;
    if (location != null && location.isNotEmpty) body['location'] = location;

    try {
      debugPrint('SubAccountApi: POST api/users/sub-accounts');
      debugPrint('Request body: $body');

      final resp = await MainApi.instance.postJson('api/users/sub-accounts', body);

      debugPrint('Status ${resp.statusCode}');
      debugPrint('Body ${resp.body}');

      if (resp.statusCode == 201 || resp.statusCode == 200) {
        final data = json.decode(resp.body);
        if (data is Map<String, dynamic>) {
          return SubAccount.fromJson(data);
        } else {
          throw Exception('Unexpected response format');
        }
      }

      String message = 'Failed to create sub account';
      try {
        final parsed = json.decode(resp.body);
        if (parsed is Map && parsed['message'] != null) {
          message = parsed['message'].toString();
        } else if (parsed is String && parsed.isNotEmpty) {
          message = parsed;
        }
      } catch (_) {}
      throw Exception('Error ${resp.statusCode}: $message');
    } catch (e) {
      debugPrint('SubAccountApi.createSubAccount error: $e');
      rethrow;
    }
  }
}