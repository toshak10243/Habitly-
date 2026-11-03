class HabitCompletion {
  final String habitId;
  final String date; // YYYY-MM-DD
  final bool completed;
  final DateTime completedAt;

  HabitCompletion({
    required this.habitId,
    required this.date,
    this.completed = true,
    required this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'habitId': habitId,
      'date': date,
      'completed': completed,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory HabitCompletion.fromJson(Map<String, dynamic> json) {
    return HabitCompletion(
      habitId: json['habitId'] as String,
      date: json['date'] as String,
      completed: (json['completed'] as bool?) ?? true,
      completedAt: DateTime.parse(json['completedAt'] as String),
    );
  }
}

