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

  // Lấy chi tiết địa chỉ theo ID
  static Future<AddressDetail> getDetail(String id) async {
    final resp = await MainApi.instance.get(
      '/api/Addresses/detail/$id',
      headers: {'accept': 'text/plain'},
    );
    
    if (resp.statusCode == 200) {
      final raw = json.decode(resp.body);
      return AddressDetail.fromJson(raw);
    }
    throw Exception('Failed to get address detail: ${resp.statusCode}');
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
}

/// Model chi tiết địa chỉ
class AddressDetail {
  final String id;
  final String name;
  final String address;
  final String type;
  final String? category;
  final String? description;
  final double lat;
  final double lng;
  final String? phone;
  final String? website;
  final String? openingHours;
  final DateTime? createdAt;

  AddressDetail({
    required this.id,
    required this.name,
    required this.address,
    required this.type,
    this.category,
    this.description,
    required this.lat,
    required this.lng,
    this.phone,
    this.website,
    this.openingHours,
    this.createdAt,
  });

  factory AddressDetail.fromJson(Map<String, dynamic> json) {
    final coords = json['coordinates'] ?? {};
    return AddressDetail(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      type: json['type'] ?? '',
      category: json['category'],
      description: json['description'],
      lat: (coords['lat'] ?? 0).toDouble(),
      lng: (coords['lng'] ?? 0).toDouble(),
      phone: json['phone'],
      website: json['website'],
      openingHours: json['openingHours'],
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) 
          : null,
    );
  }

  /// Format toạ độ đẹp hơn
  String get formattedCoordinates {
    final latDir = lat >= 0 ? 'N' : 'S';
    final lngDir = lng >= 0 ? 'E' : 'W';
    return '${lat.abs().toStringAsFixed(6)}° $latDir, ${lng.abs().toStringAsFixed(6)}° $lngDir';
  }

  /// Format ngày tạo
  String? get formattedCreatedAt {
    if (createdAt == null) return null;
    return '${createdAt!.day.toString().padLeft(2, '0')}/${createdAt!.month.toString().padLeft(2, '0')}/${createdAt!.year}';
  }
}