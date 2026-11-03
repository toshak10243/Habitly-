import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/storage/local_storage.dart';
import '../core/utils/date_utils.dart';
import '../models/habit.dart';
import '../models/habit_completion.dart';

class HabitProvider extends ChangeNotifier {
  List<Habit> _habits = [];
  List<HabitCompletion> _completions = [];
  bool _isLoading = true;

  List<Habit> get habits => _habits;
  List<Habit> get activeHabits => _habits.where((h) => !h.isArchived).toList();
  List<Habit> get archivedHabits => _habits.where((h) => h.isArchived).toList();
  List<HabitCompletion> get completions => _completions;
  bool get isLoading => _isLoading;

  HabitProvider() {
    loadData();
  }

  /// Initialize and load saved habits and completions
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final habitsData = await LocalStorage.readJson(AppConstants.habitsFile);
      if (habitsData is List && habitsData.isNotEmpty) {
        _habits = habitsData
            .map((item) => Habit.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else {
        // Pre-populate realistic sample habits for university HCI showcase
        _habits = _getInitialSampleHabits();
        await _saveHabits();
      }

      final completionsData =
          await LocalStorage.readJson(AppConstants.completionsFile);
      if (completionsData is List && completionsData.isNotEmpty) {
        _completions = completionsData
            .map((item) =>
                HabitCompletion.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else {
        // Pre-populate sample historical completions for meaningful initial analytics
        _completions = _getInitialSampleCompletions(_habits);
        await _saveCompletions();
      }
    } catch (e) {
      debugPrint('Error loading habit data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveHabits() async {
    final list = _habits.map((h) => h.toJson()).toList();
    await LocalStorage.writeJson(AppConstants.habitsFile, list);
  }

  Future<void> _saveCompletions() async {
    final list = _completions.map((c) => c.toJson()).toList();
    await LocalStorage.writeJson(AppConstants.completionsFile, list);
  }

  /// Add a new habit
  Future<bool> addHabit(Habit habit) async {
    // Prevent exact duplicates with same name if already active
    final duplicate = _habits.any((h) =>
        !h.isArchived &&
        h.name.trim().toLowerCase() == habit.name.trim().toLowerCase());
    if (duplicate) return false;

    _habits.insert(0, habit);
    await _saveHabits();
    notifyListeners();
    return true;
  }

  /// Update an existing habit
  Future<bool> updateHabit(Habit habit) async {
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits[index] = habit;
      await _saveHabits();
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Delete a habit and its completions
  Future<void> deleteHabit(String habitId) async {
    _habits.removeWhere((h) => h.id == habitId);
    _completions.removeWhere((c) => c.habitId == habitId);
    await _saveHabits();
    await _saveCompletions();
    notifyListeners();
  }

  /// Archive or Unarchive a habit
  Future<void> toggleArchive(String habitId) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index != -1) {
      final h = _habits[index];
      _habits[index] = h.copyWith(isArchived: !h.isArchived);
      await _saveHabits();
      notifyListeners();
    }
  }

  /// Check if a habit is completed on a specific date (YYYY-MM-DD)
  bool isHabitCompleted(String habitId, String dateStr) {
    return _completions.any(
        (c) => c.habitId == habitId && c.date == dateStr && c.completed);
  }

  /// Toggle completion of a habit on a specific date (defaults to today)
  Future<bool> toggleCompletion(String habitId, [DateTime? date]) async {
    final targetDate = date ?? DateTime.now();
    final dateStr = DateUtilsCustom.toDateString(targetDate);

    final existingIndex = _completions
        .indexWhere((c) => c.habitId == habitId && c.date == dateStr);

    bool newlyCompleted = false;
    if (existingIndex != -1) {
      // Toggle off (undo)
      _completions.removeAt(existingIndex);
      newlyCompleted = false;
    } else {
      // Mark as complete
      _completions.add(HabitCompletion(
        habitId: habitId,
        date: dateStr,
        completed: true,
        completedAt: DateTime.now(),
      ));
      newlyCompleted = true;
    }

    await _saveCompletions();
    notifyListeners();
    return newlyCompleted;
  }

  /// Get list of habits scheduled for a given date
  List<Habit> getHabitsForDate(DateTime date) {
    return activeHabits.where((h) => h.isActiveOnDate(date)).toList();
  }

  /// Get completion count for a date
  int getCompletedCountForDate(DateTime date) {
    final dateStr = DateUtilsCustom.toDateString(date);
    final scheduled = getHabitsForDate(date);
    int count = 0;
    for (final habit in scheduled) {
      if (isHabitCompleted(habit.id, dateStr)) {
        count++;
      }
    }
    return count;
  }

  /// Calculate completion rate (0.0 to 1.0) for a date
  double getCompletionRateForDate(DateTime date) {
    final scheduled = getHabitsForDate(date);
    if (scheduled.isEmpty) return 0.0;
    final completed = getCompletedCountForDate(date);
    return completed / scheduled.length;
  }

  /// Calculate current streak for a habit (consecutive scheduled days)
  int calculateCurrentStreak(String habitId) {
    final habit = _habits.firstWhere((h) => h.id == habitId,
        orElse: () => _habits.first);
    final today = DateUtilsCustom.normalize(DateTime.now());
    int streak = 0;

    // Check today: if scheduled and completed, streak includes today.
    // If not completed today yet, check if yesterday was completed.
    DateTime checkDate = today;
    final todayStr = DateUtilsCustom.toDateString(today);
    final isDoneToday = isHabitCompleted(habitId, todayStr);

    if (isDoneToday) {
      streak++;
      checkDate = today.subtract(const Duration(days: 1));
    } else {
      // If not done today, streak starts checking from yesterday
      checkDate = today.subtract(const Duration(days: 1));
    }

    // Walk backwards in time
    while (true) {
      final normStart = DateUtilsCustom.normalize(habit.startDate);
      if (checkDate.isBefore(normStart)) break;

      // If habit was scheduled on checkDate:
      if (habit.isScheduledForWeekday(checkDate.weekday)) {
        final dateStr = DateUtilsCustom.toDateString(checkDate);
        if (isHabitCompleted(habitId, dateStr)) {
          streak++;
        } else {
          // Missed scheduled day: streak ends
          break;
        }
      }
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Calculate longest streak for a habit
  int calculateLongestStreak(String habitId) {
    final habit = _habits.firstWhere((h) => h.id == habitId,
        orElse: () => _habits.first);
    int maxStreak = 0;
    int currentRun = 0;

    final normStart = DateUtilsCustom.normalize(habit.startDate);
    final today = DateUtilsCustom.normalize(DateTime.now());

    DateTime iter = normStart;
    while (!iter.isAfter(today)) {
      if (habit.isScheduledForWeekday(iter.weekday)) {
        final dateStr = DateUtilsCustom.toDateString(iter);
        if (isHabitCompleted(habitId, dateStr)) {
          currentRun++;
          if (currentRun > maxStreak) {
            maxStreak = currentRun;
          }
        } else {
          currentRun = 0;
        }
      }
      iter = iter.add(const Duration(days: 1));
    }

    return maxStreak;
  }

  /// Total completions for a specific habit
  int getTotalCompletions(String habitId) {
    return _completions.where((c) => c.habitId == habitId && c.completed).length;
  }

  /// Global current streak (days with at least 1 habit completed or all scheduled completed)
  int calculateGlobalStreak() {
    final today = DateUtilsCustom.normalize(DateTime.now());
    int streak = 0;

    DateTime checkDate = today;
    final todayCount = getCompletedCountForDate(today);
    if (todayCount > 0) {
      streak++;
      checkDate = today.subtract(const Duration(days: 1));
    } else {
      checkDate = today.subtract(const Duration(days: 1));
    }

    while (true) {
      final scheduled = getHabitsForDate(checkDate);
      if (scheduled.isEmpty) {
        // If nothing scheduled on that day, don't break streak, continue backwards
        checkDate = checkDate.subtract(const Duration(days: 1));
        if (today.difference(checkDate).inDays > 120) break;
        continue;
      }

      final count = getCompletedCountForDate(checkDate);
      if (count > 0) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Reset all habit data
  Future<void> resetAllData() async {
    _habits.clear();
    _completions.clear();
    await LocalStorage.deleteFile(AppConstants.habitsFile);
    await LocalStorage.deleteFile(AppConstants.completionsFile);
    notifyListeners();
  }

  // Initial realistic sample data
  List<Habit> _getInitialSampleHabits() {
    final now = DateTime.now();
    return [
      Habit(
        id: 'h1',
        name: 'Morning Hydration',
        description: 'Drink 500ml water right after waking up.',
        category: 'Health',
        iconKey: 'water_drop',
        colorValue: 0xFF06B6D4,
        createdAt: now.subtract(const Duration(days: 14)),
        startDate: now.subtract(const Duration(days: 14)),
        frequency: 'Every Day',
        reminderTime: '07:00 AM',
      ),
      Habit(
        id: 'h2',
        name: '30-Min Cardio / Gym',
        description: 'Engage in moderate-to-vigorous exercise or brisk walking.',
        category: 'Fitness',
        iconKey: 'fitness_center',
        colorValue: 0xFFEF4444,
        createdAt: now.subtract(const Duration(days: 12)),
        startDate: now.subtract(const Duration(days: 12)),
        frequency: 'Specific Days',
        selectedWeekdays: [1, 2, 3, 4, 5],
        reminderTime: '06:30 PM',
      ),
      Habit(
        id: 'h3',
        name: 'Read 15 Pages',
        description: 'Read non-fiction, design books, or personal development literature.',
        category: 'Learning',
        iconKey: 'menu_book',
        colorValue: 0xFF4F46E5,
        createdAt: now.subtract(const Duration(days: 10)),
        startDate: now.subtract(const Duration(days: 10)),
        frequency: 'Every Day',
        reminderTime: '09:00 PM',
      ),
      Habit(
        id: 'h4',
        name: 'Mindful Meditation',
        description: '10 minutes of box breathing and silent reflection.',
        category: 'Mindfulness',
        iconKey: 'self_improvement',
        colorValue: 0xFF10B981,
        createdAt: now.subtract(const Duration(days: 8)),
        startDate: now.subtract(const Duration(days: 8)),
        frequency: 'Every Day',
        reminderTime: '07:30 AM',
      ),
      Habit(
        id: 'h5',
        name: 'Deep Work Session',
        description: '90 minutes of undistracted coding & HCI project focus.',
        category: 'Productivity',
        iconKey: 'code',
        colorValue: 0xFFF59E0B,
        createdAt: now.subtract(const Duration(days: 7)),
        startDate: now.subtract(const Duration(days: 7)),
        frequency: 'Specific Days',
        selectedWeekdays: [1, 2, 3, 4, 5],
        reminderTime: '10:00 AM',
      ),
    ];
  }

  List<HabitCompletion> _getInitialSampleCompletions(List<Habit> sampleHabits) {
    final list = <HabitCompletion>[];
    final today = DateUtilsCustom.normalize(DateTime.now());

    // Generate past 10 days of completions for visual richness
    for (int i = 1; i <= 10; i++) {
      final date = today.subtract(Duration(days: i));
      final dateStr = DateUtilsCustom.toDateString(date);

      for (final habit in sampleHabits) {
        if (habit.isActiveOnDate(date)) {
          // Provide realistic completion pattern
          if (habit.id == 'h1' || (habit.id == 'h3' && i % 4 != 0) || (habit.id == 'h4' && i % 2 == 0) || (habit.id == 'h2' && i % 3 != 0)) {
            list.add(HabitCompletion(
              habitId: habit.id,
              date: dateStr,
              completed: true,
              completedAt: date.add(const Duration(hours: 10)),
            ));
          }
        }
      }
    }

    return list;
  }
}

