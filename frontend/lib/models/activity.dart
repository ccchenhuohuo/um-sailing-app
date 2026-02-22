class Activity {
  final int id;
  final String title;
  final String? description;
  final String? location;
  final DateTime startTime;
  final DateTime endTime;
  final int maxParticipants;
  final int creatorId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Activity({
    required this.id,
    required this.title,
    this.description,
    this.location,
    required this.startTime,
    required this.endTime,
    required this.maxParticipants,
    required this.creatorId,
    required this.createdAt,
    this.updatedAt,
  });

  /// 安全解析 DateTime 类型
  static DateTime _parseDateTime(dynamic value, {bool required = false}) {
    if (value == null) return required ? DateTime.now() : DateTime(1970);
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      location: json['location'] as String?,
      startTime: _parseDateTime(json['start_time'], required: true),
      endTime: _parseDateTime(json['end_time'], required: true),
      maxParticipants: json['max_participants'] as int? ?? 0,
      creatorId: json['creator_id'] as int? ?? 0,
      createdAt: _parseDateTime(json['created_at'], required: true),
      updatedAt: json['updated_at'] != null
          ? _parseDateTime(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'max_participants': maxParticipants,
      'creator_id': creatorId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
