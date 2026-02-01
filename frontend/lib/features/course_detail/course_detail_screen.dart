import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';
import '../explore/data/explore_state.dart';

// Course level model for API data
class ApiCourseLevel {
  final String id;
  final String title;
  final String content;
  final String videoUrl;
  final List<String> questionIds;

  ApiCourseLevel({
    required this.id,
    required this.title,
    this.content = '',
    this.videoUrl = '',
    this.questionIds = const [],
  });

  factory ApiCourseLevel.fromJson(Map<String, dynamic> json) {
    var qIds = <String>[];
    if (json['questions'] != null) {
      final list = json['questions'] as List;
      if (list.isNotEmpty) {
        if (list.first is String) {
          qIds = List<String>.from(list);
        } else {
          // It's likely a Map (object), extract IDs
          qIds = list
              .map((q) {
                if (q is Map) {
                  return (q['id'] ?? '').toString();
                }
                return '';
              })
              .where((s) => s.isNotEmpty)
              .toList();
        }
      }
    }

    return ApiCourseLevel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      questionIds: qIds,
    );
  }
}

class CourseDetailScreen extends ConsumerStatefulWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  List<ApiCourseLevel> _levels = [];
  bool _isLoadingLevels = true;

  @override
  void initState() {
    super.initState();
    _fetchCourseLevels();
  }

  Future<void> _fetchCourseLevels() async {
    try {
      final response = await ApiService.get(
        '/api/course?id=${widget.courseId}',
      );
      if (!mounted) return;
      if (response['success'] == true && response['course'] != null) {
        final course = response['course'];
        final levels = List<Map<String, dynamic>>.from(course['levels'] ?? []);
        setState(() {
          _levels = levels.map((l) => ApiCourseLevel.fromJson(l)).toList();
          _isLoadingLevels = false;
        });
      } else {
        setState(() => _isLoadingLevels = false);
      }
    } catch (e) {
      debugPrint('Error fetching course levels: $e');
      if (mounted) {
        setState(() => _isLoadingLevels = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(exploreProvider.notifier);
    final course = controller.getCourseById(widget.courseId);

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

    // Safely parse color
    Color color;
    try {
      String hex = course.colorHex;
      if (hex.startsWith('#')) {
        hex = hex.replaceFirst('#', '0xFF');
      } else if (!hex.startsWith('0x') && !hex.startsWith('0X')) {
        hex = '0xFF$hex';
      }
      color = Color(int.parse(hex));
    } catch (e) {
      color = AppTheme.primaryCyan;
    }

    return Scaffold(
      backgroundColor: AppTheme.bgBlack,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppTheme.cardColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.go('/explore'),
            ),
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
                        _levels.isNotEmpty
                            ? '${_levels.length} lessons'
                            : '${course.lessons} lessons',
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
                        course.duration,
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
                  _buildActionButton(course, color, controller),

                  const SizedBox(height: 24),

                  // Progress (for ongoing/completed)
                  if (course.status == CourseStatus.ongoing ||
                      course.status == CourseStatus.completed)
                    _buildProgressSection(course, color),

                  const SizedBox(height: 24),

                  // Lessons/Levels
                  Text(
                    "LESSONS",
                    style: AppTheme.labelLarge.copyWith(color: color),
                  ),
                  const SizedBox(height: 12),

                  _buildLessonsList(course, color),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    Course course,
    Color color,
    ExploreController controller,
  ) {
    if (course.status == CourseStatus.available) {
      return Container(
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
                Text("Price", style: TextStyle(color: AppTheme.textGrey)),
                Text(
                  "\$${course.price}",
                  style: AppTheme.headlineMedium.copyWith(
                    color: AppTheme.primaryCyan,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                await controller.enrollCourse(course.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Course enrolled! (Payment simulated)"),
                    ),
                  );
                  setState(() {}); // Refresh UI
                }
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
      );
    } else if (course.status == CourseStatus.enrolled && _levels.isNotEmpty) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // Navigate to first level
            context.push(
              '/course/${widget.courseId}/level/${_levels.first.id}',
              extra: {'levelTitle': _levels.first.title},
            );
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
      );
    } else if (course.status == CourseStatus.completed) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _showCertificateDialog(course),
          icon: const Icon(Icons.workspace_premium),
          label: const Text("GENERATE CERTIFICATE"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildProgressSection(Course course, Color color) {
    return Container(
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
                style: AppTheme.headlineMedium.copyWith(color: color),
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
    ).animate().fadeIn();
  }

  Widget _buildLessonsList(Course course, Color color) {
    if (_isLoadingLevels) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_levels.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.dashboard_customize,
                size: 48,
                color: Colors.grey.shade800,
              ),
              const SizedBox(height: 16),
              Text(
                "No lessons added yet",
                style: TextStyle(color: AppTheme.textGrey),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: List.generate(_levels.length, (index) {
        final level = _levels[index];
        final isCompleted = course.progress > (index + 1) / _levels.length;
        final isCurrent =
            course.progress >= index / _levels.length &&
            course.progress < (index + 1) / _levels.length;
        final isLocked = course.status == CourseStatus.available;

        return GestureDetector(
          onTap: isLocked
              ? null
              : () {
                  context.push(
                    '/course/${widget.courseId}/level/${level.id}',
                    extra: {'levelTitle': level.title},
                  );
                },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCurrent ? color.withOpacity(0.1) : AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isCurrent ? color : Colors.transparent),
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
                        "Lesson ${index + 1}: ${level.title}",
                        style: AppTheme.bodyMedium.copyWith(
                          color: isLocked ? Colors.grey : Colors.white,
                        ),
                      ),
                      Text(
                        level.questionIds.isNotEmpty
                            ? "${level.questionIds.length} questions"
                            : "Reading & Video",
                        style: TextStyle(
                          color: AppTheme.textGrey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLocked) Icon(Icons.chevron_right, color: color),
              ],
            ),
          ),
        ).animate().fadeIn(delay: (index * 100).ms);
      }),
    );
  }

  void _showCertificateDialog(Course course) {
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
                border: Border.all(color: AppTheme.primaryCyan, width: 2),
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
                    style: AppTheme.headlineMedium.copyWith(
                      color: AppTheme.primaryCyan,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Awarded to: Cyber Ninja",
                    style: TextStyle(color: Colors.white70),
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
  }
}
