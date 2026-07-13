import 'package:flutter/material.dart';
import 'package:localizy/l10n/app_localizations.dart';

import '../../domain/validation_assignment.dart';
import 'validation_badges.dart';

class AssignmentCard extends StatelessWidget {
  final ValidationAssignment assignment;
  final VoidCallback onTap;

  const AssignmentCard({
    super.key,
    required this.assignment,
    required this.onTap,
  });

  String? _locationLabel(ValidationAssignment a) {
    if (a.address?.lat != null && a.address?.lng != null) {
      return '${a.address!.lat!.toStringAsFixed(5)}, ${a.address!.lng!.toStringAsFixed(5)}';
    }
    if (a.address?.cityCode.isNotEmpty == true) return a.address!.cityCode;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final a = assignment;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        a.requestType,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(a.requestId,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  a.address?.code ?? l10n.validatorNoAddress,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (_locationLabel(a) != null) ...[
                      Icon(
                        a.address?.lat != null
                            ? Icons.my_location
                            : Icons.location_on,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(_locationLabel(a)!,
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade600)),
                      const SizedBox(width: 16),
                    ],
                    Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      a.assignedDate != null
                          ? formatValidationDate(a.assignedDate!)
                          : '-',
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      ValidationStatusBadge(status: a.status),
                      const SizedBox(width: 8),
                      ValidationPriorityBadge(priority: a.priority),
                    ]),
                    Icon(Icons.arrow_forward_ios,
                        size: 14, color: Colors.grey.shade400),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
