import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:localizy/api/main_api.dart';

class ValidationAddress {
  final String id;
  final String code;
  final String cityCode;
  final double? lat;
  final double? lng;

  ValidationAddress({
    required this.id,
    required this.code,
    required this.cityCode,
    this.lat,
    this.lng,
  });

  factory ValidationAddress.fromJson(Map<String, dynamic> json) {
    final coords = json['coordinates'] as Map<String, dynamic>?;
    return ValidationAddress(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      cityCode: json['cityCode']?.toString() ?? '',
      lat: coords?['lat']?.toDouble(),
      lng: coords?['lng']?.toDouble(),
    );
  }
}

class ValidationUser {
  final String userId;
  final String name;
  final String? email;

  ValidationUser({required this.userId, required this.name, this.email});

  factory ValidationUser.fromJson(Map<String, dynamic> json) {
    return ValidationUser(
      userId: json['userId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
    );
  }
}

class ValidationChanges {
  final String? oldData;
  final String? newData;

  ValidationChanges({this.oldData, this.newData});

  factory ValidationChanges.fromJson(Map<String, dynamic> json) {
    return ValidationChanges(
      oldData: json['oldData']?.toString(),
      newData: json['newData']?.toString(),
    );
  }
}

class ValidationVerificationData {
  final bool photosProvided;
  final bool documentsProvided;
  final bool locationVerified;
  final String? idDocumentUrl;
  final String? addressProofUrl;

  ValidationVerificationData({
    required this.photosProvided,
    required this.documentsProvided,
    required this.locationVerified,
    this.idDocumentUrl,
    this.addressProofUrl,
  });

  factory ValidationVerificationData.fromJson(Map<String, dynamic> json) {
    return ValidationVerificationData(
      photosProvided: json['photosProvided'] == true,
      documentsProvided: json['documentsProvided'] == true,
      locationVerified: json['locationVerified'] == true,
      idDocumentUrl: json['idDocumentUrl']?.toString(),
      addressProofUrl: json['addressProofUrl']?.toString(),
    );
  }
}

class ValidationAssignment {
  final String id;
  final String requestId;
  final String status;
  final String priority;
  final String requestType;
  final ValidationAddress? address;
  final ValidationUser? submittedBy;
  final DateTime? submittedDate;
  final String? notes;
  final ValidationChanges? changes;
  final ValidationVerificationData? verificationData;
  final int attachmentsCount;
  final ValidationUser? assignedValidator;
  final DateTime? assignedDate;
  final ValidationUser? processedBy;
  final DateTime? processedDate;
  final String? processingNotes;
  final String? rejectionReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ValidationAssignment({
    required this.id,
    required this.requestId,
    required this.status,
    required this.priority,
    required this.requestType,
    this.address,
    this.submittedBy,
    this.submittedDate,
    this.notes,
    this.changes,
    this.verificationData,
    this.attachmentsCount = 0,
    this.assignedValidator,
    this.assignedDate,
    this.processedBy,
    this.processedDate,
    this.processingNotes,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
  });

  factory ValidationAssignment.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    final addressJson = json['address'] as Map<String, dynamic>?;
    final submittedByJson = json['submittedBy'] as Map<String, dynamic>?;
    final assignedValidatorJson = json['assignedValidator'] as Map<String, dynamic>?;
    final processedByJson = json['processedBy'] as Map<String, dynamic>?;
    final changesJson = json['changes'] as Map<String, dynamic>?;
    final verificationDataJson = json['verificationData'] as Map<String, dynamic>?;

    return ValidationAssignment(
      id: json['id']?.toString() ?? '',
      requestId: json['requestId']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
      requestType: json['requestType']?.toString() ?? '',
      address: addressJson != null ? ValidationAddress.fromJson(addressJson) : null,
      submittedBy: submittedByJson != null ? ValidationUser.fromJson(submittedByJson) : null,
      submittedDate: parseDate(json['submittedDate']),
      notes: json['notes']?.toString(),
      changes: changesJson != null ? ValidationChanges.fromJson(changesJson) : null,
      verificationData: verificationDataJson != null
          ? ValidationVerificationData.fromJson(verificationDataJson)
          : null,
      attachmentsCount: (json['attachmentsCount'] ?? 0) as int,
      assignedValidator: assignedValidatorJson != null
          ? ValidationUser.fromJson(assignedValidatorJson)
          : null,
      assignedDate: parseDate(json['assignedDate']),
      processedBy: processedByJson != null ? ValidationUser.fromJson(processedByJson) : null,
      processedDate: parseDate(json['processedDate']),
      processingNotes: json['processingNotes']?.toString(),
      rejectionReason: json['rejectionReason']?.toString(),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  /// Ngày hiển thị trên lịch: ưu tiên assignedDate, fallback về submittedDate
  DateTime? get calendarDate => assignedDate ?? submittedDate;

  bool get isAssigned => status == 'Assigned';
  bool get isScheduled => status == 'Scheduled';
}

class ValidatorTaskStats {
  final int totalAssigned;
  final int assignedCount;
  final int scheduledCount;
  final int verifiedCount;
  final int rejectedCount;
  final int todayAppointments;

  ValidatorTaskStats({
    required this.totalAssigned,
    required this.assignedCount,
    required this.scheduledCount,
    required this.verifiedCount,
    required this.rejectedCount,
    required this.todayAppointments,
  });

