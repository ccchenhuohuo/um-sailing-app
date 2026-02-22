import 'activity.dart';

class ActivitySignup {
  final int id;
  final int activityId;
  final int userId;
  final DateTime signupTime;
  final bool checkedIn;
  final Activity? activity;

  ActivitySignup({
    required this.id,
    required this.activityId,
    required this.userId,
    required this.signupTime,
    required this.checkedIn,
    this.activity,
  });

  /// 安全解析 DateTime 类型
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  factory ActivitySignup.fromJson(Map<String, dynamic> json) {
    return ActivitySignup(
      id: json['id'] as int? ?? 0,
      activityId: json['activity_id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      signupTime: _parseDateTime(json['signup_time']),
      checkedIn: (json['checked_in'] as bool?) ?? false,
      activity: json['activity'] != null
          ? Activity.fromJson(json['activity'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activity_id': activityId,
      'user_id': userId,
      'signup_time': signupTime.toIso8601String(),
      'checked_in': checkedIn,
      'activity': activity?.toJson(),
    };
  }

  /// 获取活动状态
  String get activityStatus {
    if (activity == null) return '未知';
    final now = DateTime.now();
    if (now.isBefore(activity!.startTime)) {
      return '未开始';
    } else if (now.isAfter(activity!.endTime)) {
      return '已结束';
    } else {
      return '进行中';
    }
  }

  /// 是否可以签到
  bool get canCheckin {
    if (activity == null) return false;
    final now = DateTime.now();
    return !checkedIn && now.isAfter(activity!.startTime) && now.isBefore(activity!.endTime);
  }
}
