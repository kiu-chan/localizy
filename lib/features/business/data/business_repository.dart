import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localizy/core/network/api_client.dart';
import 'package:localizy/core/network/api_exception.dart';

import '../domain/business_dashboard.dart';
import '../domain/sub_account.dart';

final businessRepositoryProvider = Provider<BusinessRepository>(
  (ref) => BusinessRepository(ref.watch(apiClientProvider)),
);

/// Gọi các API dành cho role Business (gom BusinessApi + SubAccountApi cũ).
class BusinessRepository {
  BusinessRepository(this._client);

  final ApiClient _client;

  /// GET /api/business/dashboard — tổng quan và hoạt động gần đây.
  Future<BusinessDashboard> getDashboard() async {
    final data = await _client.getJson('api/business/dashboard');
    if (data is Map<String, dynamic>) {
      return BusinessDashboard.fromJson(data);
    }
    throw ApiException('Unexpected response format');
  }

  /// GET /api/business/sub-accounts — danh sách tài khoản con.
  Future<List<SubAccount>> getMySubAccounts() async {
    final data = await _client.getJson('api/business/sub-accounts');
    final items = (data is Map<String, dynamic> && data.containsKey('items'))
        ? data['items'] as List<dynamic>
        : data as List<dynamic>;
    return items
        .map((e) => SubAccount.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/business/sub-accounts — tạo tài khoản con (role = SubAccount).
  Future<SubAccount> createSubAccount({
    required String email,
    required String fullName,
    required String password,
    String? phone,
  }) async {
    final body = <String, dynamic>{
      'name': fullName,
      'email': email,
      'password': password,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    };

    final resp = await _client.postJson('api/business/sub-accounts', body);
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      final data = json.decode(resp.body);
      if (data is Map<String, dynamic>) return SubAccount.fromJson(data);
      throw ApiException('Unexpected response format');
    }
    _throwFromResponse(resp, 'Failed to create sub account');
  }

  /// PUT /api/business/sub-accounts/{id} — cập nhật tài khoản con.
  Future<SubAccount> updateSubAccount({
    required String id,
    String? name,
    String? email,
    String? phone,
  }) async {
    final body = <String, dynamic>{
      if (name != null && name.isNotEmpty) 'name': name,
      if (email != null && email.isNotEmpty) 'email': email,
      'phone': ?phone,
    };

    final resp =
        await _client.putJson('api/business/sub-accounts/$id', body);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      if (data is Map<String, dynamic>) return SubAccount.fromJson(data);
      throw ApiException('Unexpected response format');
    }
    _throwFromResponse(resp, 'Failed to update sub account');
  }

  /// Ném ApiException với message từ server nếu có.
  Never _throwFromResponse(dynamic resp, String fallback) {
    String message = '$fallback: ${resp.statusCode}';
    try {
      final body = json.decode(resp.body as String);
      if (body is Map && body['message'] != null) {
        message = body['message'].toString();
      }
    } catch (_) {}
    throw ApiException(message,
        statusCode: resp.statusCode as int?, body: resp.body as String?);
  }
}
