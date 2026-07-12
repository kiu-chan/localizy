import 'package:flutter/material.dart';

import '../../domain/validation_entry.dart';
import 'history_format.dart';

/// Card một yêu cầu xác minh địa chỉ (tab Verification).
class ValidationCard extends StatelessWidget {
  const ValidationCard({super.key, required this.entry, required this.onTap});

  final ValidationEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
                      color: Colors.purple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.verified_outlined,
                      color: Colors.purple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Address Verification',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.requestId,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (entry.amount > 0)
                        Text(
                          HistoryFormat.currency(entry.amount),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
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
                              size: 14,
                              color: statusColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              entry.status,
                              style: TextStyle(
                                fontSize: 12,
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
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
                        HistoryFormat.date(entry.createdAt),
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  if (entry.paymentMethod.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          HistoryFormat.paymentIcon(entry.paymentMethod),
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          HistoryFormat.paymentName(
                              context, entry.paymentMethod),
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
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
