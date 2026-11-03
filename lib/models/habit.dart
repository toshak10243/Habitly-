class Habit {
  final String id;
  final String name;
  final String description;
  final String category;
  final String iconKey;
  final int colorValue;
  final DateTime createdAt;
  final DateTime startDate;
  final String frequency; // 'Every Day' or 'Specific Days'
  final List<int> selectedWeekdays; // 1 = Monday ... 7 = Sunday
  final String reminderTime; // e.g. "08:00 AM" or empty
  final bool isArchived;

  Habit({
    required this.id,
    required this.name,
    this.description = '',
    required this.category,
    required this.iconKey,
    required this.colorValue,
    required this.createdAt,
    required this.startDate,
    this.frequency = 'Every Day',
    this.selectedWeekdays = const [1, 2, 3, 4, 5, 6, 7],
    this.reminderTime = '',
    this.isArchived = false,
  });

  /// Check if the habit is scheduled for a given weekday (1..7)
  bool isScheduledForWeekday(int weekday) {
    if (frequency == 'Every Day') return true;
    return selectedWeekdays.contains(weekday);
  }

  /// Check if the habit is active on a given date (starts on or before date)
  bool isActiveOnDate(DateTime date) {
    final normDate = DateTime(date.year, date.month, date.day);
    final normStart = DateTime(startDate.year, startDate.month, startDate.day);
    if (normDate.isBefore(normStart)) return false;
    return isScheduledForWeekday(date.weekday);
  }

  Habit copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? iconKey,
    int? colorValue,
    DateTime? createdAt,
    DateTime? startDate,
    String? frequency,
    List<int>? selectedWeekdays,
    String? reminderTime,
    bool? isArchived,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      iconKey: iconKey ?? this.iconKey,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
      startDate: startDate ?? this.startDate,
      frequency: frequency ?? this.frequency,
      selectedWeekdays: selectedWeekdays ?? this.selectedWeekdays,
      reminderTime: reminderTime ?? this.reminderTime,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'iconKey': iconKey,
      'colorValue': colorValue,
      'createdAt': createdAt.toIso8601String(),
      'startDate': startDate.toIso8601String(),
      'frequency': frequency,
      'selectedWeekdays': selectedWeekdays,
      'reminderTime': reminderTime,
      'isArchived': isArchived,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      description: (json['description'] as String?) ?? '',
      category: json['category'] as String,
      iconKey: json['iconKey'] as String,
      colorValue: json['colorValue'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      startDate: DateTime.parse(json['startDate'] as String),
      frequency: (json['frequency'] as String?) ?? 'Every Day',
      selectedWeekdays: (json['selectedWeekdays'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [1, 2, 3, 4, 5, 6, 7],
      reminderTime: (json['reminderTime'] as String?) ?? '',
      isArchived: (json['isArchived'] as bool?) ?? false,
    );
  }
}

