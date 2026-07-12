import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localizy/core/config/currency_config.dart';
import 'package:localizy/l10n/app_localizations.dart';

import '../../domain/history_entry.dart';

/// Helpers hiển thị dùng chung cho toàn bộ lịch sử giao dịch.
abstract final class HistoryFormat {
  static String currency(num amount) => CurrencyConfig.format(amount.toDouble());

  static String date(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inDays == 0) {
      return 'Today ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    }
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  /// Nhận cả trạng thái giao dịch (success/failed/pending)
  /// lẫn trạng thái xác minh (verified/rejected/pending).
  static Color statusColor(String status) => switch (status.toLowerCase()) {
        'success' || 'verified' => Colors.green,
        'failed' || 'rejected' => Colors.red,
        'pending' => Colors.orange,
        _ => Colors.grey,
      };

  static IconData statusIcon(String status) => switch (status.toLowerCase()) {
        'success' || 'verified' => Icons.check_circle,
        'failed' || 'rejected' => Icons.cancel,
        'pending' => Icons.pending,
        _ => Icons.help,
      };

  static String statusLabel(String status) => switch (status.toLowerCase()) {
        'success' => 'Success',
        'failed' => 'Failed',
        'pending' => 'Pending',
        _ => 'Unknown',
      };

  static Color typeColor(HistoryType type) => switch (type) {
        HistoryType.parking => Colors.blue,
        HistoryType.verification => Colors.purple,
        HistoryType.other => Colors.grey,
      };

  static IconData typeIcon(HistoryType type) => switch (type) {
        HistoryType.parking => Icons.local_parking,
        HistoryType.verification => Icons.verified_outlined,
        HistoryType.other => Icons.receipt,
      };

  static IconData paymentIcon(String method) =>
      switch (method.toLowerCase()) {
        'momo' => Icons.account_balance_wallet,
        'zalopay' => Icons.payment,
        'bank' => Icons.account_balance,
        'card' => Icons.credit_card,
        _ => Icons.payment,
      };

  static String paymentName(BuildContext context, String method) {
    final l10n = AppLocalizations.of(context)!;
    return switch (method.toLowerCase()) {
      'momo' => l10n.paymentMomo,
      'zalopay' => l10n.paymentZaloPay,
      'bank' => l10n.paymentBankTransfer,
      'card' => l10n.paymentCard,
      _ => l10n.paymentUnknown,
    };
  }
}
