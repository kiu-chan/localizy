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

  // Tìm kiếm địa chỉ theo từ khóa
  static Future<List<AddressSearchResult>> search(String searchTerm) async {
    if (searchTerm.trim().isEmpty) {
      return [];
    }
    
    final encodedSearchTerm = Uri.encodeComponent(searchTerm);
    final resp = await MainApi.instance.get(
      '/api/Addresses/search?searchTerm=$encodedSearchTerm',
      headers: {'accept': 'text/plain'},
    );
    
    if (resp.statusCode == 200) {
      final raw = json.decode(resp.body);
      if (raw is List) {
        return raw.map((json) => AddressSearchResult.fromJson(json)).toList();
      }
    }
    throw Exception('Failed to search addresses: ${resp.statusCode}');
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

/// Model cho kết quả tìm kiếm địa chỉ
class AddressSearchResult {
  final String id;
  final String name;
  final String address;
  final String type;
  final double lat;
  final double lng;

  AddressSearchResult({
    required this.id,
    required this.name,
    required this.address,
    required this.type,
    required this.lat,
    required this.lng,
  });

  factory AddressSearchResult.fromJson(Map<String, dynamic> json) {
    final coords = json['coordinates'] ?? {};
    return AddressSearchResult(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      type: json['type'] ?? '',
      lat: (coords['lat'] ?? 0).toDouble(),
      lng: (coords['lng'] ?? 0).toDouble(),
    );
  }

  /// Lấy icon theo loại địa chỉ
  String get typeIcon {
    switch (type.toLowerCase()) {
      case 'landmark':
        return '🏛️';
      case 'restaurant':
        return '🍽️';
      case 'hotel':
        return '🏨';
      case 'hospital':
        return '🏥';
      case 'school':
        return '🏫';
      case 'shop':
        return '🛒';
      case 'park':
        return '🌳';
      case 'station':
        return '🚉';
      case 'airport':
        return '✈️';
      default:
        return '📍';
    }
  }
}