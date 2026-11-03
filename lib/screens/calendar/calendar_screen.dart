import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../providers/habit_provider.dart';

class CalendarScreen extends StatefulWidget {
  final HabitProvider habitProvider;

  const CalendarScreen({super.key, required this.habitProvider});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
    _selectedDate = DateUtilsCustom.normalize(now);
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtilsCustom.getDaysInMonth(
      _selectedMonth.year,
      _selectedMonth.month,
    );

    // Weekday of the first day (1 = Monday ... 7 = Sunday)
    final firstWeekday = _selectedMonth.weekday;
    final totalGridCells = (firstWeekday - 1) + daysInMonth.length;
    final totalRows = (totalGridCells / 7).ceil();

    final selectedDateStr = DateUtilsCustom.toDateString(_selectedDate);
    final scheduledForSelected =
        widget.habitProvider.getHabitsForDate(_selectedDate);
    final completedCount =
        widget.habitProvider.getCompletedCountForDate(_selectedDate);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Activity Calendar'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Calendar Container Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  // Month navigation header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded),
                        onPressed: _previousMonth,
                      ),
                      Text(
                        DateUtilsCustom.formatMonthYear(_selectedMonth),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded),
                        onPressed: _nextMonth,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Weekday headers (Mon - Sun)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: AppConstants.weekDayShort.map((day) {
                      return SizedBox(
                        width: 38,
                        child: Text(
                          day,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 8),

                  // Month Grid
                  Column(
                    children: List.generate(totalRows, (rowIndex) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(7, (colIndex) {
                            final cellIndex = rowIndex * 7 + colIndex;
                            final dayNumber = cellIndex - (firstWeekday - 1) + 1;

                            if (dayNumber < 1 || dayNumber > daysInMonth.length) {
                              return const SizedBox(width: 38, height: 44);
                            }

                            final cellDate = DateTime(
                              _selectedMonth.year,
                              _selectedMonth.month,
                              dayNumber,
                            );
                            final isToday = DateUtilsCustom.isSameDay(
                                cellDate, DateTime.now());
                            final isSelected = DateUtilsCustom.isSameDay(
                                cellDate, _selectedDate);
                            final completionRate = widget.habitProvider
                                .getCompletionRateForDate(cellDate);
                            final completedOnDay = widget.habitProvider
                                .getCompletedCountForDate(cellDate);

                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedDate = cellDate;
                                });
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 38,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primaryColor
                                      : isToday
                                          ? AppTheme.primaryLight
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  border: isToday && !isSelected
                                      ? Border.all(
                                          color: AppTheme.primaryColor,
                                          width: 1.5)
                                      : null,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$dayNumber',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isSelected || isToday
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? Colors.white
                                            : isToday
                                                ? AppTheme.primaryColor
                                                : const Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    // Completion indicator dot
                                    if (completedOnDay > 0)
                                      Container(
                                        width: 5,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.white
                                              : completionRate >= 0.8
                                                  ? AppTheme.accentColor
                                                  : const Color(0xFFF59E0B),
                                          shape: BoxShape.circle,
                                        ),
                                      )
                                    else
                                      const SizedBox(height: 5),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Date Overview Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateUtilsCustom.formatFullDate(_selectedDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$completedCount of ${scheduledForSelected.length} completed',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: completedCount > 0 &&
                              completedCount == scheduledForSelected.length
                          ? AppTheme.accentLight
                          : const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      scheduledForSelected.isEmpty
                          ? '0%'
                          : '${(completedCount / scheduledForSelected.length * 100).round()}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: completedCount > 0 &&
                                completedCount == scheduledForSelected.length
                            ? const Color(0xFF047857)
                            : AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Habits for Selected Day
            const Text(
              'Habits on Selected Day',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),

            if (scheduledForSelected.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No habits scheduled for this date.',
                    style: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                ),
              )
            else
              ...scheduledForSelected.map((habit) {
                final isDone = widget.habitProvider
                    .isHabitCompleted(habit.id, selectedDateStr);
                final habitColor = Color(habit.colorValue);
                final icon = AppConstants.habitIcons[habit.iconKey] ??
                    Icons.check_circle_rounded;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDone
                          ? AppTheme.accentColor.withValues(alpha: 0.35)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: habitColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: habitColor, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              habit.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                decoration:
                                    isDone ? TextDecoration.lineThrough : null,
                                color: isDone
                                    ? const Color(0xFF64748B)
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              habit.category,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isDone
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: isDone
                              ? AppTheme.accentColor
                              : const Color(0xFFCBD5E1),
                        ),
                        onPressed: () async {
                          await widget.habitProvider
                              .toggleCompletion(habit.id, _selectedDate);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
