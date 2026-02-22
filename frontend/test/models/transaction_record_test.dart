import 'package:flutter_test/flutter_test.dart';
import 'package:uma_sailing_app/models/transaction_record.dart';

void main() {
  group('TransactionRecord Model Tests', () {
    test('fromJson creates TransactionRecord correctly', () {
      final json = {
        'id': 1,
        'type': 'deposit',
        'amount': 100.0,
        'description': '会员充值',
        'created_at': '2024-06-01T10:00:00',
      };

      final record = TransactionRecord.fromJson(json);

      expect(record.id, 1);
      expect(record.type, 'deposit');
      expect(record.amount, 100.0);
      expect(record.description, '会员充值');
      expect(record.createdAt, DateTime.parse('2024-06-01T10:00:00'));
    });

    test('fromJson handles null description', () {
      final json = {
        'id': 1,
        'type': 'payment',
        'amount': 50.0,
        'description': null,
        'created_at': '2024-06-01T10:00:00',
      };

      final record = TransactionRecord.fromJson(json);

      expect(record.description, isNull);
    });

    test('fromJson handles amount as int', () {
      final json = {
        'id': 1,
        'type': 'deposit',
        'amount': 100,
        'created_at': '2024-06-01T10:00:00',
      };

      final record = TransactionRecord.fromJson(json);

      expect(record.amount, 100.0);
    });

    test('fromJson handles amount as string', () {
      final json = {
        'id': 1,
        'type': 'deposit',
        'amount': '100.50',
        'created_at': '2024-06-01T10:00:00',
      };

      final record = TransactionRecord.fromJson(json);

      expect(record.amount, 100.50);
    });

    group('isDeposit', () {
      test('returns true for deposit type', () {
        final record = TransactionRecord(
          id: 1,
          type: 'deposit',
          amount: 100.0,
          createdAt: DateTime.now(),
        );

        expect(record.isDeposit, true);
        expect(record.isPayment, false);
      });
    });

    group('isPayment', () {
      test('returns true for payment type', () {
        final record = TransactionRecord(
          id: 1,
          type: 'payment',
          amount: 50.0,
          createdAt: DateTime.now(),
        );

        expect(record.isPayment, true);
        expect(record.isDeposit, false);
      });
    });
  });
}
