import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/storage/local_storage.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/habit_provider.dart';
import '../../providers/profile_provider.dart';

class SettingsScreen extends StatelessWidget {
  final HabitProvider habitProvider;
  final ProfileProvider profileProvider;

  const SettingsScreen({
    super.key,
    required this.habitProvider,
    required this.profileProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Settings & Preferences'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Appearance Section
            _buildSectionHeader('Appearance & Experience'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.light_mode_rounded, color: AppTheme.primaryColor),
                    title: const Text('Theme Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Light Theme (Optimized for HCI readability)'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Light Active',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Notification preferences
            _buildSectionHeader('Reminders & Alerts'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.notifications_active_outlined, color: Color(0xFF06B6D4)),
                    title: Text('Offline Habit Alarms', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('In-app habit schedule reminders enabled'),
                    trailing: Icon(Icons.check_circle_rounded, color: AppTheme.accentColor),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Data Management
            _buildSectionHeader('Data Management & Offline Backup'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.file_download_outlined, color: AppTheme.accentColor),
                    title: const Text('Export Data to JSON', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('View and copy raw JSON backup of all habits'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      final jsonString = await LocalStorage.exportAllData();
                      if (!context.mounted) return;
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Exported JSON Backup'),
                          content: SizedBox(
                            width: double.maxFinite,
                            height: 300,
                            child: SingleChildScrollView(
                              child: SelectableText(
                                jsonString,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: jsonString));
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('JSON copied to clipboard!'),
                                    backgroundColor: AppTheme.accentColor,
                                  ),
                                );
                              },
                              child: const Text('Copy to Clipboard'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.delete_forever_rounded, color: AppTheme.errorColor),
                    title: const Text('Reset All Application Data', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.errorColor)),
                    subtitle: const Text('Clear habits, completions, and restore default state'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Reset Everything?'),
                          content: const Text(
                            'This action will permanently delete all stored habits and completions. Are you sure you want to proceed?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Confirm Reset'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await habitProvider.resetAllData();
                        await profileProvider.resetProfile();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('All data has been reset to defaults.'),
                            backgroundColor: AppTheme.errorColor,
                          ),
                        );
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // About & Academic Project Info
            _buildSectionHeader('Academic & Project Information'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BIT313 HCI Assessment 3 Project',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Habitly is engineered exclusively using Flutter & Dart core libraries, adhering strictly to zero third-party dependencies, offline-first file persistence, and fundamental Human-Computer Interaction usability heuristics.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.verified_outlined, size: 16, color: AppTheme.accentColor),
                      SizedBox(width: 6),
                      Text(
                        'Version 1.0.0 (Production Architecture)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF64748B),
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
