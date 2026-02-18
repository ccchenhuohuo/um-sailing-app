import 'dart:convert';

enum BoatStatus {
  available,
  rented,
  maintenance;

  factory BoatStatus.fromString(String value) {
    return values.firstWhere((e) => e.name == value);
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

  factory Boat.fromJson(Map<String, dynamic> json) {
    return Boat(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      status: BoatStatus.fromString(json['status']),
      rentalPrice: double.parse(json['rental_price'].toString()),
      imageUrl: json['image_url'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
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
