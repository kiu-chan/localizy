import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/transaction_repository.dart';
import '../../domain/history_entry.dart';
import '../../domain/validation_entry.dart';

/// Tab All: mọi giao dịch.
final allHistoryProvider = FutureProvider<List<HistoryEntry>>(
  (ref) => ref.watch(transactionRepositoryProvider).getAllHistory(),
);

/// Tab Parking: vé đậu xe.
final parkingHistoryProvider = FutureProvider<List<HistoryEntry>>(
  (ref) => ref.watch(transactionRepositoryProvider).getParkingHistory(),
);

/// Tab Verification: yêu cầu xác minh địa chỉ.
final validationHistoryProvider = FutureProvider<List<ValidationEntry>>(
  (ref) => ref.watch(transactionRepositoryProvider).getValidationHistory(),
);
