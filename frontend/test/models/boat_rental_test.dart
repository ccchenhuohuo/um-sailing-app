import 'package:flutter_test/flutter_test.dart';
import 'package:uma_sailing_app/models/boat_rental.dart';

void main() {
  group('BoatRental Model Tests', () {
    test('fromJson creates BoatRental correctly', () {
      final json = {
        'id': 1,
        'boat_id': 10,
        'user_id': 5,
        'rental_time': '2024-06-01T10:00:00',
        'return_time': '2024-06-01T12:00:00',
        'status': 'returned',
        'rental_fee': 50.0,
      };

      final rental = BoatRental.fromJson(json);

      expect(rental.id, 1);
      expect(rental.boatId, 10);
      expect(rental.userId, 5);
      expect(rental.rentalTime, DateTime.parse('2024-06-01T10:00:00'));
      expect(rental.returnTime, DateTime.parse('2024-06-01T12:00:00'));
      expect(rental.status, 'returned');
      expect(rental.rentalFee, 50.0);
      expect(rental.boat, isNull);
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'id': 1,
        'boat_id': 10,
        'user_id': 5,
        'rental_time': '2024-06-01T10:00:00',
        'return_time': null,
        'status': null,
        'rental_fee': null,
        'boat': null,
      };

      final rental = BoatRental.fromJson(json);

      expect(rental.returnTime, isNull);
      expect(rental.status, 'active');
      expect(rental.rentalFee, isNull);
      expect(rental.boat, isNull);
    });

    test('fromJson parses nested boat', () {
      final json = {
        'id': 1,
        'boat_id': 10,
        'user_id': 5,
        'rental_time': '2024-06-01T10:00:00',
        'status': 'active',
        'boat': {
          'id': 10,
          'name': 'Sunfish',
          'type': 'sailboat',
          'status': 'rented',
          'rental_price': 25.0,
          'image_url': null,
          'description': 'A small sailboat',
          'created_at': '2024-01-01T00:00:00',
          'updated_at': null,
        },
      };

      final rental = BoatRental.fromJson(json);

      expect(rental.boat, isNotNull);
      expect(rental.boat!.name, 'Sunfish');
      expect(rental.boat!.rentalPrice, 25.0);
    });

    test('fromJson handles rental_fee as int', () {
      final json = {
        'id': 1,
        'boat_id': 10,
        'user_id': 5,
        'rental_time': '2024-06-01T10:00:00',
        'status': 'returned',
        'rental_fee': 50,
      };

      final rental = BoatRental.fromJson(json);
      expect(rental.rentalFee, 50.0);
    });

    test('toJson converts BoatRental correctly', () {
      final rental = BoatRental(
        id: 1,
        boatId: 10,
        userId: 5,
        rentalTime: DateTime.parse('2024-06-01T10:00:00'),
        returnTime: DateTime.parse('2024-06-01T12:00:00'),
        status: 'returned',
        rentalFee: 50.0,
      );

      final json = rental.toJson();

      expect(json['id'], 1);
      expect(json['boat_id'], 10);
      expect(json['user_id'], 5);
      expect(json['status'], 'returned');
      expect(json['rental_fee'], 50.0);
    });

    group('isActive', () {
      test('returns true when status is active', () {
        final rental = BoatRental(
          id: 1,
          boatId: 10,
          userId: 5,
          rentalTime: DateTime.now(),
          status: 'active',
        );

        expect(rental.isActive, true);
      });

      test('returns false when status is returned', () {
        final rental = BoatRental(
          id: 1,
          boatId: 10,
          userId: 5,
          rentalTime: DateTime.now(),
          status: 'returned',
        );

        expect(rental.isActive, false);
      });
    });

    group('statusText', () {
      test('returns 进行中 when active', () {
        final rental = BoatRental(
          id: 1,
          boatId: 10,
          userId: 5,
          rentalTime: DateTime.now(),
          status: 'active',
        );

        expect(rental.statusText, '进行中');
      });

      test('returns 已归还 when returned', () {
        final rental = BoatRental(
          id: 1,
          boatId: 10,
          userId: 5,
          rentalTime: DateTime.now(),
          status: 'returned',
        );

        expect(rental.statusText, '已归还');
      });
    });

    group('rentalHours', () {
      test('calculates hours correctly with return time', () {
        final rentalTime = DateTime(2024, 6, 1, 10, 0);
        final returnTime = DateTime(2024, 6, 1, 12, 0);

        final rental = BoatRental(
          id: 1,
          boatId: 10,
          userId: 5,
          rentalTime: rentalTime,
          returnTime: returnTime,
          status: 'returned',
        );

        expect(rental.rentalHours, 2.0);
      });

      test('calculates partial hours correctly', () {
        final rentalTime = DateTime(2024, 6, 1, 10, 0);
        final returnTime = DateTime(2024, 6, 1, 11, 30);

        final rental = BoatRental(
          id: 1,
          boatId: 10,
          userId: 5,
          rentalTime: rentalTime,
          returnTime: returnTime,
          status: 'returned',
        );

        expect(rental.rentalHours, 1.5);
      });

      test('uses current time when no return time', () {
        final rentalTime = DateTime.now().subtract(const Duration(hours: 3));

        final rental = BoatRental(
          id: 1,
          boatId: 10,
          userId: 5,
          rentalTime: rentalTime,
          status: 'active',
        );

        // Should be approximately 3 hours (allow small tolerance)
        expect(rental.rentalHours, closeTo(3.0, 0.1));
      });
    });
  });
}
