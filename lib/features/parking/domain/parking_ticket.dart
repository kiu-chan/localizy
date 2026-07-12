/// Vé đậu xe (payload từ API parking).
class ParkingTicket {
  const ParkingTicket({
    required this.id,
    required this.ticketCode,
    required this.licensePlate,
    required this.addressId,
    required this.duration,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    required this.startTime,
    required this.endTime,
    this.paidAt,
  });

  factory ParkingTicket.fromJson(Map<String, dynamic> json) {
    return ParkingTicket(
      id: json['id']?.toString() ?? '',
      ticketCode: json['ticketCode'] ?? '',
      licensePlate: json['licensePlate'] ?? '',
      addressId: json['addressId']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      amount: (json['amount'] ?? 0).toInt(),
      status: (json['status'] as String? ?? '').toLowerCase(),
      paymentMethod: json['paymentMethod'] ?? '',
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'])
          : DateTime.now(),
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
    );
  }

  final String id;
  final String ticketCode;
  final String licensePlate;
  final String addressId;
  final String duration;
  final int amount;

  /// Trạng thái thô: active / expired / cancelled / pending...
  final String status;
  final String paymentMethod;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime? paidAt;
}
