import 'package:flutter_test/flutter_test.dart';
import 'package:habitly/models/habit.dart';
import 'package:habitly/models/habit_completion.dart';
import 'package:habitly/models/user_profile.dart';
import 'package:habitly/core/utils/date_utils.dart';

void main() {
  group('Habitly Model & Logic Unit Tests', () {
    test('Habit model serialization and deserialization', () {
      final now = DateTime.now();
      final habit = Habit(
        id: 'test-1',
        name: 'Morning Hydration',
        description: 'Drink 500ml water',
        category: 'Health',
        iconKey: 'water_drop',
        colorValue: 0xFF06B6D4,
        createdAt: now,
        startDate: now,
        frequency: 'Every Day',
        reminderTime: '08:00 AM',
      );

      final json = habit.toJson();
      final fromJson = Habit.fromJson(json);

      expect(fromJson.id, 'test-1');
      expect(fromJson.name, 'Morning Hydration');
      expect(fromJson.category, 'Health');
      expect(fromJson.frequency, 'Every Day');
      expect(fromJson.isScheduledForWeekday(1), true);
      expect(fromJson.isScheduledForWeekday(7), true);
    });

    test('Habit specific weekdays scheduling', () {
      final now = DateTime.now();
      final habit = Habit(
        id: 'test-2',
        name: 'Gym Workout',
        category: 'Fitness',
        iconKey: 'fitness_center',
        colorValue: 0xFFEF4444,
        createdAt: now,
        startDate: now,
        frequency: 'Specific Days',
        selectedWeekdays: [1, 3, 5], // Mon, Wed, Fri
      );

      expect(habit.isScheduledForWeekday(1), true); // Mon
      expect(habit.isScheduledForWeekday(2), false); // Tue
      expect(habit.isScheduledForWeekday(3), true); // Wed
      expect(habit.isScheduledForWeekday(7), false); // Sun
    });

    test('DateUtils formatting & parsing integrity', () {
      final date = DateTime(2026, 11, 3);
      final dateStr = DateUtilsCustom.toDateString(date);
      expect(dateStr, '2026-11-03');

      final parsed = DateUtilsCustom.parseDate(dateStr);
      expect(parsed.year, 2026);
      expect(parsed.month, 11);
      expect(parsed.day, 3);

      expect(DateUtilsCustom.isSameDay(date, parsed), true);
    });

    test('HabitCompletion model test', () {
      final completion = HabitCompletion(
        habitId: 'test-1',
        date: '2026-11-03',
        completed: true,
        completedAt: DateTime.now(),
      );

      final json = completion.toJson();
      final fromJson = HabitCompletion.fromJson(json);
      expect(fromJson.habitId, 'test-1');
      expect(fromJson.date, '2026-11-03');
      expect(fromJson.completed, true);
    });

    test('UserProfile model test', () {
      final profile = UserProfile(
        name: 'Toshak Sharma',
        bio: 'Building habits every day',
        hasCompletedOnboarding: true,
      );

      final json = profile.toJson();
      final fromJson = UserProfile.fromJson(json);
      expect(fromJson.name, 'Toshak Sharma');
      expect(fromJson.hasCompletedOnboarding, true);
    });
  });
}
