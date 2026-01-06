import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import 'data/explore_state.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exploreState = ref.watch(exploreProvider);
    final controller = ref.read(exploreProvider.notifier);
    final filters = ['All', 'Enrolled', 'Ongoing', 'Completed'];

    return Scaffold(
      backgroundColor: AppTheme.bgBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Explore Quests", style: AppTheme.headlineMedium),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final filter = filters[index];
                final isSelected = exploreState.filter == filter.toLowerCase();
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) =>
                        controller.setFilter(filter.toLowerCase()),
                    selectedColor: AppTheme.primaryCyan,
                    backgroundColor: AppTheme.cardColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: exploreState.filteredCourses.length,
              itemBuilder: (context, index) {
                final course = exploreState.filteredCourses[index];
                return _CourseListItem(
                      course: course,
                      onTap: () => context.go('/course/${course.id}'),
                    )
                    .animate()
                    .fadeIn(delay: (index * 50).ms)
                    .slideX(begin: 0.1, end: 0);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseListItem extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;

  const _CourseListItem({required this.course, required this.onTap});

  String _getStatusLabel() {
    switch (course.status) {
      case CourseStatus.available:
        return '\$${course.price.toStringAsFixed(0)}';
      case CourseStatus.enrolled:
        return 'START';
      case CourseStatus.ongoing:
        return '${(course.progress * 100).toInt()}%';
      case CourseStatus.completed:
        return '✓ DONE';
    }
  }

  Color _getStatusColor() {
    switch (course.status) {
      case CourseStatus.available:
        return AppTheme.accentPurple;
      case CourseStatus.enrolled:
        return AppTheme.primaryCyan;
      case CourseStatus.ongoing:
        return Colors.orange;
      case CourseStatus.completed:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(course.colorHex));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(course.emoji, style: const TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course.subtitle,
                    style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person, size: 14, color: AppTheme.textGrey),
                      const SizedBox(width: 4),
                      Text(
                        course.instructor,
                        style: TextStyle(
                          color: AppTheme.textGrey,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.book, size: 14, color: AppTheme.textGrey),
                      const SizedBox(width: 4),
                      Text(
                        '${course.lessons} lessons',
                        style: TextStyle(
                          color: AppTheme.textGrey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  if (course.status == CourseStatus.ongoing) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: course.progress,
                        backgroundColor: Colors.black,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getStatusColor()),
              ),
              child: Text(
                _getStatusLabel(),
                style: TextStyle(
                  color: _getStatusColor(),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
