class DateUtilsCustom {
  /// Returns date formatted as YYYY-MM-DD
  static String toDateString(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Parses YYYY-MM-DD to DateTime (local midnight)
  static DateTime parseDate(String dateStr) {
    final parts = dateStr.split('-');
    if (parts.length == 3) {
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    }
    return DateTime.now();
  }

  /// Check if two dates are the same calendar day
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Normalize a DateTime to year-month-day at 00:00:00
  static DateTime normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Format friendly: "Monday, Nov 3"
  static String formatFullDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    final dayName = weekdays[date.weekday - 1];
    final monthName = months[date.month - 1];
    return '$dayName, $monthName ${date.day}';
  }

  /// Format month year: "November 2026"
  static String formatMonthYear(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  /// Get past 7 days ending today
  static List<DateTime> getPast7Days() {
    final today = normalize(DateTime.now());
    return List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));
  }

  /// Get days of a specific month
  static List<DateTime> getDaysInMonth(int year, int month) {
    final totalDays = DateTime(year, month + 1, 0).day;
    return List.generate(totalDays, (i) => DateTime(year, month, i + 1));
  }
}

