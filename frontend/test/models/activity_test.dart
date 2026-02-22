import 'package:flutter_test/flutter_test.dart';
import 'package:uma_sailing_app/models/activity.dart';

void main() {
  group('Activity Model Tests', () {
    test('fromJson creates Activity correctly', () {
      final json = {
        'id': 1,
        'title': 'Test Activity',
        'description': 'Test Description',
        'location': 'Test Location',
        'start_time': '2024-06-01T10:00:00',
        'end_time': '2024-06-01T12:00:00',
        'max_participants': 20,
        'creator_id': 1,
        'created_at': '2024-05-01T10:00:00',
        'updated_at': null,
      };

      final activity = Activity.fromJson(json);

      expect(activity.id, 1);
      expect(activity.title, 'Test Activity');
      expect(activity.description, 'Test Description');
      expect(activity.location, 'Test Location');
      expect(activity.startTime, DateTime.parse('2024-06-01T10:00:00'));
      expect(activity.endTime, DateTime.parse('2024-06-01T12:00:00'));
      expect(activity.maxParticipants, 20);
      expect(activity.creatorId, 1);
    });

    test('toJson converts Activity correctly', () {
      final activity = Activity(
        id: 1,
        title: 'Test Activity',
        description: 'Test Description',
        location: 'Test Location',
        startTime: DateTime.parse('2024-06-01T10:00:00'),
        endTime: DateTime.parse('2024-06-01T12:00:00'),
        maxParticipants: 20,
        creatorId: 1,
        createdAt: DateTime.parse('2024-05-01T10:00:00'),
      );

      final json = activity.toJson();

      expect(json['id'], 1);
      expect(json['title'], 'Test Activity');
      expect(json['description'], 'Test Description');
      expect(json['location'], 'Test Location');
      expect(json['max_participants'], 20);
    });

    test('handles null optional fields', () {
      final json = {
        'id': 1,
        'title': 'Test Activity',
        'description': null,
        'location': null,
        'start_time': '2024-06-01T10:00:00',
        'end_time': '2024-06-01T12:00:00',
        'max_participants': 0,
        'creator_id': 1,
        'created_at': '2024-05-01T10:00:00',
        'updated_at': null,
      };

      final activity = Activity.fromJson(json);

      expect(activity.description, isNull);
      expect(activity.location, isNull);
      expect(activity.maxParticipants, 0);
    });
  });
}
