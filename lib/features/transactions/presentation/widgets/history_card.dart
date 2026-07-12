import 'package:flutter/material.dart';

import '../../domain/history_entry.dart';
import 'history_format.dart';

/// Card một giao dịch trong danh sách (tab All và tab Parking).
class HistoryCard extends StatelessWidget {
  const HistoryCard({
    super.key,
    required this.entry,
    required this.onTap,
    this.showDuration = false,
  });

  final HistoryEntry entry;
  final VoidCallback onTap;

  /// Tab Parking hiển thị thời lượng đỗ thay cho phương thức thanh toán.
  final bool showDuration;

  @override
  Widget build(BuildContext context) {
    final typeColor = HistoryFormat.typeColor(entry.type);
    final statusColor = HistoryFormat.statusColor(entry.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      HistoryFormat.typeIcon(entry.type),
                      color: typeColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.location,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        HistoryFormat.currency(entry.amount),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            HistoryFormat.statusIcon(entry.status),
                            size: 14,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            HistoryFormat.statusLabel(entry.status),
                            style: TextStyle(
                              fontSize: 12,
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        HistoryFormat.date(entry.date),
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  if (showDuration && entry.duration != null)
                    Row(
                      children: [
                        Icon(Icons.timer, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          entry.duration!,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Icon(
                          HistoryFormat.paymentIcon(entry.paymentMethod),
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          HistoryFormat.paymentName(context, entry.paymentMethod),
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  if (entry.licensePlate != null &&
                      entry.licensePlate!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        entry.licensePlate!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
