import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../models/habit.dart';
import '../../providers/habit_provider.dart';
import 'add_habit_screen.dart';

class HabitDetailScreen extends StatelessWidget {
  final Habit habit;
  final HabitProvider habitProvider;

  const HabitDetailScreen({
    super.key,
    required this.habit,
    required this.habitProvider,
  });

  @override
  Widget build(BuildContext context) {
    // Re-fetch habit in case it was edited or completed
    final currentHabit = habitProvider.habits.firstWhere(
      (h) => h.id == habit.id,
      orElse: () => habit,
    );

    final currentStreak = habitProvider.calculateCurrentStreak(currentHabit.id);
    final longestStreak = habitProvider.calculateLongestStreak(currentHabit.id);
    final totalCompletions = habitProvider.getTotalCompletions(currentHabit.id);

    final habitColor = Color(currentHabit.colorValue);
    final iconData = AppConstants.habitIcons[currentHabit.iconKey] ?? Icons.check_circle_rounded;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Habit Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Habit',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddEditHabitScreen(
                    habitProvider: habitProvider,
                    habitToEdit: currentHabit,
                  ),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (val) async {
              if (val == 'archive') {
                await habitProvider.toggleArchive(currentHabit.id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(currentHabit.isArchived
                        ? 'Habit unarchived!'
                        : 'Habit archived!'),
                  ),
                );
              } else if (val == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Habit?'),
                    content: Text(
                      'Are you sure you want to permanently delete "${currentHabit.name}"? All completion history will be removed.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await habitProvider.deleteHabit(currentHabit.id);
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'archive',
                child: Text(currentHabit.isArchived ? 'Restore to Active' : 'Archive Habit'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete Habit', style: TextStyle(color: AppTheme.errorColor)),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: habitColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(iconData, size: 36, color: habitColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentHabit.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                currentHabit.category,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (currentHabit.isArchived)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Archived',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFD97706),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (currentHabit.description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            currentHabit.description,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Metrics row: Current streak, Longest streak, Total completions
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Current Streak',
                    value: '$currentStreak',
                    unit: 'days',
                    icon: Icons.local_fire_department_rounded,
                    color: const Color(0xFFF97316),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Best Streak',
                    value: '$longestStreak',
                    unit: 'days',
                    icon: Icons.emoji_events_rounded,
                    color: const Color(0xFFEAB308),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Completions',
                    value: '$totalCompletions',
                    unit: 'times',
                    icon: Icons.check_circle_rounded,
                    color: AppTheme.accentColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Schedule & Details Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Configuration & Schedule',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(
                    label: 'Frequency',
                    value: currentHabit.frequency,
                    icon: Icons.repeat_rounded,
                  ),
                  const Divider(height: 24),
                  _DetailRow(
                    label: 'Started On',
                    value: DateUtilsCustom.formatFullDate(currentHabit.startDate),
                    icon: Icons.calendar_today_rounded,
                  ),
                  const Divider(height: 24),
                  _DetailRow(
                    label: 'Daily Reminder',
                    value: currentHabit.reminderTime.isNotEmpty ? currentHabit.reminderTime : 'None',
                    icon: Icons.alarm_rounded,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Past 14-Day Completion Grid
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent 14-Day Consistency',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Green pills indicate completed days within this period',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(14, (i) {
                      final day = DateTime.now().subtract(Duration(days: 13 - i));
                      final dayStr = DateUtilsCustom.toDateString(day);
                      final isDone = habitProvider.isHabitCompleted(currentHabit.id, dayStr);
                      return Tooltip(
                        message: '${DateUtilsCustom.formatFullDate(day)}: ${isDone ? "Done" : "Not done"}',
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isDone ? AppTheme.accentColor : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDone ? AppTheme.accentColor : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Center(
                            child: isDone
                                ? const Icon(Icons.check, size: 18, color: Colors.white)
                                : Text(
                                    '${day.day}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF64748B)),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}

