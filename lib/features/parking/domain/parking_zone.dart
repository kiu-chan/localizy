/// Bãi đậu xe (parking zone) — dùng cho chọn bãi và tra cứu tên bãi.
class ParkingZone {
  const ParkingZone({
    required this.id,
    required this.code,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.availableSpots,
    required this.totalSpots,
    required this.pricePerHour,
  });

  factory ParkingZone.fromJson(Map<String, dynamic> json) {
    return ParkingZone(
      id: json['id']?.toString() ?? '',
      code: json['code'] ?? '',
      name: (json['name'] ?? json['fullAddress'] ?? '').toString(),
      latitude: ((json['latitude'] ?? 0.0) as num).toDouble(),
      longitude: ((json['longitude'] ?? 0.0) as num).toDouble(),
      availableSpots: ((json['availableSpots'] ?? 0) as num).toInt(),
      totalSpots: ((json['totalParkingSpots'] ?? 0) as num).toInt(),
      pricePerHour: ((json['pricePerHour'] ?? 0) as num).toInt(),
    );
  }

  final String id;
  final String code;
  final String name;
  final double latitude;
  final double longitude;
  final int availableSpots;
  final int totalSpots;
  final int pricePerHour;

  bool get isAvailable => availableSpots > 0;

  /// Tên hiển thị "CODE - Tên bãi".
  String get displayName => '$code - $name';
}
