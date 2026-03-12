import 'package:localizy/api/main_api.dart';

class Transaction {
  final String id;
  final String type;
  final String title;
  final String location;
  final int amount;
  final String status;
  final String paymentMethod;
  final DateTime date;
  final String? licensePlate;
  final String? duration;

  Transaction({
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
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      location: json['location']?.toString() ?? '',
      amount: (json['amount'] ?? 0).toInt(),
      status: (json['status'] as String? ?? '').toLowerCase(),
      paymentMethod: json['paymentMethod'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      licensePlate: json['licensePlate'] as String?,
      duration: json['duration'] as String?,
    );
  }
}

class TransactionApi {
  /// GET /api/transactions/my-transactions
  /// Lấy lịch sử giao dịch của người dùng hiện tại
  static Future<List<Transaction>> getMyTransactions() async {
    final data =
        await MainApi.instance.getJson('api/transactions/my-transactions');
    if (data is List) {
      return data
          .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Unexpected response format: expected list');
  }
}
