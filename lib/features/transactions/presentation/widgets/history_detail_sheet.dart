import 'package:flutter/material.dart';
import 'package:localizy/features/parking/presentation/pages/parking_zone_detail_map_page.dart';

import '../../domain/history_entry.dart';
import 'detail_row.dart';
import 'history_format.dart';
import 'package:localizy/core/widgets/receipt_share.dart';
import 'package:localizy/core/widgets/receipt_widget.dart';

/// Mở bottom sheet chi tiết giao dịch.
void showHistoryDetailSheet(
  BuildContext context,
  HistoryEntry entry, {
  bool parkingStyle = false,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        HistoryDetailSheet(entry: entry, parkingStyle: parkingStyle),
  );
}

class HistoryDetailSheet extends StatelessWidget {
  const HistoryDetailSheet({
    super.key,
    required this.entry,
    this.parkingStyle = false,
  });

  final HistoryEntry entry;

  /// true khi mở từ tab Parking: biên lai dạng vé đậu xe
  /// (nhãn Ticket Code/Zone, badge biển số, trạng thái "Paid").
  final bool parkingStyle;

  @override
  Widget build(BuildContext context) {
    final typeColor = HistoryFormat.typeColor(entry.type);
    final statusColor = HistoryFormat.statusColor(entry.status);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          HistoryFormat.typeIcon(entry.type),
                          color: typeColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  HistoryFormat.statusIcon(entry.status),
                                  size: 16,
                                  color: statusColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  HistoryFormat.statusLabel(entry.status),
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'Amount',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          HistoryFormat.currency(entry.amount),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  DetailRow('Transaction ID', entry.id),
                  DetailRow('Date & Time', HistoryFormat.date(entry.date)),
                  DetailRow('Location', entry.location),
                  if (entry.licensePlate != null &&
                      entry.licensePlate!.isNotEmpty)
                    DetailRow('License Plate', entry.licensePlate!),
                  if (entry.duration != null && entry.duration!.isNotEmpty)
                    DetailRow('Duration', entry.duration!),
                  DetailRow(
                    'Payment Method',
                    HistoryFormat.paymentName(context, entry.paymentMethod),
                    icon: HistoryFormat.paymentIcon(entry.paymentMethod),
                  ),
                  const SizedBox(height: 24),
                  if (entry.hasCoordinates) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _openMap(context);
                        },
                        icon: const Icon(Icons.map),
                        label: const Text('View on Map'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _shareReceipt(context),
                      icon: const Icon(Icons.download),
                      label: const Text('Download'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openMap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ParkingZoneDetailMapPage(
          zoneId: _orFallback(entry.zoneId, entry.id),
          zoneCode: _orFallback(entry.zoneCode, entry.id),
          zoneName: _orFallback(entry.zoneName, entry.title),
          latitude: entry.latitude!,
          longitude: entry.longitude!,
          availableSpots: entry.availableSpots,
          totalSpots: entry.totalSpots,
          pricePerHour: entry.pricePerHour,
        ),
      ),
    );
  }

  static String _orFallback(String? value, String fallback) =>
      (value == null || value.isEmpty) ? fallback : value;

  Future<void> _shareReceipt(BuildContext context) {
    final paymentStr = HistoryFormat.paymentName(context, entry.paymentMethod);
    final dateStr = HistoryFormat.date(entry.date);
    final amountStr = HistoryFormat.currency(entry.amount);
    final statusColor = _receiptStatusColor(entry.status);

    final Widget receipt;
    if (parkingStyle) {
      receipt = ReceiptWidget(
        headerColor: const Color(0xFF1565C0),
        typeIcon: Icons.local_parking,
        subtitle: 'Parking Payment',
        amountText: amountStr,
        statusLabel: entry.status == 'success'
            ? 'Paid'
            : HistoryFormat.statusLabel(entry.status),
        statusIcon: _receiptStatusIcon(entry.status),
        badgeText: entry.licensePlate,
        rows: [
          ReceiptRow('Ticket Code', entry.id),
          ReceiptRow('Date', dateStr),
          ReceiptRow('Zone', entry.location),
          ReceiptRow('Duration', entry.duration ?? ''),
          ReceiptRow('Payment', paymentStr),
          ReceiptRow('Status', HistoryFormat.statusLabel(entry.status),
              valueColor: statusColor),
        ],
      );
    } else {
      receipt = ReceiptWidget(
        headerColor: switch (entry.type) {
          HistoryType.parking => const Color(0xFF1565C0),
          HistoryType.verification => const Color(0xFF6A1B9A),
          HistoryType.other => const Color(0xFF2E7D32),
        },
        typeIcon: switch (entry.type) {
          HistoryType.parking => Icons.local_parking,
          HistoryType.verification => Icons.verified_outlined,
          HistoryType.other => Icons.receipt_long,
        },
        subtitle: entry.title,
        amountText: amountStr,
        statusLabel: HistoryFormat.statusLabel(entry.status),
        statusIcon: _receiptStatusIcon(entry.status),
        rows: [
          ReceiptRow('Transaction ID', entry.id),
          ReceiptRow('Date', dateStr),
          ReceiptRow('Location', entry.location),
          if (entry.licensePlate != null && entry.licensePlate!.isNotEmpty)
            ReceiptRow('License Plate', entry.licensePlate!),
          if (entry.duration != null && entry.duration!.isNotEmpty)
            ReceiptRow('Duration', entry.duration!),
          ReceiptRow('Payment', paymentStr),
          ReceiptRow('Status', HistoryFormat.statusLabel(entry.status),
              valueColor: statusColor),
        ],
      );
    }

    final prefix = parkingStyle ? 'parking_receipt' : 'receipt';
    final shareText =
        parkingStyle ? 'Parking Receipt · Localizy' : 'Transaction Receipt · Localizy';
    return shareReceiptImage(
      context,
      receipt: receipt,
      fileName: '${prefix}_${entry.id}.png',
      shareText: shareText,
    );
  }

  static Color _receiptStatusColor(String status) => switch (status) {
        'success' => const Color(0xFF43A047),
        'failed' => const Color(0xFFE53935),
        _ => const Color(0xFFFB8C00),
      };

  static IconData _receiptStatusIcon(String status) => switch (status) {
        'success' => Icons.check_circle_outline,
        'failed' => Icons.cancel_outlined,
        _ => Icons.hourglass_empty,
      };
}
