import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:localizy/api/main_api.dart';
import 'package:path/path.dart' as path;

class VerificationApi {
  static Future<Map<String, dynamic>> createVerificationRequest({
    String? addressId,
    String requestType = 'NewAddress',
    String priority = 'Medium',
    required String idType,
    required bool photosProvided,
    required bool documentsProvided,
    required int attachmentsCount,
    required double latitude,
    required double longitude,
    required String paymentMethod,
    required int paymentAmount,
    DateTime? appointmentDate,
    String? appointmentTimeSlot,
    File? idDocument,
    File? addressProof,
  }) async {
    final base = MainApi.instance.baseUrl;
    final cleanedBase = base.endsWith('/') ? base : '$base/';
    final uri = Uri.parse('${cleanedBase}api/validations/verification-request');

    final request = http.MultipartRequest('POST', uri);

    request.fields['requestType'] = requestType;
    request.fields['priority'] = priority;
    request.fields['idType'] = idType;
    request.fields['photosProvided'] = photosProvided.toString();
    request.fields['documentsProvided'] = documentsProvided.toString();
    request.fields['attachmentsCount'] = attachmentsCount.toString();
    request.fields['latitude'] = latitude.toString();
    request.fields['longitude'] = longitude.toString();
    request.fields['paymentMethod'] = paymentMethod;
    request.fields['paymentAmount'] = paymentAmount.toString();

    if (addressId != null && addressId.isNotEmpty) {
      request.fields['addressId'] = addressId;
    }
    if (appointmentDate != null) {
      request.fields['appointmentDate'] = appointmentDate.toUtc().toIso8601String();
    }
    if (appointmentTimeSlot != null) {
      request.fields['appointmentTimeSlot'] = appointmentTimeSlot;
    }

    await MainApi.instance.attachAuthToMultipart(request);

    if (idDocument != null) {
      final stream = http.ByteStream(idDocument.openRead());
      final length = await idDocument.length();
      final filename = path.basename(idDocument.path);
      final multipartFile = http.MultipartFile(
        'idDocument',
        stream,
        length,
        filename: filename,
      );
      request.files.add(multipartFile);
    }

    if (addressProof != null) {
      final stream = http.ByteStream(addressProof.openRead());
      final length = await addressProof.length();
      final filename = path.basename(addressProof.path);
      final multipartFile = http.MultipartFile(
        'addressProof',
        stream,
        length,
        filename: filename,
      );
      request.files.add(multipartFile);
    }

    debugPrint('===== VERIFICATION REQUEST DEBUG =====');
    debugPrint('Request fields: ${request.fields}');
    debugPrint('Files count: ${request.files.length}');

    final streamedResp = await request.send();
    final resp = await http.Response.fromStream(streamedResp);

    debugPrint('Response status: ${resp.statusCode}');
    debugPrint('Response body: ${resp.body}');
    debugPrint('===== END DEBUG =====');

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
}