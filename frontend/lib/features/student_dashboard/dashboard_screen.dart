import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/gamification_state.dart';
import '../../core/providers/user_state.dart';
import 'data/mock_data.dart';
import 'widgets/xp_bar.dart';
import 'widgets/stats_grid.dart';
import 'widgets/progress_chart.dart';
import 'widgets/mastery_pie_chart.dart';
import 'widgets/course_card.dart';
import 'widgets/notifications_sheet.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userStateProvider);
    final profile = userState.profile;
    final hasUnread = userState.notifications.any((n) => n.isUnread);

    final gamification = ref.watch(gamificationProvider);
    final stats = gamification.userStats;

    return Scaffold(
      backgroundColor: AppTheme.bgBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome back,",
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textGrey,
                        ),
                      ),
                      Text(profile.name, style: AppTheme.headlineMedium),
                    ],
                  ),
                  Row(
                    children: [
                      // Leaderboard button
                      GestureDetector(
                        onTap: () => context.push('/leaderboard'),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.emoji_events_outlined,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Notifications button
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (context) => DraggableScrollableSheet(
                              initialChildSize: 0.6,
                              minChildSize: 0.4,
                              maxChildSize: 0.9,
                              builder: (_, controller) =>
                                  const NotificationsSheet(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Stack(
                            children: [
                              const Icon(
                                Icons.notifications_outlined,
                                color: Colors.white,
                              ),
                              if (hasUnread)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ).animate().fadeIn().slideY(begin: -0.2, end: 0),
              const SizedBox(height: 24),
              XpBar(
                level: stats.level,
                currentXp: stats.totalXp % 1000,
                maxXp: 1000,
                rank: profile.name,
              ),
              const SizedBox(height: 24),
              const StatsGrid(),
              const SizedBox(height: 24),
              const ProgressChart(),
              const SizedBox(height: 16),
              const MasteryPieChart(),
              const SizedBox(height: 24),
              Text(
                "QUICK ACTIONS",
                style: AppTheme.labelLarge.copyWith(
                  color: AppTheme.primaryCyan,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      context,
                      icon: Icons.play_arrow,
                      label: "Continue",
                      color: AppTheme.primaryCyan,
                      onTap: () => context.go('/battle'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _actionButton(
                      context,
                      icon: Icons.psychology,
                      label: "Ask Oracle",
                      color: AppTheme.accentPurple,
                      onTap: () => context.go('/ai-chat'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "MY COURSES",
                    style: AppTheme.labelLarge.copyWith(
                      color: AppTheme.accentPurple,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/explore'),
                    child: const Text("View All"),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: MockData.trendingCourses.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final course = MockData.trendingCourses[index];
                    return GestureDetector(
                      onTap: () => context.go('/course/${course.id}'),
                      child: CourseCard(course: course)
                          .animate()
                          .fadeIn(delay: (100 * index).ms)
                          .slideX(begin: 0.1, end: 0),
                    );
                  },
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
