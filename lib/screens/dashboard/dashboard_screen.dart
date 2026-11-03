import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../providers/habit_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/custom_progress_ring.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/habit_card.dart';
import '../habits/add_habit_screen.dart';
import '../habits/habit_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  final HabitProvider habitProvider;
  final ProfileProvider profileProvider;
  final VoidCallback onNavigateToHabits;

  const DashboardScreen({
    super.key,
    required this.habitProvider,
    required this.profileProvider,
    required this.onNavigateToHabits,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getMotivationalQuote(double completionRate) {
    if (completionRate == 1.0) {
      return "Phenomenal job! You've conquered every goal for today! 🌟";
    } else if (completionRate >= 0.5) {
      return "Over halfway there! Keep building momentum step by step. 🚀";
    } else if (completionRate > 0.0) {
      return "Great start! Small daily wins compound into big transformations. ✨";
    } else {
      return "A new day full of potential. Complete your first habit today! 🌱";
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayStr = DateUtilsCustom.toDateString(today);
    final scheduledHabits = habitProvider.getHabitsForDate(today);
    final completedCount = habitProvider.getCompletedCountForDate(today);
    final totalCount = scheduledHabits.length;
    final progress = totalCount > 0 ? (completedCount / totalCount) : 0.0;
    final streak = habitProvider.calculateGlobalStreak();
    final user = profileProvider.profile;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_getGreeting()}, ${user.name.split(' ').first}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
            Text(
              DateUtilsCustom.formatFullDate(today),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFEDD5)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: Color(0xFFF97316),
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$streak d streak',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFC2410C),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await habitProvider.loadData();
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              // Daily Progress Hero Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, Color(0xFF4338CA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "TODAY'S MOMENTUM",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '$completedCount of $totalCount completed',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _getMotivationalQuote(progress),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.85),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    CustomProgressRing(
                      progress: progress,
                      size: 92,
                      strokeWidth: 9,
                      progressColor: AppTheme.accentColor,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Text(
                        '${(progress * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Weekly mini consistency strip
              _buildWeeklyStrip(habitProvider),

              const SizedBox(height: 24),

              // Today's Habits Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Today's Habits",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AddEditHabitScreen(
                            habitProvider: habitProvider,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Habit'),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Today's Habit Cards List
              if (scheduledHabits.isEmpty)
                EmptyStateWidget(
                  icon: Icons.checklist_rtl_rounded,
                  title: 'No Habits Scheduled Today',
                  subtitle: 'Take a break or set up a habit to conquer for today!',
                  actionLabel: 'Create a Habit',
                  onAction: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddEditHabitScreen(
                          habitProvider: habitProvider,
                        ),
                      ),
                    );
                  },
                )
              else
                ...scheduledHabits.map((habit) {
                  final isDone = habitProvider.isHabitCompleted(habit.id, todayStr);
                  final habitStreak = habitProvider.calculateCurrentStreak(habit.id);

                  return HabitCard(
                    habit: habit,
                    isCompleted: isDone,
                    currentStreak: habitStreak,
                    onToggle: () async {
                      final nowComplete = await habitProvider.toggleCompletion(habit.id);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            nowComplete
                                ? 'Awesome! "${habit.name}" completed! 🎉'
                                : 'Unchecked "${habit.name}".',
                          ),
                          duration: const Duration(seconds: 1),
                          backgroundColor:
                              nowComplete ? AppTheme.accentColor : const Color(0xFF64748B),
                        ),
                      );
                    },
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => HabitDetailScreen(
                            habit: habit,
                            habitProvider: habitProvider,
                          ),
                        ),
                      );
                    },
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyStrip(HabitProvider provider) {
    final past7Days = DateUtilsCustom.getPast7Days();
    final today = DateUtilsCustom.normalize(DateTime.now());

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              'Weekly Consistency Snapshot',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: past7Days.map((d) {
              final isToday = DateUtilsCustom.isSameDay(d, today);
              final count = provider.getCompletedCountForDate(d);
              final scheduled = provider.getHabitsForDate(d).length;
              final rate = scheduled > 0 ? (count / scheduled) : 0.0;
              const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
              final dayLabel = days[d.weekday - 1];

              return Column(
                children: [
                  Text(
                    dayLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isToday ? AppTheme.primaryColor : const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: rate >= 0.8
                          ? AppTheme.accentColor
                          : count > 0
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                      border: isToday
                          ? Border.all(color: AppTheme.primaryColor, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: count > 0
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : Text(
                              '${d.day}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

