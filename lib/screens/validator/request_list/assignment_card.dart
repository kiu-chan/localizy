import 'package:flutter/material.dart';
import 'package:localizy/api/validator_api.dart';
import 'package:localizy/l10n/app_localizations.dart';

class AssignmentCard extends StatelessWidget {
  final ValidationAssignment assignment;
  final VoidCallback onTap;

  const AssignmentCard({
    super.key,
    required this.assignment,
    required this.onTap,
  });

  (Color, IconData) _statusStyle(String s) => switch (s) {
        'Assigned' => (Colors.orange, Icons.assignment_ind),
        'Scheduled' => (Colors.blue, Icons.event_available),
        'Verified' => (Colors.green, Icons.verified),
        'Rejected' => (Colors.red, Icons.cancel),
        _ => (Colors.grey, Icons.event),
      };

  Widget _statusBadge(String status, Color color, IconData icon) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(status,
                style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Widget _priorityBadge(String priority) {
    final color = switch (priority) {
      'High' => Colors.red,
      'Medium' => Colors.orange,
      _ => Colors.grey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(priority,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }

  String _formatDate(DateTime dt) {
    final l = dt.toLocal();
    return '${l.day.toString().padLeft(2, '0')}/${l.month.toString().padLeft(2, '0')}/${l.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final a = assignment;
    final (Color sc, IconData si) = _statusStyle(a.status);

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
                    Icon(Icons.location_on,
                        size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(a.address?.cityCode ?? '-',
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade600)),
                    const SizedBox(width: 16),
                    Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      a.assignedDate != null
                          ? _formatDate(a.assignedDate!)
                          : '-',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      _statusBadge(a.status, sc, si),
                      const SizedBox(width: 8),
                      _priorityBadge(a.priority),
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
