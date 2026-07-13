import 'package:flutter/material.dart';

/// Màu + icon theo trạng thái của một validation assignment.
(Color, IconData) validationStatusStyle(String status) => switch (status) {
      'Assigned' => (Colors.orange, Icons.assignment_ind),
      'Scheduled' => (Colors.blue, Icons.event_available),
      'Verified' => (Colors.green, Icons.verified),
      'Rejected' => (Colors.red, Icons.cancel),
      _ => (Colors.grey, Icons.event),
    };

/// Badge trạng thái (icon + chữ trên nền màu nhạt).
class ValidationStatusBadge extends StatelessWidget {
  final String status;

  const ValidationStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, icon) = validationStatusStyle(status);
    return Container(
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
                  fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Badge độ ưu tiên (High/Medium/Low).
class ValidationPriorityBadge extends StatelessWidget {
  final String priority;

  const ValidationPriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
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
}

/// dd/MM/yyyy (giờ local).
String formatValidationDate(DateTime dt) {
  final l = dt.toLocal();
  return '${l.day.toString().padLeft(2, '0')}/${l.month.toString().padLeft(2, '0')}/${l.year}';
}

/// dd/MM/yyyy  HH:mm (giờ local).
String formatValidationDateTime(DateTime dt) {
  final l = dt.toLocal();
  return '${formatValidationDate(dt)}'
      '  ${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
}
