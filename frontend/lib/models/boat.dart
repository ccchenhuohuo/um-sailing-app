enum BoatStatus {
  available,
  rented,
  maintenance;

  /// 安全解析 BoatStatus
  static BoatStatus fromString(String? value) {
    if (value == null) return BoatStatus.available;
    return values.firstWhere(
      (e) => e.name == value,
      orElse: () => BoatStatus.available,
    );
  }
}

class Boat {
  final int id;
  final String name;
  final String? type;
  final BoatStatus status;
  final double rentalPrice;
  final String? imageUrl;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Boat({
    required this.id,
    required this.name,
    this.type,
    required this.status,
    required this.rentalPrice,
    this.imageUrl,
    this.description,
    required this.createdAt,
    this.updatedAt,
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
  static DateTime _parseDateTime(dynamic value, {bool required = false}) {
    if (value == null) return required ? DateTime.now() : DateTime(1970);
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  factory Boat.fromJson(Map<String, dynamic> json) {
    return Boat(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      type: json['type'] as String?,
      status: BoatStatus.fromString(json['status'] as String?),
      rentalPrice: _parseDouble(json['rental_price']),
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
      createdAt: _parseDateTime(json['created_at'], required: true),
      updatedAt: json['updated_at'] != null
          ? _parseDateTime(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'status': status.name,
      'rental_price': rentalPrice,
      'image_url': imageUrl,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
