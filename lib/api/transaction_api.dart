import 'package:localizy/api/main_api.dart';

class Transaction {
  final String id;
  final String type;
  final String description;
  final int amount;
  final String status;
  final String paymentMethod;
  final String referenceId;
  final DateTime date;

  Transaction({
    required this.id,
    required this.type,
    required this.description,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    required this.referenceId,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      amount: (json['amount'] ?? 0).toInt(),
      status: (json['status'] as String? ?? '').toLowerCase(),
      paymentMethod: json['paymentMethod'] ?? '',
      referenceId: json['referenceId']?.toString() ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
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
