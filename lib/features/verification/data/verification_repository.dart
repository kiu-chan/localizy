import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:localizy/core/network/api_client.dart';
import 'package:path/path.dart' as path;

final verificationRepositoryProvider = Provider<VerificationRepository>(
  (ref) => VerificationRepository(ref.watch(apiClientProvider)),
);

class VerificationRepository {
  VerificationRepository(this._client);

  final ApiClient _client;

  /// POST /api/validations/verification-request (multipart) —
  /// gửi yêu cầu xác minh địa chỉ kèm giấy tờ.
  Future<Map<String, dynamic>> createVerificationRequest({
    String? addressId,
    String requestType = 'NewAddress',
    String priority = 'Medium',
    required String idType,
    required bool photosProvided,
    required bool documentsProvided,
    required int attachmentsCount,
    required double latitude,
    required double longitude,
    String? locationName,
    String? fullAddress,
    String? cityId,
    required String paymentMethod,
    required int paymentAmount,
    DateTime? appointmentDate,
    String? appointmentTimeSlot,
    File? idDocument,
    File? addressProof,
  }) async {
    final base = _client.baseUrl;
    final cleanedBase = base.endsWith('/') ? base : '$base/';
    final uri =
        Uri.parse('${cleanedBase}api/validations/verification-request');

    final request = http.MultipartRequest('POST', uri);

    request.fields['requestType'] = requestType;
    request.fields['priority'] = priority;
    request.fields['idType'] = idType;
    request.fields['photosProvided'] = photosProvided.toString();
    request.fields['documentsProvided'] = documentsProvided.toString();
    request.fields['attachmentsCount'] = attachmentsCount.toString();
    request.fields['latitude'] = latitude.toString();
    request.fields['longitude'] = longitude.toString();
    if (locationName != null && locationName.isNotEmpty) {
      request.fields['locationName'] = locationName;
    }
    if (fullAddress != null && fullAddress.isNotEmpty) {
      request.fields['fullAddress'] = fullAddress;
    }
    if (cityId != null && cityId.isNotEmpty) {
      request.fields['cityId'] = cityId;
    }
    request.fields['paymentMethod'] = paymentMethod;
    request.fields['paymentAmount'] = paymentAmount.toString();

    if (addressId != null && addressId.isNotEmpty) {
      request.fields['addressId'] = addressId;
    }
    if (appointmentDate != null) {
      request.fields['appointmentDate'] =
          appointmentDate.toUtc().toIso8601String();
    }
    if (appointmentTimeSlot != null) {
      request.fields['appointmentTimeSlot'] = appointmentTimeSlot;
    }

    await _client.attachAuthToMultipart(request);

    if (idDocument != null) {
      request.files.add(await _multipartFile('idDocument', idDocument));
    }
    if (addressProof != null) {
      request.files.add(await _multipartFile('addressProof', addressProof));
    }

    final resp = await http.Response.fromStream(await request.send());

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }

    String message = 'Request failed: ${resp.statusCode}';
    try {
      final body = json.decode(resp.body);
      if (body is Map && body['message'] != null) {
        message = body['message'].toString();
      }
    } catch (_) {}
    throw Exception(message);
  }

  static Future<http.MultipartFile> _multipartFile(
      String field, File file) async {
    return http.MultipartFile(
      field,
      http.ByteStream(file.openRead()),
      await file.length(),
      filename: path.basename(file.path),
    );
  }
}
