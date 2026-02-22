import 'package:flutter_test/flutter_test.dart';
import 'package:uma_sailing_app/models/activity.dart';
import 'package:uma_sailing_app/models/activity_signup.dart';

void main() {
  group('ActivitySignup Model Tests', () {
    test('fromJson creates ActivitySignup correctly', () {
      final json = {
        'id': 1,
        'activity_id': 10,
        'user_id': 5,
        'signup_time': '2024-05-20T10:00:00',
        'checked_in': true,
      };

      final signup = ActivitySignup.fromJson(json);

      expect(signup.id, 1);
      expect(signup.activityId, 10);
      expect(signup.userId, 5);
      expect(signup.checkedIn, true);
      expect(signup.signupTime, DateTime.parse('2024-05-20T10:00:00'));
    });

    test('fromJson handles null checked_in', () {
      final json = {
        'id': 1,
        'activity_id': 10,
        'user_id': 5,
        'signup_time': '2024-05-20T10:00:00',
        'checked_in': null,
      };

      final signup = ActivitySignup.fromJson(json);

      expect(signup.checkedIn, false);
    });

    test('fromJson parses nested activity', () {
      final json = {
        'id': 1,
        'activity_id': 10,
        'user_id': 5,
        'signup_time': '2024-05-20T10:00:00',
        'checked_in': false,
        'activity': {
          'id': 10,
          'title': 'Test Activity',
          'description': 'Description',
          'location': 'Location',
          'start_time': '2024-06-01T10:00:00',
          'end_time': '2024-06-01T12:00:00',
          'max_participants': 20,
          'creator_id': 1,
          'created_at': '2024-05-01T10:00:00',
        },
      };

      final signup = ActivitySignup.fromJson(json);

      expect(signup.activity, isNotNull);
      expect(signup.activity!.id, 10);
      expect(signup.activity!.title, 'Test Activity');
    });

    test('toJson converts ActivitySignup correctly', () {
      final signup = ActivitySignup(
        id: 1,
        activityId: 10,
        userId: 5,
        signupTime: DateTime.parse('2024-05-20T10:00:00'),
        checkedIn: true,
      );

      final json = signup.toJson();

      expect(json['id'], 1);
      expect(json['activity_id'], 10);
      expect(json['user_id'], 5);
      expect(json['checked_in'], true);
    });

    group('activityStatus', () {
      test('returns 未开始 when activity not started', () {
        final futureActivity = ActivitySignup(
          id: 1,
          activityId: 10,
          userId: 5,
          signupTime: DateTime.now(),
          checkedIn: false,
          activity: Activity(
            id: 10,
            title: 'Test',
            startTime: DateTime.now().add(const Duration(days: 1)),
            endTime: DateTime.now().add(const Duration(days: 2)),
            maxParticipants: 20,
            creatorId: 1,
            createdAt: DateTime.now(),
          ),
        );

        expect(futureActivity.activityStatus, '未开始');
      });

      test('returns 进行中 when activity is ongoing', () {
        final ongoingActivity = ActivitySignup(
          id: 1,
          activityId: 10,
          userId: 5,
          signupTime: DateTime.now(),
          checkedIn: false,
          activity: Activity(
            id: 10,
            title: 'Test',
            startTime: DateTime.now().subtract(const Duration(hours: 1)),
            endTime: DateTime.now().add(const Duration(hours: 1)),
            maxParticipants: 20,
            creatorId: 1,
            createdAt: DateTime.now(),
          ),
        );

        expect(ongoingActivity.activityStatus, '进行中');
      });

      test('returns 已结束 when activity ended', () {
        final endedActivity = ActivitySignup(
          id: 1,
          activityId: 10,
          userId: 5,
          signupTime: DateTime.now(),
          checkedIn: false,
          activity: Activity(
            id: 10,
            title: 'Test',
            startTime: DateTime.now().subtract(const Duration(hours: 2)),
            endTime: DateTime.now().subtract(const Duration(hours: 1)),
            maxParticipants: 20,
            creatorId: 1,
            createdAt: DateTime.now(),
          ),
        );

        expect(endedActivity.activityStatus, '已结束');
      });

      test('returns 未知 when activity is null', () {
        final signup = ActivitySignup(
          id: 1,
          activityId: 10,
          userId: 5,
          signupTime: DateTime.now(),
          checkedIn: false,
        );

        expect(signup.activityStatus, '未知');
      });
    });

    group('canCheckin', () {
      test('returns true when activity ongoing and not checked in', () {
        final signup = ActivitySignup(
          id: 1,
          activityId: 10,
          userId: 5,
          signupTime: DateTime.now(),
          checkedIn: false,
          activity: Activity(
            id: 10,
            title: 'Test',
            startTime: DateTime.now().subtract(const Duration(hours: 1)),
            endTime: DateTime.now().add(const Duration(hours: 1)),
            maxParticipants: 20,
            creatorId: 1,
            createdAt: DateTime.now(),
          ),
        );

        expect(signup.canCheckin, true);
      });

      test('returns false when already checked in', () {
        final signup = ActivitySignup(
          id: 1,
          activityId: 10,
          userId: 5,
          signupTime: DateTime.now(),
          checkedIn: true,
          activity: Activity(
            id: 10,
            title: 'Test',
            startTime: DateTime.now().subtract(const Duration(hours: 1)),
            endTime: DateTime.now().add(const Duration(hours: 1)),
            maxParticipants: 20,
            creatorId: 1,
            createdAt: DateTime.now(),
          ),
        );

        expect(signup.canCheckin, false);
      });

      test('returns false when activity not ongoing', () {
        final signup = ActivitySignup(
          id: 1,
          activityId: 10,
          userId: 5,
          signupTime: DateTime.now(),
          checkedIn: false,
          activity: Activity(
            id: 10,
            title: 'Test',
            startTime: DateTime.now().add(const Duration(days: 1)),
            endTime: DateTime.now().add(const Duration(days: 2)),
            maxParticipants: 20,
            creatorId: 1,
            createdAt: DateTime.now(),
          ),
        );

        expect(signup.canCheckin, false);
      });

      test('returns false when activity is null', () {
        final signup = ActivitySignup(
          id: 1,
          activityId: 10,
          userId: 5,
          signupTime: DateTime.now(),
          checkedIn: false,
        );

        expect(signup.canCheckin, false);
      });

      test('returns false when activity ended and not checked in', () {
        final signup = ActivitySignup(
          id: 1,
          activityId: 10,
          userId: 5,
          signupTime: DateTime.now(),
          checkedIn: false,
          activity: Activity(
            id: 10,
            title: 'Test',
            startTime: DateTime.now().subtract(const Duration(hours: 3)),
            endTime: DateTime.now().subtract(const Duration(hours: 1)),
            maxParticipants: 20,
            creatorId: 1,
            createdAt: DateTime.now(),
          ),
        );

        expect(signup.canCheckin, false);
      });
    });
  });
}
