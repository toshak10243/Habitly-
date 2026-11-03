import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'HABITLY';
  static const String appTitle = 'Habitly – Daily Habit & Progress Tracker';
  static const String appTagline = 'Build Better Habits. Become Better Every Day.';
  static const String appVersion = '1.0.0';

  // Storage filenames
  static const String habitsFile = 'habitly_habits.json';
  static const String completionsFile = 'habitly_completions.json';
  static const String profileFile = 'habitly_profile.json';
  static const String settingsFile = 'habitly_settings.json';

  // Categories
  static const List<String> categories = [
    'Health',
    'Fitness',
    'Learning',
    'Productivity',
    'Mindfulness',
    'Personal',
  ];

  // Frequency types
  static const String freqEveryday = 'Every Day';
  static const String freqWeekdays = 'Specific Days';

  // Weekday names
  static const List<String> weekDayShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const List<String> weekDayFull = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  // Available icon keys mapped to IconData
  static const Map<String, IconData> habitIcons = {
    'fitness_center': Icons.fitness_center_rounded,
    'water_drop': Icons.water_drop_rounded,
    'menu_book': Icons.menu_book_rounded,
    'self_improvement': Icons.self_improvement_rounded,
    'bedtime': Icons.bedtime_rounded,
    'directions_run': Icons.directions_run_rounded,
    'code': Icons.code_rounded,
    'psychology': Icons.psychology_rounded,
    'apple': Icons.apple_rounded,
    'spa': Icons.spa_rounded,
    'palette': Icons.palette_rounded,
    'music_note': Icons.music_note_rounded,
    'timer': Icons.timer_rounded,
    'edit_note': Icons.edit_note_rounded,
    'wb_sunny': Icons.wb_sunny_rounded,
    'local_cafe': Icons.local_cafe_rounded,
  };

  // Available color options (hex values)
  static const List<int> colorOptions = [
    0xFF4F46E5, // Indigo (Primary)
    0xFF06B6D4, // Cyan
    0xFF10B981, // Mint / Emerald
    0xFFF59E0B, // Amber
    0xFFEF4444, // Rose Red
    0xFF8B5CF6, // Purple
    0xFFEC4899, // Pink
    0xFF3B82F6, // Blue
    0xFF14B8A6, // Teal
    0xFFF97316, // Orange
  ];
}

