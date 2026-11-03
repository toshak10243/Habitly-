import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/habit_provider.dart';
import '../../providers/profile_provider.dart';
import '../analytics/analytics_screen.dart';
import '../calendar/calendar_screen.dart';
import '../habits/habits_screen.dart';
import '../profile/profile_screen.dart';
import 'dashboard_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // Singletons initialized for app lifespan
  late final HabitProvider _habitProvider;
  late final ProfileProvider _profileProvider;

  @override
  void initState() {
    super.initState();
    _habitProvider = HabitProvider();
    _profileProvider = ProfileProvider();

    // Listen to changes so whole app re-renders cleanly
    _habitProvider.addListener(_onProviderUpdate);
    _profileProvider.addListener(_onProviderUpdate);
  }

  void _onProviderUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _habitProvider.removeListener(_onProviderUpdate);
    _profileProvider.removeListener(_onProviderUpdate);
    _habitProvider.dispose();
    _profileProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Keep navigation state preserved using IndexedStack
    final screens = [
      DashboardScreen(
        habitProvider: _habitProvider,
        profileProvider: _profileProvider,
        onNavigateToHabits: () {
          setState(() => _currentIndex = 1);
        },
      ),
      HabitsScreen(habitProvider: _habitProvider),
      CalendarScreen(habitProvider: _habitProvider),
      AnalyticsScreen(habitProvider: _habitProvider),
      ProfileScreen(
        habitProvider: _habitProvider,
        profileProvider: _profileProvider,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          backgroundColor: Colors.white,
          indicatorColor: AppTheme.primaryLight,
          elevation: 0,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: AppTheme.primaryColor),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.checklist_outlined),
              selectedIcon: Icon(Icons.checklist_rounded, color: AppTheme.primaryColor),
              label: 'Habits',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month_rounded, color: AppTheme.primaryColor),
              label: 'Calendar',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart_rounded, color: AppTheme.primaryColor),
              label: 'Analytics',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded, color: AppTheme.primaryColor),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

