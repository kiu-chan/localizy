import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:localizy/core/network/api_client.dart';
import 'package:localizy/screens/home/parking/parking_zone_detail_map_page.dart';

import '../../domain/validation_entry.dart';
import 'detail_row.dart';
import 'history_format.dart';
import 'receipt_share.dart';
import 'receipt_widget.dart';

/// Mở bottom sheet chi tiết yêu cầu xác minh địa chỉ.
void showValidationDetailSheet(BuildContext context, ValidationEntry entry) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ValidationDetailSheet(entry: entry),
  );
}

class ValidationDetailSheet extends ConsumerWidget {
  const ValidationDetailSheet({super.key, required this.entry});

  final ValidationEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = HistoryFormat.statusColor(entry.status);
    final baseUrl = ref.watch(apiClientProvider).baseUrl;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
                          color: Colors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.verified_outlined,
                          color: Colors.purple,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Address Verification',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    HistoryFormat.statusIcon(entry.status),
                                    size: 16,
                                    color: statusColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    entry.status,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  if (entry.amount > 0) ...[
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
                  ],
                  DetailRow('Request ID', entry.requestId),
                  DetailRow('Date & Time', HistoryFormat.date(entry.createdAt)),
                  DetailRow(
                    'Location',
                    'Lat: ${entry.latitude.toStringAsFixed(6)}, '
                        'Lng: ${entry.longitude.toStringAsFixed(6)}',
                  ),
                  if (entry.idType.isNotEmpty)
                    DetailRow('ID Type', entry.idType),
                  if (entry.paymentMethod.isNotEmpty)
                    DetailRow(
                      'Payment Method',
                      HistoryFormat.paymentName(context, entry.paymentMethod),
                      icon: HistoryFormat.paymentIcon(entry.paymentMethod),
                    ),
                  if (entry.paymentStatus.isNotEmpty)
                    DetailRow('Payment Status', entry.paymentStatus),
                  if (entry.appointmentDate != null)
                    DetailRow(
                      'Appointment',
                      '${DateFormat('dd/MM/yyyy').format(entry.appointmentDate!)}'
                          ' - ${entry.appointmentTimeSlot}',
                    ),
                  if (entry.notes.isNotEmpty) DetailRow('Notes', entry.notes),
                  if (entry.idDocumentUrl != null ||
                      entry.addressProofUrl != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Documents',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (entry.idDocumentUrl != null)
                          Expanded(
                            child: _DocumentPreview(
                              label: 'ID Document',
                              url: entry.idDocumentUrl!,
                              baseUrl: baseUrl,
                            ),
                          ),
                        if (entry.idDocumentUrl != null &&
                            entry.addressProofUrl != null)
                          const SizedBox(width: 12),
                        if (entry.addressProofUrl != null)
                          Expanded(
                            child: _DocumentPreview(
                              label: 'Address Proof',
                              url: entry.addressProofUrl!,
                              baseUrl: baseUrl,
                            ),
                          ),
                      ],
                    ),
                  ],
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
          zoneId: entry.requestId,
          zoneCode: entry.requestId,
          zoneName: 'Verification Location',
          latitude: entry.latitude,
          longitude: entry.longitude,
        ),
      ),
    );
  }

  Future<void> _shareReceipt(BuildContext context) {
    final statusLabel = switch (entry.status.toLowerCase()) {
      'verified' => 'Verified',
      'rejected' => 'Rejected',
      _ => 'Pending',
    };
    final statusColor = switch (entry.status.toLowerCase()) {
      'verified' => const Color(0xFF43A047),
      'rejected' => const Color(0xFFE53935),
      _ => const Color(0xFFFB8C00),
    };
    final statusIcon = switch (entry.status.toLowerCase()) {
      'verified' => Icons.check_circle_outline,
      'rejected' => Icons.cancel_outlined,
      _ => Icons.hourglass_empty,
    };
    final locationStr = entry.hasCoordinates
        ? '${entry.latitude.toStringAsFixed(4)}, '
            '${entry.longitude.toStringAsFixed(4)}'
        : '';
    final paymentStr = entry.paymentMethod.isNotEmpty
        ? HistoryFormat.paymentName(context, entry.paymentMethod)
        : '';

    return shareReceiptImage(
      context,
      receipt: ReceiptWidget(
        headerColor: const Color(0xFF6A1B9A),
        typeIcon: Icons.verified_outlined,
        subtitle: 'Address Verification',
        amountText:
            entry.amount > 0 ? HistoryFormat.currency(entry.amount) : null,
        statusLabel: statusLabel,
        statusIcon: statusIcon,
        footerText: 'Official Certificate · Citea',
        rows: [
          ReceiptRow('Request ID', entry.requestId),
          ReceiptRow('Date', HistoryFormat.date(entry.createdAt)),
          if (locationStr.isNotEmpty) ReceiptRow('Location', locationStr),
          if (entry.idType.isNotEmpty) ReceiptRow('ID Type', entry.idType),
          if (paymentStr.isNotEmpty) ReceiptRow('Payment', paymentStr),
          ReceiptRow('Status', statusLabel, valueColor: statusColor),
        ],
      ),
      fileName: 'verification_${entry.requestId}.png',
      shareText: 'Verification Receipt · Localizy',
    );
  }
}

class _DocumentPreview extends StatelessWidget {
  const _DocumentPreview({
    required this.label,
    required this.url,
    required this.baseUrl,
  });

  final String label;
  final String url;
  final String baseUrl;

  @override
  Widget build(BuildContext context) {
    final fullUrl = url.startsWith('http') ? url : '$baseUrl$url';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 8),
        Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              fullUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, color: Colors.grey.shade400),
                    const SizedBox(height: 4),
                    Text(
                      'Image',
                      style: TextStyle(
                          fontSize: 10, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
