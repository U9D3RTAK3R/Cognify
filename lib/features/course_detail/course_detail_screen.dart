import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../explore/data/explore_state.dart';

class CourseDetailScreen extends ConsumerWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exploreState = ref.watch(exploreProvider);
    final controller = ref.read(exploreProvider.notifier);
    final course = controller.getCourseById(courseId);

    if (course == null) {
      return Scaffold(
        backgroundColor: AppTheme.bgBlack,
        body: const Center(
          child: Text(
            "Course not found",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final color = Color(int.parse(course.colorHex));
    final lessonTitles = [
      'Introduction',
      'Core Concepts',
      'Advanced Topics',
      'Best Practices',
      'Final Project',
    ];

    return Scaffold(
      backgroundColor: AppTheme.bgBlack,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppTheme.cardColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                course.title,
                style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withOpacity(0.4), AppTheme.cardColor],
                  ),
                ),
                child: Center(
                  child: Text(
                    course.emoji,
                    style: const TextStyle(fontSize: 80),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Info
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: AppTheme.textGrey),
                      const SizedBox(width: 4),
                      Text(
                        course.instructor,
                        style: TextStyle(color: AppTheme.textGrey),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.book, size: 16, color: AppTheme.textGrey),
                      const SizedBox(width: 4),
                      Text(
                        '${course.lessons} lessons',
                        style: TextStyle(color: AppTheme.textGrey),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppTheme.textGrey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${course.duration}h',
                        style: TextStyle(color: AppTheme.textGrey),
                      ),
                    ],
                  ).animate().fadeIn(),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                    course.subtitle,
                    style: AppTheme.bodyMedium.copyWith(color: Colors.white70),
                  ),

                  const SizedBox(height: 24),

                  // Action Button based on status
                  if (course.status == CourseStatus.available) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Price",
                                style: TextStyle(color: AppTheme.textGrey),
                              ),
                              Text(
                                "\$${course.price}",
                                style: AppTheme.headlineMedium.copyWith(
                                  color: AppTheme.primaryCyan,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              controller.enrollCourse(course.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Course enrolled! (Payment simulated)",
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryCyan,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              "ENROLL NOW",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (course.status == CourseStatus.enrolled) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          controller.startCourse(course.id);
                          context.go('/battle');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryCyan,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          "START LEARNING",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ] else if (course.status == CourseStatus.completed) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: AppTheme.cardColor,
                              title: const Text(
                                "🎉 Certificate Generated!",
                                style: TextStyle(color: Colors.white),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppTheme.primaryCyan,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      children: [
                                        const Text(
                                          "CERTIFICATE OF COMPLETION",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          course.title,
                                          style: AppTheme.headlineMedium
                                              .copyWith(
                                                color: AppTheme.primaryCyan,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          "Awarded to: Cyber Ninja",
                                          style: TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Close"),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Download"),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.workspace_premium),
                        label: const Text("GENERATE CERTIFICATE"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Progress (for ongoing/completed)
                  if (course.status == CourseStatus.ongoing ||
                      course.status == CourseStatus.completed)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Progress", style: AppTheme.bodyLarge),
                              Text(
                                "${(course.progress * 100).toInt()}%",
                                style: AppTheme.headlineMedium.copyWith(
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: course.progress,
                              minHeight: 8,
                              backgroundColor: Colors.black,
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(),

                  const SizedBox(height: 24),

                  // Lessons
                  Text(
                    "LESSONS",
                    style: AppTheme.labelLarge.copyWith(color: color),
                  ),
                  const SizedBox(height: 12),

                  ...List.generate(5, (index) {
                    final isCompleted = course.progress > (index + 1) / 5;
                    final isCurrent =
                        course.progress >= index / 5 &&
                        course.progress < (index + 1) / 5;
                    final isLocked =
                        course.status == CourseStatus.available ||
                        course.status == CourseStatus.enrolled;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? color.withOpacity(0.1)
                            : AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCurrent ? color : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCompleted
                                  ? color
                                  : (isLocked
                                        ? Colors.grey.shade800
                                        : color.withOpacity(0.2)),
                            ),
                            child: Icon(
                              isCompleted
                                  ? Icons.check
                                  : (isLocked ? Icons.lock : Icons.play_arrow),
                              color: isCompleted
                                  ? Colors.black
                                  : (isLocked ? Colors.grey : color),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Lesson ${index + 1}: ${lessonTitles[index]}",
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: isLocked
                                        ? Colors.grey
                                        : Colors.white,
                                  ),
                                ),
                                Text(
                                  "${10 + index * 5} min",
                                  style: TextStyle(
                                    color: AppTheme.textGrey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isCurrent &&
                              course.status == CourseStatus.ongoing)
                            ElevatedButton(
                              onPressed: () => context.go('/battle'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: color,
                                foregroundColor: Colors.black,
                              ),
                              child: const Text("Continue"),
                            ),
                        ],
                      ),
                    ).animate().fadeIn(delay: (index * 100).ms);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
