import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';
import '../../../core/providers/user_state.dart';

// --- Domain Models ---

class CourseLevel {
  final String id;
  String title;
  String content;
  String videoUrl;
  List<CourseQuestion> questions;

  CourseLevel({
    required this.id,
    required this.title,
    this.content = '',
    this.videoUrl = '',
    List<CourseQuestion>? questions,
  }) : questions = questions ?? [];

  CourseLevel copyWith({
    String? title,
    String? content,
    String? videoUrl,
    List<CourseQuestion>? questions,
  }) {
    return CourseLevel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      videoUrl: videoUrl ?? this.videoUrl,
      questions: questions ?? this.questions,
    );
  }
}

class CourseQuestion {
  final String id;
  String text;
  List<String> options;
  int correctIndex;

  CourseQuestion({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
  });

  CourseQuestion copyWith({
    String? text,
    List<String>? options,
    int? correctIndex,
  }) {
    return CourseQuestion(
      id: id,
      text: text ?? this.text,
      options: options ?? this.options,
      correctIndex: correctIndex ?? this.correctIndex,
    );
  }
}

class InstructorCourse {
  final String id;
  final String instructorId;
  String title;
  String subtitle; // Added
  int studentCount;
  int progress;
  String duration;
  String instructorName;
  List<CourseLevel> levels;

  InstructorCourse({
    required this.id,
    this.instructorId = '',
    required this.title,
    this.subtitle = '', // Default empty
    this.studentCount = 0,
    this.progress = 0,
    this.duration = '10h',
    this.instructorName = '',
    List<CourseLevel>? levels,
  }) : levels = levels ?? [];

  InstructorCourse copyWith({
    String? title,
    String? subtitle,
    int? studentCount,
    int? progress,
    String? duration,
    String? instructorName,
    List<CourseLevel>? levels,
  }) {
    return InstructorCourse(
      id: id,
      instructorId: instructorId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      studentCount: studentCount ?? this.studentCount,
      progress: progress ?? this.progress,
      duration: duration ?? this.duration,
      instructorName: instructorName ?? this.instructorName,
      levels: levels ?? this.levels,
    );
  }
}

class GeneratedCertificate {
  final String id;
  final String studentName;
  final String courseName;
  final String templateName;
  final bool isAiGenerated;
  final DateTime createdAt;

  GeneratedCertificate({
    required this.id,
    required this.studentName,
    required this.courseName,
    required this.templateName,
    required this.isAiGenerated,
    required this.createdAt,
  });
}

class StudentProgressItem {
  final String id;
  final String studentName;
  final String courseName;
  final int progress;
  final String status;

  StudentProgressItem({
    required this.id,
    required this.studentName,
    required this.courseName,
    required this.progress,
    required this.status,
  });

  factory StudentProgressItem.fromJson(Map<String, dynamic> json) {
    return StudentProgressItem(
      id: json['id'] ?? '',
      studentName: json['studentName'] ?? '',
      courseName: json['courseName'] ?? '',
      progress: json['progress'] ?? 0,
      status: json['status'] ?? 'Active',
    );
  }
}

class AnalyticsInsights {
  final List<String> roadblocks;
  final List<String> recommendations;

  AnalyticsInsights({required this.roadblocks, required this.recommendations});

