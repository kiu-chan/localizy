import 'dart:convert';
import 'package:localizy/api/main_api.dart';

class ParkingTicket {
  final String id;
  final String ticketCode;
  final String licensePlate;
  final String parkingZone;
  final String duration;
  final int amount;
  final String status;
  final String paymentMethod;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime? paidAt;

  ParkingTicket({
    required this.id,
    required this.ticketCode,
    required this.licensePlate,
    required this.parkingZone,
    required this.duration,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    required this.startTime,
    required this.endTime,
    this.paidAt,
  });

  factory ParkingTicket.fromJson(Map<String, dynamic> json) {
    return ParkingTicket(
      id: json['id']?.toString() ?? '',
      ticketCode: json['ticketCode'] ?? '',
      licensePlate: json['licensePlate'] ?? '',
      parkingZone: json['parkingZone'] ?? '',
      duration: json['duration']?.toString() ?? '',
      amount: (json['amount'] ?? 0).toInt(),
      status: (json['status'] as String? ?? '').toLowerCase(),
      paymentMethod: json['paymentMethod'] ?? '',
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'])
          : DateTime.now(),
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
    );
  }

  /// Trạng thái để hiển thị UI: success / failed / pending / active
  String get uiStatus {
    switch (status) {
      case 'cancelled':
        return 'failed';
      case 'active':
        return 'success';
      case 'expired':
        return 'success';
      default:
        return status;
    }
  }
}

class ParkingApi {
  /// POST /api/parking
  /// Tạo vé đậu xe mới
  static Future<ParkingTicket> createTicket({
    required String licensePlate,
    required String parkingZone,
    required String duration,
    required String paymentMethod,
  }) async {
    final resp = await MainApi.instance.postJson('api/parking', {
      'licensePlate': licensePlate,
      'parkingZone': parkingZone,
      'duration': duration,
      'paymentMethod': paymentMethod,
    });

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      final data = json.decode(resp.body);
      return ParkingTicket.fromJson(data as Map<String, dynamic>);
    }

    String message = 'Failed to create parking ticket';
    try {
      final parsed = json.decode(resp.body);
      if (parsed is Map && parsed['message'] != null) {
        message = parsed['message'].toString();
      }
    } catch (_) {}
    throw Exception(message);
  }

  /// GET /api/parking/ticket/{code}
  /// Tìm vé theo mã vé
  static Future<ParkingTicket> getByTicketCode(String code) async {
    final encoded = Uri.encodeComponent(code);
    final data = await MainApi.instance.getJson('api/parking/ticket/$encoded');
    return ParkingTicket.fromJson(data as Map<String, dynamic>);
  }

  /// GET /api/parking/license/{plate}
  /// Tìm vé theo biển số xe
  static Future<ParkingTicket> getByLicensePlate(String plate) async {
    final encoded = Uri.encodeComponent(plate);
    final data = await MainApi.instance.getJson('api/parking/license/$encoded');
    return ParkingTicket.fromJson(data as Map<String, dynamic>);
  }

  /// GET /api/parking/my-tickets
  /// Lấy danh sách vé của người dùng hiện tại
  static Future<List<ParkingTicket>> getMyTickets() async {
    final data = await MainApi.instance.getJson('api/parking/my-tickets');
    if (data is List) {
      return data
          .map((e) => ParkingTicket.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Unexpected response format: expected list');
  }
}