  factory ValidatorTaskStats.fromJson(Map<String, dynamic> json) {
    return ValidatorTaskStats(
      totalAssigned: (json['totalAssigned'] ?? 0) as int,
      assignedCount: (json['assignedCount'] ?? 0) as int,
      scheduledCount: (json['scheduledCount'] ?? 0) as int,
      verifiedCount: (json['verifiedCount'] ?? 0) as int,
      rejectedCount: (json['rejectedCount'] ?? 0) as int,
      todayAppointments: (json['todayAppointments'] ?? 0) as int,
    );
  }
}

class ValidatorDashboard {
  final ValidatorTaskStats taskStats;
  final List<ValidationAssignment> recentAssignments;

  ValidatorDashboard({
    required this.taskStats,
    required this.recentAssignments,
  });

  factory ValidatorDashboard.fromJson(Map<String, dynamic> json) {
    final statsJson = json['taskStats'] as Map<String, dynamic>? ?? {};
    final recentJson = json['recentAssignments'] as List? ?? [];
    return ValidatorDashboard(
      taskStats: ValidatorTaskStats.fromJson(statsJson),
      recentAssignments: recentJson
          .map((e) => ValidationAssignment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ValidatorApi {
  /// GET /api/dashboard/validator
  /// Lấy dữ liệu tổng quan cho Validator: thống kê + 10 task gần nhất
  static Future<ValidatorDashboard> getValidatorDashboard() async {
    final data = await MainApi.instance.getJson('api/dashboard/validator');
    debugPrint('[ValidatorApi] getValidatorDashboard: $data');
    return ValidatorDashboard.fromJson(data as Map<String, dynamic>);
  }

  /// GET /api/validations/my-assignments
  /// Lấy danh sách các yêu cầu xác minh được phân công cho validator hiện tại
  static Future<List<ValidationAssignment>> getMyAssignments() async {
    final data = await MainApi.instance.getJson('api/validations/my-assignments');
    debugPrint('[ValidatorApi] getMyAssignments: $data');
    final items = (data is Map<String, dynamic> && data.containsKey('items'))
        ? data['items'] as List<dynamic>
        : data as List<dynamic>;
    return items
        .map((e) => ValidationAssignment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/validations/{id}/verify
  /// Validator xác minh địa chỉ sau khi đến thực địa
  /// [notes] - ghi chú xác minh
  static Future<ValidationAssignment> verifyValidation(String id, String notes) async {
    final resp = await MainApi.instance.postJson(
      'api/validations/$id/verify',
      {'notes': notes},
    );
    debugPrint('[ValidatorApi] verifyValidation $id: ${resp.statusCode} ${resp.body}');
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return ValidationAssignment.fromJson(
          json.decode(resp.body) as Map<String, dynamic>);
    }
    _throwFromResponse(resp, 'Verify validation failed');
  }

  /// POST /api/validations/{id}/reject
  /// Validator từ chối validation
  /// [reason] - lý do từ chối (bắt buộc)
  static Future<void> rejectValidation(String id, String reason) async {
    final resp = await MainApi.instance.postJson(
      'api/validations/$id/reject',
      {'reason': reason},
    );
    debugPrint('[ValidatorApi] rejectValidation $id: ${resp.statusCode} ${resp.body}');
    if (resp.statusCode == 200 || resp.statusCode == 201) return;
    _throwFromResponse(resp, 'Reject validation failed');
  }

  /// POST /api/addresses/{id}/review
  /// Đánh dấu địa chỉ là đã xác minh (Reviewed)
  /// [comments] - nhận xét sau xác minh thực địa
  static Future<void> reviewAddress(String addressId, String comments) async {
    final resp = await MainApi.instance.postJson(
      'api/addresses/$addressId/review',
      {'comments': comments},
    );
    debugPrint('[ValidatorApi] reviewAddress $addressId: ${resp.statusCode} ${resp.body}');
    if (resp.statusCode >= 200 && resp.statusCode < 300) return;
    _throwFromResponse(resp, 'Review address failed');
  }

  /// POST /api/addresses/{id}/reject
  /// Từ chối địa chỉ
  /// [comments] - lý do từ chối
  static Future<void> rejectAddress(String addressId, String comments) async {
    final resp = await MainApi.instance.postJson(
      'api/addresses/$addressId/reject',
      {'comments': comments},
    );
    debugPrint('[ValidatorApi] rejectAddress $addressId: ${resp.statusCode} ${resp.body}');
    if (resp.statusCode >= 200 && resp.statusCode < 300) return;
    _throwFromResponse(resp, 'Reject address failed');
  }

  static Never _throwFromResponse(dynamic resp, String fallback) {
    String message = '$fallback: ${resp.statusCode}';
    try {
      final body = json.decode(resp.body as String);
      if (body is Map && body['message'] != null) {
        message = body['message'].toString();
      }
    } catch (_) {}
    throw Exception(message);
  }

  /// POST /api/validations/{id}/confirm-appointment
  /// Validator xác nhận sẽ đến xác minh theo lịch hẹn đã đặt
  /// Trả về Validation object với status: "Scheduled"
  static Future<ValidationAssignment> confirmAppointment(String id) async {
    final resp = await MainApi.instance.postJson(
      'api/validations/$id/confirm-appointment',
      {},
    );
    debugPrint('[ValidatorApi] confirmAppointment $id: ${resp.statusCode} ${resp.body}');
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      final body = json.decode(resp.body);
      return ValidationAssignment.fromJson(body as Map<String, dynamic>);
    }

    String message = 'Confirm appointment failed: ${resp.statusCode}';
    try {
      final body = json.decode(resp.body);
      if (body is Map && body['message'] != null) {
        message = body['message'].toString();
      }
    } catch (_) {}
    throw Exception(message);
  }
}
