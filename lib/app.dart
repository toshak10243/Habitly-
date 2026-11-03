import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'providers/profile_provider.dart';
import 'screens/onboarding/splash_screen.dart';

class HabitlyApp extends StatefulWidget {
  const HabitlyApp({super.key});

  @override
  State<HabitlyApp> createState() => _HabitlyAppState();
}

class _HabitlyAppState extends State<HabitlyApp> {
  final ProfileProvider _profileProvider = ProfileProvider();

  @override
  void dispose() {
    _profileProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habitly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: SplashScreen(profileProvider: _profileProvider),
    );
  }
}

