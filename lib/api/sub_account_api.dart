import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:localizy/api/main_api.dart';

class SubAccount {
  final String id;
  final String email;
  final String fullName;
  final String phone;
  final String role;
  final bool isActive;
  final String parentBusinessId;
  final String createdAt;

  SubAccount({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.role,
    required this.isActive,
    required this.parentBusinessId,
    required this.createdAt,
  });

  factory SubAccount.fromJson(Map<String, dynamic> json) {
    return SubAccount(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      // API trả về field 'name'
      fullName: json['name'] ?? json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'SubAccount',
      isActive: json['isActive'] == null ? true : (json['isActive'] == true),
      parentBusinessId: json['parentBusinessId']?.toString() ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }

  SubAccount copyWith({
    String? fullName,
    String? email,
    String? phone,
  }) {
    return SubAccount(
      id: id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role,
      isActive: isActive,
      parentBusinessId: parentBusinessId,
      createdAt: createdAt,
    );
  }
}

class SubAccountApi {
  /// GET /api/business/sub-accounts
  /// Lấy danh sách tài khoản con thuộc Business hiện tại
  static Future<List<SubAccount>> getMySubAccounts() async {
    debugPrint('SubAccountApi: GET api/business/sub-accounts');
    final data = await MainApi.instance.getJson('api/business/sub-accounts');
    if (data is List) {
      return data
          .map((e) => SubAccount.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Unexpected response format: expected list');
  }

  /// POST /api/business/sub-accounts
  /// Tạo tài khoản con mới (role tự động = SubAccount)
  static Future<SubAccount> createSubAccount({
    required String email,
    required String fullName,
    required String password,
    String? phone,
  }) async {
    final body = <String, dynamic>{
      'name': fullName,
      'email': email,
      'password': password,
    };
    if (phone != null && phone.isNotEmpty) body['phone'] = phone;

    debugPrint('SubAccountApi: POST api/business/sub-accounts');
    final resp = await MainApi.instance.postJson('api/business/sub-accounts', body);

    if (resp.statusCode == 201 || resp.statusCode == 200) {
      final data = json.decode(resp.body);
      if (data is Map<String, dynamic>) return SubAccount.fromJson(data);
      throw Exception('Unexpected response format');
    }

    String message = 'Failed to create sub account';
    try {
      final parsed = json.decode(resp.body);
      if (parsed is Map && parsed['message'] != null) {
        message = parsed['message'].toString();
      }
    } catch (_) {}
    throw Exception('Error ${resp.statusCode}: $message');
  }

  /// PUT /api/business/sub-accounts/{id}
  /// Cập nhật thông tin tài khoản con (tất cả fields optional)
  static Future<SubAccount> updateSubAccount({
    required String id,
    String? name,
    String? email,
    String? phone,
  }) async {
    final body = <String, dynamic>{};
    if (name != null && name.isNotEmpty) body['name'] = name;
    if (email != null && email.isNotEmpty) body['email'] = email;
    if (phone != null) body['phone'] = phone;

    debugPrint('SubAccountApi: PUT api/business/sub-accounts/$id');
    final resp = await MainApi.instance.putJson('api/business/sub-accounts/$id', body);

    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      if (data is Map<String, dynamic>) return SubAccount.fromJson(data);
      throw Exception('Unexpected response format');
    }

    String message = 'Failed to update sub account';
    try {
      final parsed = json.decode(resp.body);
      if (parsed is Map && parsed['message'] != null) {
        message = parsed['message'].toString();
      }
    } catch (_) {}
    throw Exception('Error ${resp.statusCode}: $message');
  }
}
