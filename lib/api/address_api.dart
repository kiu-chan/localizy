import 'dart:convert';
import 'package:localizy/api/main_api.dart';

class AddressApi {
  // Lấy danh sách địa chỉ có id và toạ độ từ endpoint mới
  static Future<List<AddressCoordinate>> fetchCoordinates() async {
    final resp = await MainApi.instance.get('/api/Addresses/coordinates',
      headers: {'accept': 'text/plain'},
    );
    if (resp.statusCode == 200) {
      final raw = json.decode(resp.body);
      if (raw is List) {
        return raw.map((json) => AddressCoordinate.fromJson(json)).toList();
      }
    }
    throw Exception('Failed to fetch address coordinates: ${resp.statusCode}');
  }
}

/// Model đơn giản hoá chỉ chứa id và coordinates
class AddressCoordinate {
  final String id;
  final double lat;
  final double lng;
  AddressCoordinate({
    required this.id,
    required this.lat,
    required this.lng,
  });

  factory AddressCoordinate.fromJson(Map<String, dynamic> json) {
    final coords = json['coordinates'] ?? {};
    return AddressCoordinate(
      id: json['id'] ?? '',
      lat: (coords['lat'] ?? 0).toDouble(),
      lng: (coords['lng'] ?? 0).toDouble(),
    );
  }
}