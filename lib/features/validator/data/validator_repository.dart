import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localizy/core/network/api_client.dart';
import 'package:localizy/core/network/api_exception.dart';

import '../domain/validation_assignment.dart';

final validatorRepositoryProvider = Provider<ValidatorRepository>(
  (ref) => ValidatorRepository(ref.watch(apiClientProvider)),
);

/// Gọi các API dành cho role Validator (từ ValidatorApi cũ).
class ValidatorRepository {
  ValidatorRepository(this._client);

  final ApiClient _client;

  /// GET /api/dashboard/validator — thống kê + 10 task gần nhất.
  Future<ValidatorDashboard> getDashboard() async {
    final data = await _client.getJson('api/dashboard/validator');
    return ValidatorDashboard.fromJson(data as Map<String, dynamic>);
  }

  /// GET /api/validations/my-assignments — các yêu cầu xác minh được phân
  /// công cho validator hiện tại.
  Future<List<ValidationAssignment>> getMyAssignments() async {
    final data = await _client.getJson('api/validations/my-assignments');
    final items = (data is Map<String, dynamic> && data.containsKey('items'))
        ? data['items'] as List<dynamic>
        : data as List<dynamic>;
    return items
        .map((e) => ValidationAssignment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/validations/{id}/confirm-appointment — validator xác nhận sẽ
  /// đến xác minh theo lịch hẹn. Trả về assignment với status "Scheduled".
  Future<ValidationAssignment> confirmAppointment(String id) async {
    final resp = await _client.postJson(
      'api/validations/$id/confirm-appointment',
      {},
    );
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return ValidationAssignment.fromJson(
          json.decode(resp.body) as Map<String, dynamic>);
    }
    _throwFromResponse(resp, 'Confirm appointment failed');
  }

  /// POST /api/validations/{id}/verify — xác minh địa chỉ sau khi đến thực địa.
  Future<ValidationAssignment> verifyValidation(String id, String notes) async {
    final resp = await _client.postJson(
      'api/validations/$id/verify',
      {'notes': notes},
    );
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return ValidationAssignment.fromJson(
          json.decode(resp.body) as Map<String, dynamic>);
    }
    _throwFromResponse(resp, 'Verify validation failed');
  }

  /// POST /api/validations/{id}/reject — từ chối validation, [reason] bắt buộc.
  Future<void> rejectValidation(String id, String reason) async {
    final resp = await _client.postJson(
      'api/validations/$id/reject',
      {'reason': reason},
    );
    if (resp.statusCode == 200 || resp.statusCode == 201) return;
    _throwFromResponse(resp, 'Reject validation failed');
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
