import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import 'data/mock_data.dart';
import 'widgets/xp_bar.dart';
import 'widgets/stats_grid.dart';
import 'widgets/progress_chart.dart';
import 'widgets/mastery_pie_chart.dart';
import 'widgets/course_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                      Text("Cyber Ninja", style: AppTheme.headlineMedium),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                    ),
                  ),
                ],
              ).animate().fadeIn().slideY(begin: -0.2, end: 0),
              const SizedBox(height: 24),
              const XpBar(
                level: 5,
                currentXp: 350,
                maxXp: 1000,
                rank: "Cyber Ninja",
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
