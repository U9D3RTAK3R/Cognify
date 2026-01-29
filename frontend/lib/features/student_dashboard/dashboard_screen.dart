import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/gamification_state.dart';
import '../../core/providers/user_state.dart';
import '../../core/providers/auth_state.dart';
import '../../core/theme/app_animations.dart';
import '../../shared/animations/breathing_card.dart';
import '../../shared/animations/animated_neon_button.dart';

import 'widgets/xp_bar.dart';
import 'widgets/stats_grid.dart';
import 'widgets/progress_chart.dart';
import 'widgets/mastery_pie_chart.dart';
import 'widgets/course_card.dart';
import 'widgets/notifications_sheet.dart';
import 'package:cognify/features/explore/data/explore_state.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userStateProvider);
    final profile = userState.profile;
    final hasUnread = userState.notifications.any((n) => n.isUnread);
    final authState = ref.watch(authProvider); // Watch auth state
    final isInstructor = authState.role == 'instructor';

    final gamification = ref.watch(gamificationProvider);
    final stats = gamification.userStats;

    final exploreState = ref.watch(exploreProvider);
    final myCourses = exploreState.courses
        .where(
          (c) =>
              c.status == CourseStatus.enrolled ||
              c.status == CourseStatus.ongoing,
        )
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.bgBlack,
      body: AppAnimations.pageTransitionWrapper(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.emoji_events_outlined, color: Colors.amber),
                            onPressed: () => context.push('/leaderboard'),
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
                BreathingCard(
                  glowColor: AppTheme.primaryCyan,
                   child: XpBar(
                    level: stats.level,
                    currentXp: stats.totalXp % 1000,
                    maxXp: 1000,
                    rank: profile.name,
                  ),
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
                      child: AnimatedNeonButton(
                        label: "Forum",
                        icon: Icons.forum,
                        color: Colors.blue,
                        onTap: () => context.go('/forum'),
                        isPrimary: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AnimatedNeonButton(
                        label: "Ask Oracle",
                        icon: Icons.psychology,
                        color: AppTheme.accentPurple,
                        onTap: () => context.go('/ai-chat'),
                        isPrimary: true,
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
                  child: myCourses.isEmpty
                      ? Center(
                          child: Text(
                            "No active courses yet. Start exploring!",
                            style: TextStyle(color: AppTheme.textGrey),
                          ),
                        )
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          itemCount: myCourses.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            final course = myCourses[index];
                            return GestureDetector(
                              onTap: () => context.go('/course/${course.id}'),
                              child: CourseCard(course: course),
                            );
                          },
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

}
