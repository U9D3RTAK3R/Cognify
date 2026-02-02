import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/instructor_state.dart';
import '../../../core/providers/user_state.dart';
import '../../../core/providers/auth_state.dart';
import '../screens/instructor_analytics_screen.dart';

class InstructorDashboardScreen extends ConsumerWidget {
  const InstructorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instructorState = ref.watch(instructorStateProvider);
    final userState = ref.watch(userStateProvider);
    final authState = ref.watch(authProvider);

    // Show loading state if auth data is not ready
    if (authState.walletAddress == null || authState.walletAddress!.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.bgBlack,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.orange),
              const SizedBox(height: 16),
              Text(
                'Loading instructor dashboard...',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textGrey),
              ),
            ],
          ),
        ),
      );
    }

    // Ensure we have fresh stats
    // Note: We're doing this in build for simplicity but usually better in initState or router listener
    // But since we have a state notifier that handles 'fetch if empty' or similar, we rely on that.
    // Actually, let's trigger a refresh if the values are default/zero if we want to be sure.
    // ref.read(instructorStateProvider.notifier).fetchDashboardStats();
    // Commented out to avoid infinite loops, relying on the one-time fetch in notifier constructor.

    return Scaffold(
      backgroundColor: AppTheme.bgBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.orange.withOpacity(0.5),
                                ),
                              ),
                              child: const Text(
                                'INSTRUCTOR',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Welcome back,",
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textGrey,
                          ),
                        ),
                        Text(
                          instructorState.name.isNotEmpty
                              ? instructorState.name
                              : "Instructor",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ), // Add spacing between text and avatar
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade400, Colors.deepOrange],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        userState.profile.avatarEmoji.isNotEmpty
                            ? userState.profile.avatarEmoji
                            : '👨‍🏫',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn().slideY(begin: -0.2, end: 0),
              const SizedBox(height: 24),

              // Stats Grid
              SizedBox(
                height: 120,
                child: Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        'Total Students',
                        '${instructorState.totalStudents}',
                        Icons.people,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        'Active Courses',
                        // Use the actual count from backend stats
                        '${instructorState.activeCoursesCount}',
                        Icons.book,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        'Completion Rate',
                        '${instructorState.completionRate}%',
                        Icons.trending_up,
                        Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        'Avg. Rating',
                        '${instructorState.averageRating}',
                        Icons.star,
                        Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'QUICK ACTIONS',
                style: AppTheme.labelLarge.copyWith(color: Colors.orange),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      context,
                      Icons.add_circle_outline,
                      'Create Course',
                      Colors.orange,
                      () => context.go('/instructor/courses'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _actionButton(
                      context,
                      Icons.quiz_outlined,
                      'Add Questions',
                      Colors.purple,
                      () => context.go('/instructor/editor'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // NEW BUTTON FOR TRUST ANALYTICS
              Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      context,
                      Icons.verified_user_outlined,
                      'Trust & Reputation',
                      const Color(0xFF10B981),
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => InstructorAnalyticsScreen(
                              walletAddress: authState.walletAddress!,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Activity
              Text(
                'RECENT ACTIVITY',
                style: AppTheme.labelLarge.copyWith(color: Colors.orange),
              ),
              const SizedBox(height: 12),
              if (instructorState.recentActivity.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('No recent activity'),
                  ),
                )
              else
                Column(
                  children: instructorState.recentActivity.map((activity) {
                    return _activityItem(
                      activity.title,
                      activity.subtitle,
                      _getTimeAgo(activity.timestamp),
                      _getActivityIcon(activity.type),
                      _getActivityColor(activity.type),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _activityItem(
    String title,
    String subtitle,
    String time,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.bodyMedium),
                Text(
                  subtitle,
                  style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(time, style: TextStyle(color: AppTheme.textGrey, fontSize: 10)),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'enrollment':
        return Icons.person_add;
      case 'completion':
        return Icons.check_circle;
      case 'feedback':
        return Icons.rate_review;
      case 'certificate':
        return Icons.verified;
      default:
        return Icons.info;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'enrollment':
        return Colors.green;
      case 'completion':
        return Colors.blue;
      case 'feedback':
        return Colors.amber;
      case 'certificate':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
