class Stats {
  final int totalUsers;
  final int totalActivities;
  final int totalBoats;
  final double totalRevenue;
  final double monthlyRevenue;
  final int activeUsers;
  final List<BoatUsage> boatUsage;
  final List<RevenueHistory> revenueHistory;
  final List<ActivityParticipation> activityParticipation;

  Stats({
    required this.totalUsers,
    required this.totalActivities,
    required this.totalBoats,
    required this.totalRevenue,
    required this.monthlyRevenue,
    required this.activeUsers,
    required this.boatUsage,
    required this.revenueHistory,
    required this.activityParticipation,
  });

  /// 安全解析 double 类型
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      totalUsers: json['total_users'] as int? ?? 0,
      totalActivities: json['total_activities'] as int? ?? 0,
      totalBoats: json['total_boats'] as int? ?? 0,
      totalRevenue: _parseDouble(json['total_revenue']),
      monthlyRevenue: _parseDouble(json['monthly_revenue']),
      activeUsers: json['active_users'] as int? ?? 0,
      boatUsage: (json['boat_usage'] as List?)
          ?.map((e) => BoatUsage.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      revenueHistory: (json['revenue_history'] as List?)
          ?.map((e) => RevenueHistory.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      activityParticipation: (json['activity_participation'] as List?)
          ?.map((e) => ActivityParticipation.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class BoatUsage {
  final int boatId;
  final String boatName;
  final int rentalCount;

  BoatUsage({
    required this.boatId,
    required this.boatName,
    required this.rentalCount,
  });

  factory BoatUsage.fromJson(Map<String, dynamic> json) {
    return BoatUsage(
      boatId: json['boat_id'] as int? ?? 0,
      boatName: json['boat_name'] as String? ?? '',
      rentalCount: json['rental_count'] as int? ?? 0,
    );
  }
}

class RevenueHistory {
  final String month;
  final double revenue;

  RevenueHistory({required this.month, required this.revenue});

  /// 安全解析 double 类型
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory RevenueHistory.fromJson(Map<String, dynamic> json) {
    return RevenueHistory(
      month: json['month'] as String? ?? '',
      revenue: _parseDouble(json['revenue']),
    );
  }
}

class ActivityParticipation {
  final String month;
  final int count;

  ActivityParticipation({required this.month, required this.count});

  factory ActivityParticipation.fromJson(Map<String, dynamic> json) {
    return ActivityParticipation(
      month: json['month'] as String? ?? '',
      count: json['count'] as int? ?? 0,
    );
  }
}
