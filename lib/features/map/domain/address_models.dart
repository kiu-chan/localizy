/// Model địa chỉ của user (Business/SubAccount) trên bản đồ.
class MyAddress {
  const MyAddress({
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
}

/// Model rút gọn: chỉ id, code và tọa độ (đổ marker lên bản đồ).
class AddressCoordinate {
  const AddressCoordinate({
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

  final String id;
  final String code;
  final double lat;
  final double lng;
}

/// Kết quả tìm kiếm địa chỉ (thanh search trên bản đồ).
class AddressSearchResult {
  const AddressSearchResult({
    required this.id,
    required this.code,
    required this.name,
    required this.address,
    required this.type,
    required this.lat,
    required this.lng,
  });

  factory AddressSearchResult.fromJson(Map<String, dynamic> json) {
    return AddressSearchResult(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      address: json['fullAddress'] ?? json['address'] ?? '',
      type: json['type'] ?? '',
      lat: (json['latitude'] ?? 0).toDouble(),
      lng: (json['longitude'] ?? 0).toDouble(),
    );
  }

  final String id;
  final String code;
  final String name;
  final String address;
  final String type;
  final double lat;
  final double lng;
}

/// Kết quả tìm kiếm cho màn hình address_search.
class AddressItem {
  const AddressItem({
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
}

/// Chi tiết địa chỉ — khớp với Address Response Object từ API.
class AddressDetail {
  const AddressDetail({
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

  /// Format toạ độ đẹp hơn
  String get formattedCoordinates {
    final latDir = lat >= 0 ? 'N' : 'S';
    final lngDir = lng >= 0 ? 'E' : 'W';
    return '${lat.abs().toStringAsFixed(6)}° $latDir, '
        '${lng.abs().toStringAsFixed(6)}° $lngDir';
  }

  /// Format ngày tạo
  String? get formattedCreatedAt {
    if (createdAt == null) return null;
    return '${createdAt!.day.toString().padLeft(2, '0')}/'
        '${createdAt!.month.toString().padLeft(2, '0')}/${createdAt!.year}';
  }

  /// Format giá đỗ xe
  String get formattedPricePerHour {
    if (pricePerHour <= 0) return 'Miễn phí';
    return '${pricePerHour.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} đ/giờ';
  }
}
