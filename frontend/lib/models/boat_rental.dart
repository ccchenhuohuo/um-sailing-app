import 'boat.dart';

class BoatRental {
  final int id;
  final int boatId;
  final int userId;
  final DateTime rentalTime;
  final DateTime? returnTime;
  final String status; // "active" 或 "returned"
  final Boat? boat;
  final double? rentalFee;

  BoatRental({
    required this.id,
    required this.boatId,
    required this.userId,
    required this.rentalTime,
    this.returnTime,
    required this.status,
    this.boat,
    this.rentalFee,
  });

  /// 安全解析 DateTime 类型
  static DateTime _parseDateTime(dynamic value, {bool required = false}) {
    if (value == null) return required ? DateTime.now() : DateTime(1970);
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  /// 安全解析 double 类型
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  factory BoatRental.fromJson(Map<String, dynamic> json) {
    return BoatRental(
      id: json['id'] as int? ?? 0,
      boatId: json['boat_id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      rentalTime: _parseDateTime(json['rental_time'], required: true),
      returnTime: json['return_time'] != null
          ? _parseDateTime(json['return_time'])
          : null,
      status: (json['status'] as String?) ?? 'active',
      boat: json['boat'] != null
          ? Boat.fromJson(json['boat'] as Map<String, dynamic>)
          : null,
      rentalFee: _parseDouble(json['rental_fee']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'boat_id': boatId,
      'user_id': userId,
      'rental_time': rentalTime.toIso8601String(),
      'return_time': returnTime?.toIso8601String(),
      'status': status,
      'boat': boat?.toJson(),
      'rental_fee': rentalFee,
    };
  }

  /// 是否正在租借中
  bool get isActive => status == 'active';

  /// 获取状态显示文本
  String get statusText => isActive ? '进行中' : '已归还';

  /// 计算租借时长（小时）
  double get rentalHours {
    final endTime = returnTime ?? DateTime.now();
    return endTime.difference(rentalTime).inMinutes / 60.0;
  }
}
