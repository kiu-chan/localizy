import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:localizy/api/main_api.dart';
import 'package:path/path.dart' as path;

/// VerificationService: tách riêng việc gọi API gửi yêu cầu xác minh địa chỉ.
///
/// - Khi gửi JSON (không có file), dùng MainApi.instance.postJson(...) -> MainApi tự động thêm Authorization nếu có.
/// - Khi gửi multipart (có file), sử dụng MultipartRequest nhưng trước khi gửi gọi:
///     await MainApi.instance.attachAuthToMultipart(request);
///   để MainApi thêm Authorization (nếu token tồn tại).
class VerificationApi {
  static Future<Map<String, dynamic>> createVerificationRequest({
    String addressId = '',
    String requestType = 'NewAddress',
    String priority = 'Medium',
    required String idType,
    String? notes,
    required bool photosProvided,
    required bool documentsProvided,
    required int attachmentsCount,
    required double latitude,
    required double longitude,
    required String paymentMethod,
    required int paymentAmount,
    DateTime? appointmentDate,
    String? appointmentTimeSlot,
    List<File>? attachments,
  }) async {
    final base = MainApi.instance.baseUrl;
    final cleanedBase = base.endsWith('/') ? base : '$base/';
    final uri = Uri.parse('${cleanedBase}api/validations/verification-request');

    // If there are attachments, send multipart/form-data.
    if (attachments != null && attachments.isNotEmpty) {
      final request = http.MultipartRequest('POST', uri);

      // Populate fields
      request.fields['addressId'] = addressId;
      request.fields['requestType'] = requestType;
      request.fields['priority'] = priority;
      request.fields['idType'] = idType;
      if (notes != null) request.fields['notes'] = notes;
      request.fields['photosProvided'] = photosProvided.toString();
      request.fields['documentsProvided'] = documentsProvided.toString();
      request.fields['attachmentsCount'] = attachmentsCount.toString();
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();
      request.fields['paymentMethod'] = paymentMethod;
      request.fields['paymentAmount'] = paymentAmount.toString();
      if (appointmentDate != null) {
        request.fields['appointmentDate'] = appointmentDate.toUtc().toIso8601String();
      }
      if (appointmentTimeSlot != null) {
        request.fields['appointmentTimeSlot'] = appointmentTimeSlot;
      }

      // Use MainApi helper to attach Authorization header if token exists.
      await MainApi.instance.attachAuthToMultipart(request);

      // Attach files
      for (var i = 0; i < attachments.length; i++) {
        final file = attachments[i];
        final stream = http.ByteStream(file.openRead());
        final length = await file.length();
        final filename = path.basename(file.path);
        final multipartFile = http.MultipartFile(
          'attachments',
          stream,
          length,
          filename: filename,
        );
        request.files.add(multipartFile);
      }

      final streamedResp = await request.send();
      final resp = await http.Response.fromStream(streamedResp);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        return json.decode(resp.body) as Map<String, dynamic>;
      }

      // Try extract error message
      String message = 'Request failed: ${resp.statusCode}';
      try {
        final body = json.decode(resp.body);
        if (body is Map && body['message'] != null) {
          message = body['message'].toString();
        } else if (body is String && body.isNotEmpty) {
          message = body;
        }
      } catch (_) {}
      throw Exception(message);
    }

    // No attachments -> send JSON via MainApi so token (if any) is attached automatically.
    final body = {
      'addressId': addressId,
      'requestType': requestType,
      'priority': priority,
      'idType': idType,
      'notes': notes ?? '',
      'photosProvided': photosProvided,
      'documentsProvided': documentsProvided,
      'attachmentsCount': attachmentsCount,
      'latitude': latitude,
      'longitude': longitude,
      'paymentMethod': paymentMethod,
      'paymentAmount': paymentAmount,
      if (appointmentDate != null) 'appointmentDate': appointmentDate.toUtc().toIso8601String(),
      if (appointmentTimeSlot != null) 'appointmentTimeSlot': appointmentTimeSlot,
    };

    final resp = await MainApi.instance.postJson('api/validations/verification-request', body);

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }

    String message = 'Request failed: ${resp.statusCode}';
    try {
      final bodyResp = json.decode(resp.body);
      if (bodyResp is Map && bodyResp['message'] != null) {
        message = bodyResp['message'].toString();
      } else if (bodyResp is String && bodyResp.isNotEmpty) {
        message = bodyResp;
      }
    } catch (_) {}
    throw Exception(message);
  }
}