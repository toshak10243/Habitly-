import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../models/habit.dart';
import '../../providers/habit_provider.dart';
import '../../widgets/chart_widgets.dart';

class AnalyticsScreen extends StatefulWidget {
  final HabitProvider habitProvider;

  const AnalyticsScreen({super.key, required this.habitProvider});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _timeframeFilter = 'Weekly'; // 'Weekly' or 'Monthly'

  @override
  Widget build(BuildContext context) {
    final habits = widget.habitProvider.habits;
    final completions = widget.habitProvider.completions;

    // 1. Overall Completion Percentage
    final totalScheduledLast30Days = _calculateTotalScheduledLastDays(30);
    final totalCompletedLast30Days = _calculateTotalCompletedLastDays(30);
    final overallRate = totalScheduledLast30Days > 0
        ? (totalCompletedLast30Days / totalScheduledLast30Days * 100).round()
        : 0;

    // 2. Global current streak
    final globalStreak = widget.habitProvider.calculateGlobalStreak();

    // 3. Best Performing Habit
    Habit? bestHabit;
    int highestCompletions = -1;
    for (final h in habits) {
      final c = widget.habitProvider.getTotalCompletions(h.id);
      if (c > highestCompletions) {
        highestCompletions = c;
        bestHabit = h;
      }
    }

    // 4. Category-wise Habit Distribution
    final categoryCounts = <String, int>{};
    for (final h in widget.habitProvider.activeHabits) {
      categoryCounts[h.category] = (categoryCounts[h.category] ?? 0) + 1;
    }

    // 5. Weekly Bar Chart Data (Past 7 Days)
    final past7Days = DateUtilsCustom.getPast7Days();
    final dayLabels = past7Days.map((d) {
      const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
      return days[d.weekday - 1];
    }).toList();
    final completionRates = past7Days.map((d) {
      return widget.habitProvider.getCompletionRateForDate(d);
    }).toList();
    final completedCounts = past7Days.map((d) {
      return widget.habitProvider.getCompletedCountForDate(d);
    }).toList();
    final totalCounts = past7Days.map((d) {
      return widget.habitProvider.getHabitsForDate(d).length;
    }).toList();

    // 6. Monthly 30-Day Trend Data
    final today = DateUtilsCustom.normalize(DateTime.now());
    final past30Days = List.generate(
      30,
      (i) => today.subtract(Duration(days: 29 - i)),
    );
    final dailyRates = past30Days.map((d) {
      return widget.habitProvider.getCompletionRateForDate(d);
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Performance & Analytics'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Weekly', label: Text('Week')),
                  ButtonSegment(value: 'Monthly', label: Text('Month')),
                ],
                selected: {_timeframeFilter},
                onSelectionChanged: (set) {
                  setState(() {
                    _timeframeFilter = set.first;
                  });
                },
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  textStyle: WidgetStateProperty.all(
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // KPI Highlight Cards
            Row(
              children: [
                Expanded(
                  child: _KPICard(
                    title: 'Total Logged',
                    value: '${completions.length}',
                    subtitle: 'Completions to date',
                    icon: Icons.check_circle_outline_rounded,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _KPICard(
                    title: 'Active Streak',
                    value: '$globalStreak',
                    subtitle: 'Consecutive days',
                    icon: Icons.local_fire_department_rounded,
                    color: const Color(0xFFF97316),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _KPICard(
                    title: '30-Day Consistency',
                    value: '$overallRate%',
                    subtitle: 'Avg target execution',
                    icon: Icons.pie_chart_outline_rounded,
                    color: AppTheme.accentColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _KPICard(
                    title: 'Top Habit',
                    value: bestHabit != null ? bestHabit.name : 'None',
                    subtitle: bestHabit != null ? '$highestCompletions checks' : 'Add habit',
                    icon: Icons.star_outline_rounded,
                    color: const Color(0xFF8B5CF6),
                    isCompactText: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Timeframe specific visual
            if (_timeframeFilter == 'Weekly') ...[
              WeeklyBarChartWidget(
                dayLabels: dayLabels,
                completionRates: completionRates,
                completedCounts: completedCounts,
                totalCounts: totalCounts,
              ),
            ] else ...[
              MonthlyTrendLineChartWidget(
                dailyRates: dailyRates,
              ),
            ],

            const SizedBox(height: 20),

            // Category Distribution Donut Chart
            CategoryDonutChartWidget(
              categoryCounts: categoryCounts,
            ),

            const SizedBox(height: 20),

            // Habit Ranking Breakdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Habit Completion Leaderboard',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Ranked by lifetime consistency and completed sessions',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 16),
                  if (habits.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No habits found.', style: TextStyle(color: Color(0xFF94A3B8))),
                      ),
                    )
                  else
                    ...habits.map((h) {
                      final c = widget.habitProvider.getTotalCompletions(h.id);
                      final streak = widget.habitProvider.calculateCurrentStreak(h.id);
                      final habitColor = Color(h.colorValue);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: habitColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.track_changes_rounded,
                                  color: habitColor,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    h.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0F172A),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Streak: $streak days',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$c checks',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateTotalScheduledLastDays(int days) {
    int count = 0;
    final today = DateUtilsCustom.normalize(DateTime.now());
    for (int i = 0; i < days; i++) {
      final d = today.subtract(Duration(days: i));
      count += widget.habitProvider.getHabitsForDate(d).length;
    }
    return count;
  }

  int _calculateTotalCompletedLastDays(int days) {
    int count = 0;
    final today = DateUtilsCustom.normalize(DateTime.now());
    for (int i = 0; i < days; i++) {
      final d = today.subtract(Duration(days: i));
      count += widget.habitProvider.getCompletedCountForDate(d);
    }
    return count;
  }
}

class _KPICard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isCompactText;

  const _KPICard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.isCompactText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              Icon(icon, size: 20, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isCompactText ? 17 : 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF94A3B8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

