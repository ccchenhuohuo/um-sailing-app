class Notice {
  final int id;
  final String title;
  final String content;
  final int? authorId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Notice({
    required this.id,
    required this.title,
    required this.content,
    this.authorId,
    required this.createdAt,
    this.updatedAt,
  });

  /// 安全解析 DateTime 类型
  static DateTime _parseDateTime(dynamic value, {bool required = false}) {
    if (value == null) return required ? DateTime.now() : DateTime(1970);
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      authorId: json['author_id'] as int?,
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
      'content': content,
      'author_id': authorId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
