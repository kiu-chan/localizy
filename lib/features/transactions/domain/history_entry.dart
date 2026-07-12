/// Loại giao dịch trong lịch sử.
enum HistoryType {
  parking,
  verification,
  other;

  static HistoryType from(String raw) => switch (raw) {
        'parking' => parking,
        'verification' => verification,
        _ => other,
      };
}

/// Một dòng trong lịch sử giao dịch (tab All và tab Parking).
///
/// Dữ liệu đã được join sẵn với parking zone ở tầng data:
/// [location] là tên hiển thị, [latitude]/[longitude] dùng cho "View on Map".
class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.location,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    required this.date,
    this.licensePlate,
    this.duration,
    this.latitude,
    this.longitude,
    this.zoneId,
    this.zoneCode,
    this.zoneName,
    this.availableSpots = 0,
    this.totalSpots = 0,
    this.pricePerHour = 0,
  });

  final String id;
  final HistoryType type;
  final String title;
  final String location;
  final int amount;

  /// Đã chuẩn hóa: success / failed / pending.
  final String status;
  final String paymentMethod;
  final DateTime date;
  final String? licensePlate;
  final String? duration;

  final double? latitude;
  final double? longitude;
  final String? zoneId;
  final String? zoneCode;
  final String? zoneName;
  final int availableSpots;
  final int totalSpots;
  final int pricePerHour;

  bool get hasCoordinates => latitude != null && longitude != null;
}
