class User {
  final int id;
  final String username;
  final String email;
  final String? phone;
  final String role;
  final double balance;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.phone,
    required this.role,
    required this.balance,
    required this.createdAt,
  });

  /// 安全解析 double 类型
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// 安全解析 DateTime 类型
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'user',
      balance: _parseDouble(json['balance']),
      createdAt: _parseDateTime(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'role': role,
      'balance': balance,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isAdmin => role == 'admin';
}
