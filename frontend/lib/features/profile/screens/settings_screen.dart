import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _darkMode = true;
  bool _soundEffects = true;
  bool _hapticFeedback = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgBlack,
      appBar: AppBar(
        title: Text('Settings', style: AppTheme.headlineMedium),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('NOTIFICATIONS'),
            const SizedBox(height: 12),
            _settingsTile(
              'Push Notifications',
              'Receive updates and reminders',
              Icons.notifications_outlined,
              _notifications,
              (val) => setState(() => _notifications = val),
            ),

            const SizedBox(height: 24),
            _sectionTitle('APPEARANCE'),
            const SizedBox(height: 12),
            _settingsTile(
              'Dark Mode',
              'Use dark theme',
              Icons.dark_mode_outlined,
              _darkMode,
              (val) => setState(() => _darkMode = val),
            ),

            const SizedBox(height: 24),
            _sectionTitle('SOUND & HAPTICS'),
            const SizedBox(height: 12),
            _settingsTile(
              'Sound Effects',
              'Play sounds for actions',
              Icons.volume_up_outlined,
              _soundEffects,
              (val) => setState(() => _soundEffects = val),
            ),
            const SizedBox(height: 12),
            _settingsTile(
              'Haptic Feedback',
              'Vibrate on interactions',
              Icons.vibration,
              _hapticFeedback,
              (val) => setState(() => _hapticFeedback = val),
            ),

            const SizedBox(height: 24),
            _sectionTitle('DATA & STORAGE'),
            const SizedBox(height: 12),
            _actionTile('Clear Cache', Icons.cleaning_services_outlined, () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Cache cleared!'),
                  backgroundColor: AppTheme.primaryCyan,
                ),
              );
            }),
            const SizedBox(height: 12),
            _actionTile('Download Data', Icons.download_outlined, () {}),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.labelLarge.copyWith(color: AppTheme.primaryCyan),
    );
  }

  Widget _settingsTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryCyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryCyan),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.bodyLarge),
                Text(
                  subtitle,
                  style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryCyan,
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }

  Widget _actionTile(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.accentPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.accentPurple),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: AppTheme.bodyLarge)),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
