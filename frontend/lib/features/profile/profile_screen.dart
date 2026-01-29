import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/user_state.dart';
import '../../core/providers/gamification_state.dart';
import '../../core/providers/auth_state.dart';
import '../../core/theme/app_animations.dart';
import '../../shared/animations/breathing_card.dart';
import '../../shared/animations/ambient_background.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userStateProvider);
    final profile = userState.profile;
    final gamification = ref.watch(gamificationProvider);
    final stats = gamification.userStats;
    final achievements = gamification.achievements;
    final authState = ref.watch(authProvider);
    final isInstructor = authState.role == 'instructor';

    return Scaffold(
      backgroundColor: AppTheme.bgBlack,
      body: AmbientBackground(
        child: AppAnimations.pageTransitionWrapper(
          child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 40),
              if (isInstructor) ...[
                GestureDetector(
                  onTap: () => context.go('/instructor/profile'),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.school, color: Colors.orange),
                        const SizedBox(width: 12),
                        Text(
                          "Viewing as Student - Switch Back to Instructor",
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              // Profile Header
              BreathingCard(
                glowColor: AppTheme.primaryCyan,
                child: Container(
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
                        child: Center(
                          child: Text(
                            profile.avatarEmoji,
                            style: const TextStyle(fontSize: 50),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(profile.name, style: AppTheme.headlineMedium),
                      const SizedBox(height: 4),
                      Text(
                        "@${profile.username}",
                        style: TextStyle(color: AppTheme.textGrey),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _statItem("Level", stats.level.toString()),
                          _statItem("XP", "${stats.totalXp}"),
                          _statItem("Rank", "#${stats.globalRank}"),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Edit Profile Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/profile/edit'),
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Edit Profile'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryCyan,
                            side: BorderSide(
                              color: AppTheme.primaryCyan.withOpacity(0.5),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),

              // Achievements
              _sectionTitle("ACHIEVEMENTS"),
              const SizedBox(height: 12),
              SizedBox(
                height: 110,
                child: achievements.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryCyan,
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: achievements.length,
                        itemBuilder: (context, index) {
                          final achievement = achievements[index];
                          return _achievementBadge(
                            achievement.emoji,
                            achievement.name,
                            achievement.isUnlocked
                                ? _getAchievementColor(achievement.category)
                                : Colors.grey,
                            isLocked: !achievement.isUnlocked,
                            requirement: achievement.requirement,
                          );
                        },
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
                      stats.battlesWon.toString(),
                      Icons.sports_esports,
                      AppTheme.primaryCyan,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      "Courses",
                      stats.coursesCompleted.toString(),
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
                      "${stats.currentStreak} days",
                      Icons.local_fire_department,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      "Total XP",
                      stats.totalXp.toString(),
                      Icons.bolt,
                      Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Menu Items
              _menuItem(
                context,
                Icons.settings,
                "Settings",
                () => context.push('/profile/settings'),
              ),
              _menuItem(
                context,
                Icons.help_outline,
                "Help & Support",
                () => context.push('/profile/help'),
              ),
              _menuItem(
                context,
                Icons.card_membership_rounded,
                "Certificates",
                () => context.push('/profile/certificates'),
              ),
              _menuItem(
                context,
                Icons.privacy_tip_outlined,
                "Privacy Policy",
                () => context.push('/profile/privacy'),
              ),

              // Logout Button - Redesigned
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showLogoutDialog(context, ref),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.logout, color: Colors.red),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          "Logout",
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.red),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Logout', style: AppTheme.headlineMedium),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textGrey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
              // context.go('/login'); // Router will handle redirect
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
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

  Color _getAchievementColor(String category) {
    switch (category) {
      case 'battles':
        return Colors.amber;
      case 'learning':
        return Colors.orange;
      case 'courses':
        return Colors.green;
      case 'social':
        return AppTheme.accentPurple;
      default:
        return AppTheme.primaryCyan;
    }
  }

  Widget _achievementBadge(
    String emoji,
    String label,
    Color color, {
    bool isLocked = false,
    String requirement = '',
  }) {
    return Tooltip(
      message: isLocked ? 'Locked: $requirement' : 'Unlocked!',
      child: Container(
        width: 85,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(isLocked ? 0.05 : 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(isLocked ? 0.2 : 0.4)),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  emoji,
                  style: TextStyle(
                    fontSize: 28,
                    color: isLocked ? Colors.grey : null,
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isLocked ? Colors.grey : color,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (isLocked)
              Positioned(
                top: 4,
                right: 4,
                child: Icon(
                  Icons.lock,
                  size: 14,
                  color: Colors.grey.withOpacity(0.7),
                ),
              ),
          ],
        ),
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
