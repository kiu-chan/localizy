import 'dart:convert';
import 'package:localizy/api/main_api.dart';

/// Model địa chỉ dùng cho map page (Business/SubAccount)
class MyAddress {
  final String id;
  final String code;
  final String name;
  final String fullAddress;
  final String userId;
  final String userName;
  final double latitude;
  final double longitude;
  final String cityName;
  final String status;
  final String comments;
  final String createdAt;

  MyAddress({
    required this.id,
    required this.code,
    required this.name,
    required this.fullAddress,
    required this.userId,
    required this.userName,
    required this.latitude,
    required this.longitude,
    required this.cityName,
    required this.status,
    required this.comments,
    required this.createdAt,
  });

  factory MyAddress.fromJson(Map<String, dynamic> json) {
    return MyAddress(
      id: json['id']?.toString() ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      fullAddress: json['fullAddress'] ?? '',
      userId: json['userId']?.toString() ?? '',
      userName: json['userName'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      cityName: json['cityName'] ?? '',
      status: json['status'] ?? '',
      comments: json['comments'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class AddressApi {
  // Lấy danh sách địa chỉ có id, code và toạ độ
  static Future<List<AddressCoordinate>> fetchCoordinates() async {
    final resp = await MainApi.instance.get('/api/Addresses',
      headers: {'accept': 'text/plain'},
    );
    if (resp.statusCode == 200) {
      final raw = json.decode(resp.body);
      if (raw is List) {
        return raw
            .map((item) => AddressCoordinate(
                  id: item['id']?.toString() ?? '',
                  code: item['code'] ?? '',
                  lat: (item['latitude'] ?? 0).toDouble(),
                  lng: (item['longitude'] ?? 0).toDouble(),
                ))
            .where((a) => a.lat != 0 || a.lng != 0)
            .toList();
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

  /// GET /api/addresses/my-addresses
  /// Lấy danh sách địa chỉ của user hiện tại (Business/SubAccount)
  static Future<List<MyAddress>> getMyAddresses() async {
    final data = await MainApi.instance.getJson('api/addresses/my-addresses');
    if (data is List) {
      return data.map((e) => MyAddress.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Unexpected response format: expected list');
  }

  /// GET /api/business/addresses
  /// Lấy địa chỉ của cả nhóm doanh nghiệp (Business + tất cả SubAccounts)
  /// - Role Business: địa chỉ của business + tất cả sub-accounts
  /// - Role SubAccount: địa chỉ của parent business + tất cả sub-accounts cùng cấp
  static Future<List<MyAddress>> getBusinessAddresses() async {
    final data = await MainApi.instance.getJson('api/business/addresses');
    if (data is List) {
      return data.map((e) => MyAddress.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Unexpected response format: expected list');
  }

  /// GET /api/business/addresses/mine
  /// Chỉ trả về địa chỉ mà chính tài khoản đang đăng nhập đã thêm
  static Future<List<MyAddress>> getBusinessMineAddresses() async {
    final data = await MainApi.instance.getJson('api/business/addresses/mine');
    if (data is List) {
      return data.map((e) => MyAddress.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Unexpected response format: expected list');
  }

  /// POST /api/addresses
  /// Thêm địa chỉ mới (Business/SubAccount → status = Reviewed ngay lập tức)
  static Future<MyAddress> addAddress({
    required String name,
    required String fullAddress,
    required double latitude,
    required double longitude,
    required String cityId,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'fullAddress': fullAddress,
      'latitude': latitude,
      'longitude': longitude,
      'cityId': cityId,
      'extraDocs': null,
    };

    final resp = await MainApi.instance.postJson('api/addresses', body);

    if (resp.statusCode == 201 || resp.statusCode == 200) {
      final data = json.decode(resp.body);
      if (data is Map<String, dynamic>) {
        return MyAddress.fromJson(data);
      }
      throw Exception('Unexpected response format');
    }

    String message = 'Failed to add address';
    try {
      final parsed = json.decode(resp.body);
      if (parsed is Map && parsed['message'] != null) {
        message = parsed['message'].toString();
      }
    } catch (_) {}
    throw Exception('Error ${resp.statusCode}: $message');
  }

  /// GET /api/addresses
  /// Lấy tất cả địa chỉ (Public)
  static Future<List<AddressItem>> fetchAll() async {
    final data = await MainApi.instance.getJson('api/addresses');
    if (data is List) {
      return data
          .map((e) => AddressItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Unexpected response format: expected list');
  }

  /// GET /api/addresses/search?searchTerm={term}
  /// Tìm kiếm địa chỉ cho màn hình address_search (trả về AddressItem)
  static Future<List<AddressItem>> searchItems(String searchTerm) async {
    if (searchTerm.trim().isEmpty) return [];
    final encoded = Uri.encodeComponent(searchTerm.trim());
    final data =
        await MainApi.instance.getJson('api/addresses/search?searchTerm=$encoded');
    if (data is List) {
      return data
          .map((e) => AddressItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Unexpected response format: expected list');
  }

  /// GET /api/addresses/parking-zones
  /// Lấy danh sách khu vực đậu xe
  static Future<List<ParkingZoneItem>> getParkingZones() async {
    final data =
        await MainApi.instance.getJson('api/addresses/parking-zones');
    if (data is List) {
      return data
          .map((e) => ParkingZoneItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Unexpected response format: expected list');
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

/// Model đơn giản hoá chỉ chứa id, code và coordinates
class AddressCoordinate {
  final String id;
  final String code;
  final double lat;
  final double lng;

  AddressCoordinate({
    required this.id,
    this.code = '',
    required this.lat,
    required this.lng,
  });

  factory AddressCoordinate.fromJson(Map<String, dynamic> json) {
    final coords = json['coordinates'] ?? {};
    return AddressCoordinate(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
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

/// Model kết quả tìm kiếm địa chỉ cho màn hình address_search
class AddressItem {
  final String id;
  final String code;
  final String name;
  final String fullAddress;
  final String cityName;
  final double latitude;
  final double longitude;
  final bool isVerified;
  final bool parkingAvailable;
  final int parkingSpots;

  AddressItem({
    required this.id,
    required this.code,
    required this.name,
    required this.fullAddress,
    required this.cityName,
    required this.latitude,
    required this.longitude,
    required this.isVerified,
    required this.parkingAvailable,
    required this.parkingSpots,
  });

  factory AddressItem.fromJson(Map<String, dynamic> json) {
    return AddressItem(
      id: json['id']?.toString() ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      fullAddress: json['fullAddress'] ?? '',
      cityName: json['cityName'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      isVerified: json['isVerified'] ?? false,
      parkingAvailable: json['parkingAvailable'] ?? false,
      parkingSpots:
          (json['availableSpots'] ?? json['totalParkingSpots'] ?? 0).toInt(),
    );
  }
}

/// Model khu vực đậu xe cho bản đồ
class ParkingZoneItem {
  final String id;
  final String code;
  final String name;
  final double latitude;
  final double longitude;
  final int availableSpots;
  final int totalSpots;
  final int pricePerHour;

  ParkingZoneItem({
    required this.id,
    required this.code,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.availableSpots,
    required this.totalSpots,
    required this.pricePerHour,
  });

  factory ParkingZoneItem.fromJson(Map<String, dynamic> json) {
    return ParkingZoneItem(
      id: json['id']?.toString() ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? json['fullAddress'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      availableSpots: (json['availableSpots'] ?? 0).toInt(),
      totalSpots: (json['totalParkingSpots'] ?? 0).toInt(),
      pricePerHour: (json['pricePerHour'] ?? 0).toInt(),
    );
  }
}

/// Model chi tiết địa chỉ - khớp với Address Response Object từ API
class AddressDetail {
  final String id;
  final String code;
  final String name;
  final String fullAddress;
  final String userName;
  final double lat;
  final double lng;
  final String cityName;
  final String status;
  final bool isVerified;
  final String? validatorName;
  final String? comments;
  final bool parkingAvailable;
  final int totalParkingSpots;
  final int availableSpots;
  final int pricePerHour;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AddressDetail({
    required this.id,
    required this.code,
    required this.name,
    required this.fullAddress,
    required this.userName,
    required this.lat,
    required this.lng,
    required this.cityName,
    required this.status,
    required this.isVerified,
    this.validatorName,
    this.comments,
    required this.parkingAvailable,
    required this.totalParkingSpots,
    required this.availableSpots,
    required this.pricePerHour,
    this.createdAt,
    this.updatedAt,
  });

  factory AddressDetail.fromJson(Map<String, dynamic> json) {
    return AddressDetail(
      id: json['id']?.toString() ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      fullAddress: json['fullAddress'] ?? '',
      userName: json['userName'] ?? '',
      lat: (json['latitude'] ?? 0).toDouble(),
      lng: (json['longitude'] ?? 0).toDouble(),
      cityName: json['cityName'] ?? '',
      status: json['status'] ?? '',
      isVerified: json['isVerified'] ?? false,
      validatorName: json['validatorName'],
      comments: json['comments'],
      parkingAvailable: json['parkingAvailable'] ?? false,
      totalParkingSpots: (json['totalParkingSpots'] ?? 0).toInt(),
      availableSpots: (json['availableSpots'] ?? 0).toInt(),
      pricePerHour: (json['pricePerHour'] ?? 0).toInt(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
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

  /// Format giá đỗ xe
  String get formattedPricePerHour {
    if (pricePerHour <= 0) return 'Miễn phí';
    return '${pricePerHour.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} đ/giờ';
  }
}