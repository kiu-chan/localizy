import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localizy/core/network/api_client.dart';

import '../domain/address_models.dart';

final addressRepositoryProvider = Provider<AddressRepository>(
  (ref) => AddressRepository(ref.watch(apiClientProvider)),
);

class AddressRepository {
  AddressRepository(this._client);

  final ApiClient _client;

  /// Trích xuất danh sách items từ PagedResult hoặc List thuần
  static List<dynamic> _extractItems(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('items')) {
      return data['items'] as List<dynamic>;
    }
    if (data is List) return data;
    throw Exception('Unexpected response format');
  }

  /// GET /api/addresses/coordinates — tọa độ mọi địa chỉ (đổ marker bản đồ).
  Future<List<AddressCoordinate>> fetchCoordinates() async {
    final resp = await _client.get('/api/addresses/coordinates',
        headers: {'accept': 'text/plain'});
    if (resp.statusCode == 200) {
      final raw = json.decode(resp.body);
      final items = raw is List ? raw : (raw['items'] as List? ?? []);
      return items
          .map((item) =>
              AddressCoordinate.fromJson(item as Map<String, dynamic>))
          .where((a) => a.lat != 0 || a.lng != 0)
          .toList();
    }
    throw Exception('Failed to fetch address coordinates: ${resp.statusCode}');
  }

  /// GET /api/Addresses/search — tìm kiếm cho thanh search trên bản đồ.
  Future<List<AddressSearchResult>> search(String searchTerm) async {
    if (searchTerm.trim().isEmpty) return [];

    final encoded = Uri.encodeComponent(searchTerm);
    final resp = await _client.get('/api/Addresses/search?searchTerm=$encoded',
        headers: {'accept': 'text/plain'});

    if (resp.statusCode == 200) {
      return _extractItems(json.decode(resp.body))
          .map((e) => AddressSearchResult.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to search addresses: ${resp.statusCode}');
  }

  /// GET /api/addresses/my-addresses — địa chỉ của user hiện tại.
  Future<List<MyAddress>> getMyAddresses() async {
    final data = await _client.getJson('api/addresses/my-addresses');
    return _extractItems(data)
        .map((e) => MyAddress.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/business/addresses — địa chỉ của cả nhóm doanh nghiệp.
  Future<List<MyAddress>> getBusinessAddresses() async {
    final data = await _client.getJson('api/business/addresses');
    return _extractItems(data)
        .map((e) => MyAddress.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/business/addresses/mine — chỉ địa chỉ tài khoản này đã thêm.
  Future<List<MyAddress>> getBusinessMineAddresses() async {
    final data = await _client.getJson('api/business/addresses/mine');
    return _extractItems(data)
        .map((e) => MyAddress.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/addresses — thêm địa chỉ mới (Business/SubAccount).
  Future<MyAddress> addAddress({
    required String name,
    required String fullAddress,
    required double latitude,
    required double longitude,
    required String cityId,
  }) async {
    final resp = await _client.postJson('api/addresses', {
      'cityId': cityId,
      'name': name,
      'fullAddress': fullAddress,
      'latitude': latitude,
      'longitude': longitude,
      'parkingAvailable': false,
      'totalParkingSpots': 0,
      'pricePerHour': 0,
    });

    if (resp.statusCode == 201 || resp.statusCode == 200) {
      final data = json.decode(resp.body);
      if (data is Map<String, dynamic>) return MyAddress.fromJson(data);
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

  /// GET /api/addresses — tất cả địa chỉ (public).
  Future<List<AddressItem>> fetchAll() async {
    final data = await _client.getJson('api/addresses');
    return _extractItems(data)
        .map((e) => AddressItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/addresses/search — tìm kiếm cho màn address_search.
  Future<List<AddressItem>> searchItems(String searchTerm) async {
    if (searchTerm.trim().isEmpty) return [];
    final encoded = Uri.encodeComponent(searchTerm.trim());
    final data =
        await _client.getJson('api/addresses/search?searchTerm=$encoded');
    return _extractItems(data)
        .map((e) => AddressItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/Addresses/detail/{id} — chi tiết địa chỉ.
  Future<AddressDetail> getDetail(String id) async {
    final resp = await _client
        .get('/api/Addresses/detail/$id', headers: {'accept': 'text/plain'});
    if (resp.statusCode == 200) {
      return AddressDetail.fromJson(json.decode(resp.body));
    }
    throw Exception('Failed to get address detail: ${resp.statusCode}');
  }
}
