class Post {
  final int id;
  final int userId;
  final String? authorName;
  final String title;
  final String content;
  final int? tagId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Post({
    required this.id,
    required this.userId,
    this.authorName,
    required this.title,
    required this.content,
    this.tagId,
    required this.createdAt,
    this.updatedAt,
  });

  /// 安全解析 DateTime 类型
  static DateTime _parseDateTime(dynamic value, {bool required = false}) {
    if (value == null) return required ? DateTime.now() : DateTime(1970);
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      authorName: json['author_name'] as String? ??
          (json['user']?['username'] as String? ?? '匿名用户'),
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      tagId: json['tag_id'] as int?,
      createdAt: _parseDateTime(json['created_at'], required: true),
      updatedAt: json['updated_at'] != null
          ? _parseDateTime(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'author_name': authorName,
      'title': title,
      'content': content,
      'tag_id': tagId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class Comment {
  final int id;
  final int postId;
  final int userId;
  final String content;
  final DateTime createdAt;
  final String? authorName;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.authorName,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int? ?? 0,
      postId: json['post_id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      content: json['content'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      authorName: json['author_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Tag {
  final int id;
  final String name;

  Tag({
    required this.id,
    required this.name,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
