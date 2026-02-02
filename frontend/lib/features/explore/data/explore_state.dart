import 'dart:convert';
import 'package:cognify/core/config/api_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../core/providers/user_state.dart';

enum CourseStatus { available, enrolled, ongoing, completed }

class AIRecommendation {
  final String courseId;
  final String reason;

  AIRecommendation({required this.courseId, required this.reason});

  factory AIRecommendation.fromJson(Map<String, dynamic> json) {
    return AIRecommendation(
      courseId: json['courseId'] ?? '',
      reason: json['reason'] ?? '',
    );
  }
}

class Course {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final String colorHex;
  final double progress;
  final CourseStatus status;
  final double price;
  final String instructor;
  final int lessons;
  final String duration; // e.g. "10h"
  final String? recommendationReason; // Populated if recommended
  final int difficultyRating; // 1-5 scale

  Course({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.colorHex,
    required this.progress,
    required this.status,
    this.price = 0,
    this.instructor = 'Unknown',
    this.lessons = 10,
    this.duration = '5h',
    this.recommendationReason,
    this.difficultyRating = 3,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Untitled',
      subtitle: json['subtitle'] ?? '',
      emoji: json['emoji'] ?? '📚',
      colorHex: json['colorHex'] ?? '0xFF00F5FF',
      progress: (json['progress'] ?? 0.0).toDouble(),
      status: CourseStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['status'] ?? 'available'),
        orElse: () => CourseStatus.available,
      ),
      price: (json['price'] ?? 0).toDouble(),
      instructor:
          (json['instructorName'] != null &&
              json['instructorName'].toString().isNotEmpty)
          ? json['instructorName']
          : 'Unknown Instructor',
      lessons: (json['levels'] as List?)?.length ?? 0,
      duration:
          (json['duration'] != null && json['duration'].toString().isNotEmpty)
          ? json['duration']
          : '5h',
      difficultyRating: json['difficultyRating'] ?? 3,
    );
  }

  Course copyWith({
    CourseStatus? status,
    double? progress,
    String? recommendationReason,
    int? difficultyRating,
  }) {
    return Course(
      id: id,
      title: title,
      subtitle: subtitle,
      emoji: emoji,
      colorHex: colorHex,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      price: price,
      instructor: instructor,
      lessons: lessons,
      duration: duration,
      recommendationReason: recommendationReason ?? this.recommendationReason,
      difficultyRating: difficultyRating ?? this.difficultyRating,
    );
  }
}

class ExploreState {
  final List<Course> courses;
  final List<AIRecommendation> recommendations;
  final String filter; // all, enrolled, ongoing, completed
  final bool isLoading;

  ExploreState({
    required this.courses,
    this.recommendations = const [],
    this.filter = 'all',
    this.isLoading = false,
  });

