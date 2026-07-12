/// Một yêu cầu xác minh địa chỉ trong lịch sử (tab Verification).
class ValidationEntry {
  const ValidationEntry({
    required this.requestId,
    required this.status,
    required this.createdAt,
    required this.notes,
    required this.amount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.latitude,
    required this.longitude,
    required this.idType,
    this.idDocumentUrl,
    this.addressProofUrl,
    this.appointmentDate,
    required this.appointmentTimeSlot,
  });

  factory ValidationEntry.fromJson(Map<String, dynamic> json) {
    final payment = json['paymentInfo'] as Map?;
    final location = json['locationInfo'] as Map?;
    final documents = json['documentFiles'] as Map?;
    final appointment = json['appointmentInfo'] as Map?;

    return ValidationEntry(
      requestId: json['requestId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      notes: json['notes']?.toString() ?? '',
      amount: ((payment?['amount'] ?? 0) as num).toInt(),
      paymentMethod: payment?['method']?.toString() ?? '',
      paymentStatus: payment?['status']?.toString() ?? '',
      latitude: ((location?['latitude'] ?? 0.0) as num).toDouble(),
      longitude: ((location?['longitude'] ?? 0.0) as num).toDouble(),
      idType: documents?['idType']?.toString() ?? '',
      idDocumentUrl: documents?['idDocumentUrl'] as String?,
      addressProofUrl: documents?['addressProofUrl'] as String?,
      appointmentDate: appointment?['date'] != null
          ? DateTime.parse(appointment!['date'] as String)
          : null,
      appointmentTimeSlot: appointment?['timeSlot']?.toString() ?? '',
    );
  }

  final String requestId;

  /// Trạng thái thô từ API: Verified / Rejected / Pending.
  final String status;
  final DateTime createdAt;
  final String notes;
  final int amount;
  final String paymentMethod;
  final String paymentStatus;
  final double latitude;
  final double longitude;
  final String idType;
  final String? idDocumentUrl;
  final String? addressProofUrl;
  final DateTime? appointmentDate;
  final String appointmentTimeSlot;

  bool get hasCoordinates => latitude != 0.0 || longitude != 0.0;
}
