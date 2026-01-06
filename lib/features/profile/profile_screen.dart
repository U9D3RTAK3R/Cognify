import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgBlack,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryCyan.withOpacity(0.2),
                    AppTheme.accentPurple.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppTheme.primaryCyan.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryCyan, AppTheme.accentPurple],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryCyan.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text("🥷", style: TextStyle(fontSize: 50)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text("Cyber Ninja", style: AppTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text(
                    "@cyberninja42",
                    style: TextStyle(color: AppTheme.textGrey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _statItem("Level", "5"),
                      _statItem("XP", "2,450"),
                      _statItem("Rank", "#42"),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.1, end: 0),

            const SizedBox(height: 24),

            // Achievements
            _sectionTitle("ACHIEVEMENTS"),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _achievementBadge("🏆", "First Win", Colors.amber),
                  _achievementBadge("🔥", "7 Day Streak", Colors.orange),
                  _achievementBadge("⚡", "Speed Demon", AppTheme.primaryCyan),
                  _achievementBadge("🎯", "Perfect Score", Colors.green),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Stats
            _sectionTitle("STATISTICS"),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    "Battles Won",
                    "12",
                    Icons.sports_esports,
                    AppTheme.primaryCyan,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    "Courses",
                    "3",
                    Icons.book,
                    AppTheme.accentPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    "Streak",
                    "7 days",
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    "Time",
                    "24h",
                    Icons.access_time,
                    Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Menu Items
            _menuItem(context, Icons.settings, "Settings", () {}),
            _menuItem(context, Icons.help_outline, "Help & Support", () {}),
            _menuItem(
              context,
              Icons.privacy_tip_outlined,
              "Privacy Policy",
              () {},
            ),
            _menuItem(
              context,
              Icons.logout,
              "Logout",
              () => context.go('/login'),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: AppTheme.labelLarge.copyWith(color: AppTheme.primaryCyan),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.headlineMedium.copyWith(color: AppTheme.primaryCyan),
        ),
        Text(label, style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
      ],
    );
  }

  Widget _achievementBadge(String emoji, String label, Color color) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: AppTheme.headlineMedium.copyWith(color: color)),
          Text(label, style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _menuItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: AppTheme.bodyMedium)),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