  ExploreState copyWith({
    List<Course>? courses,
    List<AIRecommendation>? recommendations,
    String? filter,
    bool? isLoading,
  }) {
    return ExploreState(
      courses: courses ?? this.courses,
      recommendations: recommendations ?? this.recommendations,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  List<Course> get filteredCourses {
    if (filter == 'all') return courses;
    if (filter == 'enrolled')
      return courses.where((c) => c.status != CourseStatus.available).toList();
    if (filter == 'ongoing')
      return courses.where((c) => c.status == CourseStatus.ongoing).toList();
    if (filter == 'completed')
      return courses.where((c) => c.status == CourseStatus.completed).toList();
    return courses;
  }

  List<Course> get recommendedCourses {
    // Map recommendations to actual course objects
    List<Course> recs = [];
    for (var r in recommendations) {
      try {
        final course = courses.firstWhere((c) => c.id == r.courseId);
        recs.add(course.copyWith(recommendationReason: r.reason));
      } catch (_) {}
    }
    return recs;
  }
}

class ExploreController extends Notifier<ExploreState> {
  @override
  ExploreState build() {
    // Initial fetch
    Future.microtask(() => _fetchData());
    return ExploreState(courses: [], isLoading: true);
  }

  Future<void> _fetchData() async {
    state = state.copyWith(isLoading: true);
    await _fetchCourses();
    await _fetchEnrollments(); // Sync enrollment status from backend
    await _fetchRecommendations();
    state = state.copyWith(isLoading: false);
  }

  Future<void> _fetchCourses() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.apiUrl}/courses'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Assuming API returns { "courses": [...] } or direct list. Main.go says GetCoursesHandler.
        // Usually wrapped in success or list.
        // Let's assume list for now or check handler implementation.
        // Assuming array of courses for now based on standard impl, or Wrapped.
        // Wait, boilerplate handler usually returns JSON map.
        // If `respondJSON(w, http.StatusOK, courses)` -> it's a list.
        // If `respondJSON(w, http.StatusOK, map[string]interface{"courses": courses})` -> it's wrapped.
        // I'll assume wrapped "courses" or check user's other handlers.

        List<dynamic> list = [];
        if (data is Map && data.containsKey('courses')) {
          list = data['courses'];
        } else if (data is List) {
          list = data;
        }

        final courses = list.map((c) => Course.fromJson(c)).toList();
        state = state.copyWith(courses: courses);
      }
    } catch (e) {
      print("Error fetching courses: $e");
    }
  }

  Future<void> _fetchRecommendations() async {
    final userId = ref.read(userStateProvider).profile.id;
    if (userId.isEmpty) return;

    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.apiUrl}/courses/recommendations?userId=$userId',
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['recommendations'] != null) {
          final list = data['recommendations'] as List;
          final recs = list.map((r) => AIRecommendation.fromJson(r)).toList();
          state = state.copyWith(recommendations: recs);
        }
      }
    } catch (e) {
      print("Error fetching recommendations: $e");
    }
  }

  void setFilter(String filter) {
    state = state.copyWith(filter: filter);
  }

  Future<void> _fetchEnrollments() async {
    final userId = ref.read(userStateProvider).profile.id;
    if (userId.isEmpty) return;

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.apiUrl}/user/enrollments?userId=$userId'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['enrollments'] != null) {
          final enrollments = List<Map<String, dynamic>>.from(
            data['enrollments'],
          );

          // Update course statuses based on enrollments
          state = state.copyWith(
            courses: state.courses.map((c) {
              final enrollment = enrollments.firstWhere(
                (e) => e['courseId'] == c.id,
                orElse: () => <String, dynamic>{},
              );
              if (enrollment.isNotEmpty) {
                final progress = (enrollment['progress'] ?? 0.0).toDouble();
                final completed = enrollment['completed'] == true;

                CourseStatus newStatus;
                if (completed) {
                  newStatus = CourseStatus.completed;
                } else if (progress > 0) {
                  newStatus = CourseStatus.ongoing;
                } else {
                  newStatus = CourseStatus.enrolled;
                }

                return c.copyWith(status: newStatus, progress: progress);
              }
              return c;
            }).toList(),
          );
        }
      }
    } catch (e) {
      print("Error fetching enrollments: $e");
    }
  }

  Future<void> enrollCourse(String courseId) async {
    final userId = ref.read(userStateProvider).profile.id;

    // Call backend API to enroll
    try {
      await http.post(
        Uri.parse('${ApiConfig.apiUrl}/courses/enroll'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId, 'courseId': courseId}),
      );
    } catch (e) {
      print("Error enrolling course: $e");
    }

    // Update local state
    state = state.copyWith(
      courses: state.courses.map((c) {
        if (c.id == courseId && c.status == CourseStatus.available) {
          return c.copyWith(status: CourseStatus.enrolled);
        }
        return c;
      }).toList(),
    );
  }

  void startCourse(String courseId) {
    state = state.copyWith(
      courses: state.courses.map((c) {
        if (c.id == courseId && c.status == CourseStatus.enrolled) {
          return c.copyWith(status: CourseStatus.ongoing, progress: 0.1);
        }
        return c;
      }).toList(),
    );
  }

  void completeCourse(String courseId) {
    state = state.copyWith(
      courses: state.courses.map((c) {
        if (c.id == courseId) {
          return c.copyWith(status: CourseStatus.completed, progress: 1.0);
        }
        return c;
      }).toList(),
    );
  }

  Course? getCourseById(String id) {
    try {
      return state.courses.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}

final exploreProvider = NotifierProvider<ExploreController, ExploreState>(
  ExploreController.new,
);
