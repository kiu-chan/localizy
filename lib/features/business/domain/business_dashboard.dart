/// Một hoạt động gần đây trong nhóm doanh nghiệp.
class RecentActivity {
  final String type;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final String? actorName;

  RecentActivity({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    this.actorName,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      actorName: json['actorName'] as String?,
    );
  }
}

/// Tổng quan cho tab Dashboard của role Business.
class BusinessDashboard {
  final int totalLocations;
  final int subAccountCount;
  final List<RecentActivity> recentActivities;

  BusinessDashboard({
    required this.totalLocations,
    required this.subAccountCount,
    required this.recentActivities,
  });

  factory BusinessDashboard.fromJson(Map<String, dynamic> json) {
    final rawActivities = json['recentActivities'];
    final activities = rawActivities is List
        ? rawActivities
            .map((e) => RecentActivity.fromJson(e as Map<String, dynamic>))
            .toList()
        : <RecentActivity>[];
    return BusinessDashboard(
      totalLocations: (json['totalLocations'] ?? 0) as int,
      subAccountCount: (json['subAccountCount'] ?? 0) as int,
      recentActivities: activities,
    );
  }
}
