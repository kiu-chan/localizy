import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:localizy/api/main_api.dart';

// ─── Business Dashboard ──────────────────────────────────────────────────────

class RecentActivity {
  final String type;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final String? actorName;

  RecentActivity({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    this.actorName,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      actorName: json['actorName'] as String?,
    );
  }
}

class BusinessDashboard {
  final int totalLocations;
  final int subAccountCount;
  final List<RecentActivity> recentActivities;

  BusinessDashboard({
    required this.totalLocations,
    required this.subAccountCount,
    required this.recentActivities,
  });

  factory BusinessDashboard.fromJson(Map<String, dynamic> json) {
    final rawActivities = json['recentActivities'];
    final activities = rawActivities is List
        ? rawActivities
            .map((e) => RecentActivity.fromJson(e as Map<String, dynamic>))
            .toList()
        : <RecentActivity>[];
    return BusinessDashboard(
      totalLocations: (json['totalLocations'] ?? 0) as int,
      subAccountCount: (json['subAccountCount'] ?? 0) as int,
      recentActivities: activities,
    );
  }
}

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

class BusinessApi {
  /// GET /api/business/dashboard
  /// Lấy tổng quan và hoạt động gần đây của nhóm doanh nghiệp
  static Future<BusinessDashboard> getDashboard() async {
    debugPrint('BusinessApi: GET api/business/dashboard');
    final data = await MainApi.instance.getJson('api/business/dashboard');
    if (data is Map<String, dynamic>) {
      return BusinessDashboard.fromJson(data);
    }
    throw Exception('Unexpected response format');
  }
}

class SubAccountApi {
  /// GET /api/business/sub-accounts
  /// Lấy danh sách tài khoản con thuộc Business hiện tại
  static Future<List<SubAccount>> getMySubAccounts() async {
    debugPrint('SubAccountApi: GET api/business/sub-accounts');
    final data = await MainApi.instance.getJson('api/business/sub-accounts');
    final items = (data is Map<String, dynamic> && data.containsKey('items'))
        ? data['items'] as List<dynamic>
        : data as List<dynamic>;
    return items
        .map((e) => SubAccount.fromJson(e as Map<String, dynamic>))
        .toList();
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