  factory AnalyticsInsights.fromJson(Map<String, dynamic> json) {
    return AnalyticsInsights(
      roadblocks: List<String>.from(json['roadblocks'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }
}

class InstructorAnalyticsData {
  final int activeCount;
  final int droppedCount;
  final int completedCount;
  final List<StudentProgressItem> students;
  final AnalyticsInsights insights;

  InstructorAnalyticsData({
    required this.activeCount,
    required this.droppedCount,
    required this.completedCount,
    required this.students,
    required this.insights,
  });

  factory InstructorAnalyticsData.fromJson(Map<String, dynamic> json) {
    return InstructorAnalyticsData(
      activeCount: json['activeCount'] ?? 0,
      droppedCount: json['droppedCount'] ?? 0,
      completedCount: json['completedCount'] ?? 0,
      students:
          (json['studentProgress'] as List?)
              ?.map((e) => StudentProgressItem.fromJson(e))
              .toList() ??
          [],
      insights: AnalyticsInsights.fromJson(json['insights'] ?? {}),
    );
  }
}

class ActivityItem {
  final String id;
  final String type;
  final String title;
  final String subtitle;
  final DateTime timestamp;

  ActivityItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timestamp,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      id: json['id'] ?? '',
      type: json['type'] ?? 'info',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

// --- State Model ---

class InstructorState {
  final List<InstructorCourse> courses;
  final List<GeneratedCertificate> certificates;
  final String name;
  final String email;
  final String institution;

  // Dashboard Stats
  final int totalStudents;
  final double averageRating;
  final int totalEnrollments;
  final double completionRate;
  final int activeCoursesCount;

  // Recent Activity
  final List<ActivityItem> recentActivity;

  // Analytics
  final InstructorAnalyticsData? analytics;

  InstructorState({
    this.courses = const [],
    this.certificates = const [],
    this.name = '',
    this.email = '',
    this.institution = 'Cognify Academy',
    this.totalStudents = 0,
    this.averageRating = 4.8,
    this.totalEnrollments = 0,
    this.completionRate = 0.0,
    this.activeCoursesCount = 0,
    this.recentActivity = const [],
    this.analytics,
  });

  InstructorState copyWith({
    List<InstructorCourse>? courses,
    List<GeneratedCertificate>? certificates,
    String? name,
    String? email,
    String? institution,
    int? totalStudents,
    double? averageRating,
    int? totalEnrollments,
    double? completionRate,
    int? activeCoursesCount,
    List<ActivityItem>? recentActivity,
    InstructorAnalyticsData? analytics,
  }) {
    return InstructorState(
      courses: courses ?? this.courses,
      certificates: certificates ?? this.certificates,
      name: name ?? this.name,
      email: email ?? this.email,
      institution: institution ?? this.institution,
      totalStudents: totalStudents ?? this.totalStudents,
      averageRating: averageRating ?? this.averageRating,
      totalEnrollments: totalEnrollments ?? this.totalEnrollments,
      completionRate: completionRate ?? this.completionRate,
      activeCoursesCount: activeCoursesCount ?? this.activeCoursesCount,
      recentActivity: recentActivity ?? this.recentActivity,
      analytics: analytics ?? this.analytics,
    );
  }
}

// --- Notifier ---

class InstructorStateNotifier extends Notifier<InstructorState> {
  @override
  InstructorState build() {
    // Sync basic info from UserState on build
    final userState = ref.watch(userStateProvider);

    // Defer fetching stats to allow build to finish
    Future.microtask(() => fetchDashboardStats());

    return InstructorState(
      name: userState.profile.name.isNotEmpty
          ? userState.profile.name
          : 'Instructor',
      email: userState.profile.id.contains('@')
          ? userState.profile.id
          : 'instructor@cognify.app',
      institution: userState.profile.institution.isNotEmpty
          ? userState.profile.institution
          : 'Cognify Academy',
      // Preserve existing mock data structure for now until real endpoints exist for everything
      courses: [], // Will be fetched from API
      certificates: [],
    );
  }

  // Helper to map backend Course to InstructorCourse
  InstructorCourse _mapCourse(Map<String, dynamic> json) {
    // Map levels if present
    List<CourseLevel> levels = [];
    if (json['levels'] != null) {
      levels = (json['levels'] as List)
          .map(
            (l) => CourseLevel(
              id: l['id'] ?? '',
              title: l['title'] ?? '',
              content: l['content'] ?? '',
              videoUrl: l['videoUrl'] ?? '',
              questions:
                  (l['questions'] as List?)?.map((q) {
                    return CourseQuestion(
                      id: q['id'] ?? 'q_mock',
                      text: q['text'] ?? 'Question',
                      options: List<String>.from(q['options'] ?? []),
                      correctIndex: q['correctIndex'] ?? 0,
                    );
                  }).toList() ??
                  [],
            ),
          )
          .toList();
    }

    return InstructorCourse(
      id: json['id'],
      instructorId: json['instructorId'] ?? '',
      title: json['title'],
      subtitle: json['subtitle'] ?? '', // Map subtitle
      studentCount: 0,
      progress: (json['progress'] ?? 0).toInt(),
      duration: json['duration'] ?? '10h',
      instructorName: json['instructorName'] ?? 'Instructor',
      levels: levels,
    );
  }

  Future<void> fetchCourses() async {
    final userState = ref.read(userStateProvider);
    final instructorId = userState.profile.id;
    if (instructorId.isEmpty) return;

    try {
      final result = await ApiService.get(
        '/api/instructor/courses?instructorId=$instructorId',
      );
      if (result['success'] == true && result['courses'] != null) {
        final List<dynamic> courseList = result['courses'];
        final courses = courseList.map((c) => _mapCourse(c)).toList();
        state = state.copyWith(courses: courses);
      }
    } catch (e) {
      debugPrint('Error fetching instructor courses: $e');
    }
  }

  Future<void> fetchDashboardStats() async {
    final userState = ref.read(userStateProvider);
    final email = userState.profile.id; // Assuming ID is email

    if (email.isEmpty) return;

    try {
      final result = await ApiService.get(
        '/api/instructor/dashboard?instructorId=$email',
      );
      if (result['success'] == true && result['data'] != null) {
        final data = result['data'];
        state = state.copyWith(
          totalStudents: data['totalStudents'] ?? state.totalStudents,
          totalEnrollments: data['totalEnrollments'] ?? state.totalEnrollments,
          activeCoursesCount: data['activeCourses'] ?? state.activeCoursesCount,
          completionRate:
              (data['completionRate'] as num?)?.toDouble() ??
              state.completionRate,
          averageRating:
              (data['averageRating'] as num?)?.toDouble() ??
              state.averageRating,
          recentActivity:
              (data['recentActivity'] as List?)
                  ?.map((e) => ActivityItem.fromJson(e))
                  .toList() ??
              state.recentActivity,
        );
        // Fetch actual courses list
        await fetchCourses();
      }
    } catch (e) {
      debugPrint('Error fetching dashboard stats: $e');
    }
  }

  Future<void> fetchAnalytics() async {
    final userState = ref.read(userStateProvider);
    final email = userState.profile.id;

    if (email.isEmpty) return;

    try {
      final result = await ApiService.get(
        '/api/instructor/analytics?instructorId=$email',
      );
      if (result['success'] == true && result['data'] != null) {
        final data = result['data'];
        state = state.copyWith(
          analytics: InstructorAnalyticsData.fromJson(data),
        );
      }
    } catch (e) {
      debugPrint('Error fetching analytics: $e');
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? institution,
  }) async {
    // Delegate to UserStateNotifier which handles API and persistence
    await ref
        .read(userStateProvider.notifier)
        .updateProfile(
          name: name,
          institution: institution,
          // email is not updateable via updateProfile usually, or handled separately
        );

    // Local state will update automatically because we watch userStateProvider in build()
  }

  // --- Course Management Methods ---

  Future<void> addCourse(String title, String subtitle) async {
    final userState = ref.read(userStateProvider);

    // Harden: Ensure we have valid user data
    var instructorId = userState.profile.id;
    var instructorName = userState.profile.name;

    if (instructorId.isEmpty) {
      // Fallback: Try to get from SharedPrefs directly
      try {
        final prefs = await SharedPreferences.getInstance();
        instructorId =
            prefs.getString('profile_id') ??
            prefs.getString('user_email') ??
            '';
        instructorName = prefs.getString('profile_name') ?? 'Instructor';
      } catch (e) {
        debugPrint('Error accessing SharedPrefs: $e');
      }
    }

    if (instructorId.isEmpty) {
      debugPrint('Error: Cannot create course without Instructor ID');
      return;
    }

    final newCourseData = {
      'title': title,
      'subtitle': subtitle, // Send subtitle
      'instructorId': instructorId,
      'instructorName': instructorName.isNotEmpty
          ? instructorName
          : 'Unknown Instructor',
      'duration': '10h', // Default duration
      'progress': 0, // Initialize progress
      'levels': [],
    };

    debugPrint('Creating course with payload: $newCourseData');

    try {
      final result = await ApiService.post('/api/courses', newCourseData);
      if (result['success'] == true) {
        // Refresh courses
        await fetchCourses();
      }
    } catch (e) {
      debugPrint('Error creating course: $e');
    }
  }

  Future<void> updateCourse(
    String courseId,
    InstructorCourse updatedCourse,
  ) async {
    // Map Frontend InstructorCourse back to Backend Course model structure
    final courseData = {
      'id': updatedCourse.id,
      'instructorId': updatedCourse.instructorId, // CRITICAL FIX: Include ID
      'title': updatedCourse.title,
      'progress': updatedCourse.progress,
      'instructorName': updatedCourse.instructorName, // Ensure this isn't lost
      'duration': updatedCourse.duration, // Ensure this isn't lost
      // Map levels and embedded questions
      'levels': updatedCourse.levels.map((l) {
        return {
          'id': l.id,
          'title': l.title,
          'content': l.content,
          'videoUrl': l.videoUrl,
          'questions': l.questions.map((q) {
            return {
              'id': q.id,
              'text': q.text,
              'options': q.options,
              'correctIndex': q.correctIndex,
              // Add default values for backend Question fields not in frontend yet
              'difficulty': 'Medium',
              'topic': updatedCourse.title,
              'points': 10,
              'timeLimit': 30,
            };
          }).toList(),
        };
      }).toList(),
    };

    try {
      final result = await ApiService.put('/api/courses', courseData);
      if (result['success'] == true) {
        // We could just update local state instead of re-fetching to be snappier,
        // but re-fetching ensures sync. Let's do optimistic update + fetch.
        state = state.copyWith(
          courses: state.courses
              .map((c) => c.id == courseId ? updatedCourse : c)
              .toList(),
        );
        // await fetchCourses(); // Optional: uncomment if we trust backend more
      }
    } catch (e) {
      debugPrint('Error updating course: $e');
    }
  }

  void addLevelToCourse(String courseId) {
    InstructorCourse? updatedCourse;
    final courses = state.courses.map((c) {
      if (c.id == courseId) {
        final newLevel = CourseLevel(
          id: 'l${c.levels.length + 1}', // In real app, maybe use UUID
          title: 'Module ${c.levels.length + 1}',
        );
        updatedCourse = c.copyWith(levels: [...c.levels, newLevel]);
        return updatedCourse!;
      }
      return c;
    }).toList();

    // Update local state first (optimistic)
    state = state.copyWith(courses: courses);

    // Persist
    if (updatedCourse != null) {
      updateCourse(courseId, updatedCourse!);
    }
  }

  void updateLevel(String courseId, String levelId, CourseLevel updatedLevel) {
    InstructorCourse? updatedCourse;
    final courses = state.courses.map((c) {
      if (c.id == courseId) {
        updatedCourse = c.copyWith(
          levels: c.levels
              .map((l) => l.id == levelId ? updatedLevel : l)
              .toList(),
        );
        return updatedCourse!;
      }
      return c;
    }).toList();
    state = state.copyWith(courses: courses);

    if (updatedCourse != null) {
      updateCourse(courseId, updatedCourse!);
    }
  }

  void addQuestionToLevel(
    String courseId,
    String levelId,
    CourseQuestion question,
  ) {
    InstructorCourse? updatedCourse;
    final courses = state.courses.map((c) {
      if (c.id == courseId) {
        updatedCourse = c.copyWith(
          levels: c.levels.map((l) {
            if (l.id == levelId) {
              return l.copyWith(questions: [...l.questions, question]);
            }
            return l;
          }).toList(),
        );
        return updatedCourse!;
      }
      return c;
    }).toList();
    state = state.copyWith(courses: courses);

    if (updatedCourse != null) {
      updateCourse(courseId, updatedCourse!);
    }
  }

  void updateQuestion(
    String courseId,
    String levelId,
    String questionId,
    CourseQuestion updatedQuestion,
  ) {
    InstructorCourse? updatedCourse;
    final courses = state.courses.map((c) {
      if (c.id == courseId) {
        updatedCourse = c.copyWith(
          levels: c.levels.map((l) {
            if (l.id == levelId) {
              return l.copyWith(
                questions: l.questions
                    .map((q) => q.id == questionId ? updatedQuestion : q)
                    .toList(),
              );
            }
            return l;
          }).toList(),
        );
        return updatedCourse!;
      }
      return c;
    }).toList();
    state = state.copyWith(courses: courses);

    if (updatedCourse != null) {
      updateCourse(courseId, updatedCourse!);
    }
  }

  void addCertificate(GeneratedCertificate cert) {
    state = state.copyWith(certificates: [...state.certificates, cert]);
  }

  Future<void> generateCertificate({
    required String studentName,
    required String courseName,
    required String templateName,
    required bool isAiGenerated,
  }) async {
    final userState = ref.read(userStateProvider);
    final instructorId = userState.profile.id;

    try {
      final result = await ApiService.post(
        '/api/instructor/certificate/generate',
        {
          'userId': instructorId,
          'userName': studentName,
          'courseName': courseName,
          'courseId':
              'course_${DateTime.now().millisecondsSinceEpoch}', // Mock course ID
          'template':
              templateName, // Pass template preference if backend supports it
        },
      );

      if (result['success'] == true && result['data'] != null) {
        // Parse returned certificate
        // Adjust based on actual backend response structure
        // For now constructing from inputs + ID if needed
        final certData = result['data'];
        final newCert = GeneratedCertificate(
          id:
              certData['id'] ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          studentName: studentName,
          courseName: courseName,
          templateName: templateName,
          isAiGenerated: isAiGenerated,
          createdAt: DateTime.now(),
        );
        addCertificate(newCert);
      }
    } catch (e) {
      debugPrint('Error generating certificate: $e');
      // Fallback for demo if backend fails or is WIP
      final fallbackCert = GeneratedCertificate(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        studentName: studentName,
        courseName: courseName,
        templateName: templateName,
        isAiGenerated: isAiGenerated,
        createdAt: DateTime.now(),
      );
      addCertificate(fallbackCert);
    }
  }
}

final instructorStateProvider =
    NotifierProvider<InstructorStateNotifier, InstructorState>(
      InstructorStateNotifier.new,
    );

// Selected course provider for editing
final selectedCourseIdProvider = StateProvider<String?>((ref) => null);
final selectedLevelIdProvider = StateProvider<String?>((ref) => null);

// Track if user is in instructor mode (for forum author detection)
final isInstructorModeProvider = StateProvider<bool>((ref) => false);
