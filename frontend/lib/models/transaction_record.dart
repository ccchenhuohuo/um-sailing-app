/// 交易记录模型
/// type: "deposit" 充值, "payment" 消费
class TransactionRecord {
  final int id;
  final String type;
  final double amount;
  final String? description;
  final DateTime createdAt;

  TransactionRecord({
    required this.id,
    required this.type,
    required this.amount,
    this.description,
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

  factory TransactionRecord.fromJson(Map<String, dynamic> json) {
    return TransactionRecord(
      id: json['id'] as int? ?? 0,
      type: json['type'] as String? ?? 'payment',
      amount: _parseDouble(json['amount']),
      description: json['description'] as String?,
      createdAt: _parseDateTime(json['created_at']),
    );
  }

  /// 是否是充值
  bool get isDeposit => type == 'deposit';

  /// 是否是消费
  bool get isPayment => type == 'payment';
}
