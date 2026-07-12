import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localizy/core/network/api_client.dart';

import '../domain/parking_ticket.dart';
import '../domain/parking_zone.dart';

final parkingRepositoryProvider = Provider<ParkingRepository>(
  (ref) => ParkingRepository(ref.watch(apiClientProvider)),
);

class ParkingRepository {
  ParkingRepository(this._client);

  final ApiClient _client;

  static List<dynamic> _items(dynamic data) =>
      (data is Map && data.containsKey('items'))
          ? data['items'] as List<dynamic>
          : data as List<dynamic>;

  /// POST /api/parking — tạo vé đậu xe mới.
  Future<ParkingTicket> createTicket({
    required String licensePlate,
    required String addressId,
    required String duration,
    required String paymentMethod,
  }) async {
    final resp = await _client.postJson('api/parking', {
      'licensePlate': licensePlate,
      'addressId': addressId,
      'duration': duration,
      'paymentMethod': paymentMethod,
    });

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return ParkingTicket.fromJson(
          json.decode(resp.body) as Map<String, dynamic>);
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

  /// GET /api/parking/ticket/{code} — tìm vé theo mã vé.
  Future<ParkingTicket> getByTicketCode(String code) async {
    final data = await _client
        .getJson('api/parking/ticket/${Uri.encodeComponent(code)}');
    return ParkingTicket.fromJson(data as Map<String, dynamic>);
  }

  /// GET /api/parking/license/{plate} — tìm vé theo biển số.
  Future<ParkingTicket> getByLicensePlate(String plate) async {
    final data = await _client
        .getJson('api/parking/license/${Uri.encodeComponent(plate)}');
    return ParkingTicket.fromJson(data as Map<String, dynamic>);
  }

  /// GET /api/addresses/parking-zones — danh sách bãi đậu xe.
  Future<List<ParkingZone>> getParkingZones() async {
    final data = await _client.getJson('api/addresses/parking-zones');
    return _items(data)
        .map((e) => ParkingZone.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Tên bãi cho [addressId]; trả về chính addressId nếu không tra được.
  Future<String> zoneNameFor(String addressId) async {
    try {
      final zones = await getParkingZones();
      final zone = zones.where((z) => z.id == addressId).firstOrNull;
      if (zone != null && zone.name.isNotEmpty) return zone.name;
    } catch (_) {}
    return addressId;
  }
}
