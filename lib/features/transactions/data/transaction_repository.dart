import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localizy/core/network/api_client.dart';

import '../domain/history_entry.dart';
import '../domain/validation_entry.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepository(ref.watch(apiClientProvider)),
);

class TransactionRepository {
  TransactionRepository(this._client);

  final ApiClient _client;

  static List<dynamic> _items(dynamic data) =>
      (data is Map && data.containsKey('items'))
          ? data['items'] as List<dynamic>
          : data as List<dynamic>;

  /// GET /api/transactions/my-transactions — mọi giao dịch của user,
  /// join với parking zones để có tên zone và tọa độ.
  Future<List<HistoryEntry>> getAllHistory() async {
    final results = await Future.wait([
      _client.getJson('api/transactions/my-transactions'),
      _client.getJson('api/addresses/parking-zones'),
    ]);
    final zones = _parseZones(results[1]);

    return _items(results[0]).map((e) {
      final json = e as Map<String, dynamic>;
      final typeRaw = json['type']?.toString() ?? '';
      final rawLocation = json['location']?.toString() ?? '';

      // Giao dịch parking lưu zone ID trong trường location
      final zone = typeRaw == 'parking' ? zones[rawLocation] : null;

      double? lat = zone?.latitude;
      double? lng = zone?.longitude;
      // Giao dịch verification lưu tọa độ dạng chuỗi "Lat: X, Lng: Y"
      if (lat == null && typeRaw == 'verification') {
        final match = RegExp(r'Lat:\s*([\d.]+),\s*Lng:\s*([\d.]+)')
            .firstMatch(rawLocation);
        if (match != null) {
          lat = double.tryParse(match.group(1)!);
          lng = double.tryParse(match.group(2)!);
        }
      }

      return HistoryEntry(
        id: json['id']?.toString() ?? '',
        type: HistoryType.from(typeRaw),
        title: json['title']?.toString() ?? '',
        location: zone != null ? '${zone.code} - ${zone.name}' : rawLocation,
        amount: ((json['amount'] ?? 0) as num).toInt(),
        status: (json['status'] as String? ?? '').toLowerCase(),
        paymentMethod: json['paymentMethod']?.toString() ?? '',
        date: json['date'] != null
            ? DateTime.parse(json['date'] as String)
            : DateTime.now(),
        licensePlate: json['licensePlate'] as String?,
        duration: json['duration'] as String?,
        latitude: lat,
        longitude: lng,
        zoneId: zone?.id,
        zoneCode: zone?.code,
        zoneName: zone?.name,
        availableSpots: zone?.availableSpots ?? 0,
        totalSpots: zone?.totalSpots ?? 0,
        pricePerHour: zone?.pricePerHour ?? 0,
      );
    }).toList();
  }

  /// GET /api/parking/my-tickets — vé đậu xe của user, join với zones.
  Future<List<HistoryEntry>> getParkingHistory() async {
    final results = await Future.wait([
      _client.getJson('api/parking/my-tickets'),
      _client.getJson('api/addresses/parking-zones'),
    ]);
    final zones = _parseZones(results[1]);

    return _items(results[0]).map((e) {
      final json = e as Map<String, dynamic>;
      final addressId = json['addressId']?.toString() ?? '';
      final zone = zones[addressId];
      final ticketCode = json['ticketCode']?.toString() ?? '';
      final id = json['id']?.toString() ?? '';

      return HistoryEntry(
        id: ticketCode.isNotEmpty ? ticketCode : id,
        type: HistoryType.parking,
        title: 'Parking Payment',
        location: zone != null ? '${zone.code} - ${zone.name}' : addressId,
        amount: ((json['amount'] ?? 0) as num).toInt(),
        status: _ticketUiStatus((json['status'] as String? ?? '').toLowerCase()),
        paymentMethod: json['paymentMethod']?.toString() ?? '',
        date: json['startTime'] != null
            ? DateTime.parse(json['startTime'] as String)
            : DateTime.now(),
        licensePlate: json['licensePlate']?.toString() ?? '',
        duration: json['duration']?.toString() ?? '',
        latitude: zone?.latitude,
        longitude: zone?.longitude,
        zoneId: zone?.id ?? addressId,
        zoneCode: zone?.code ?? '',
        zoneName: zone?.name ?? '',
        availableSpots: zone?.availableSpots ?? 0,
        totalSpots: zone?.totalSpots ?? 0,
        pricePerHour: zone?.pricePerHour ?? 0,
      );
    }).toList();
  }

  /// GET /api/validations/my-validations — yêu cầu xác minh địa chỉ của user.
  Future<List<ValidationEntry>> getValidationHistory() async {
    final data = await _client.getJson('api/validations/my-validations');
    return _items(data)
        .map((e) => ValidationEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Trạng thái vé → trạng thái hiển thị UI (success / failed / pending).
  static String _ticketUiStatus(String status) => switch (status) {
        'cancelled' => 'failed',
        'active' || 'expired' => 'success',
        _ => status,
      };

  static Map<String, _ParkingZone> _parseZones(dynamic data) => {
        for (final z in _items(data)
            .map((e) => _ParkingZone.fromJson(e as Map<String, dynamic>)))
          z.id: z,
      };
}

/// Thông tin zone tối thiểu cần cho lịch sử giao dịch. Bản đầy đủ
/// (ParkingZoneItem) sẽ về features/map khi migrate feature đó.
class _ParkingZone {
  _ParkingZone.fromJson(Map<String, dynamic> json)
      : id = json['id']?.toString() ?? '',
        code = json['code']?.toString() ?? '',
        name = (json['name'] ?? json['fullAddress'] ?? '').toString(),
        latitude = ((json['latitude'] ?? 0.0) as num).toDouble(),
        longitude = ((json['longitude'] ?? 0.0) as num).toDouble(),
        availableSpots = ((json['availableSpots'] ?? 0) as num).toInt(),
        totalSpots = ((json['totalParkingSpots'] ?? 0) as num).toInt(),
        pricePerHour = ((json['pricePerHour'] ?? 0) as num).toInt();

  final String id;
  final String code;
  final String name;
  final double latitude;
  final double longitude;
  final int availableSpots;
  final int totalSpots;
  final int pricePerHour;
}
