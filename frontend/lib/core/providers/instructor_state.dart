import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  String title;
  int studentCount;
  int progress;
  List<CourseLevel> levels;

  InstructorCourse({
    required this.id,
    required this.title,
    this.studentCount = 0,
    this.progress = 0,
    List<CourseLevel>? levels,
  }) : levels = levels ?? [];

  InstructorCourse copyWith({
    String? title,
    int? studentCount,
    int? progress,
    List<CourseLevel>? levels,
  }) {
    return InstructorCourse(
      id: id,
      title: title ?? this.title,
      studentCount: studentCount ?? this.studentCount,
      progress: progress ?? this.progress,
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

class InstructorState {
  final List<InstructorCourse> courses;
  final List<GeneratedCertificate> certificates;
  final String name;
  final String email;
  final String institution;

  InstructorState({
    this.courses = const [],
    this.certificates = const [],
    this.name = 'Dr. Educator',
    this.email = 'educator@cognify.app',
    this.institution = 'Cognify Academy',
  });

  InstructorState copyWith({
    List<InstructorCourse>? courses,
    List<GeneratedCertificate>? certificates,
    String? name,
    String? email,
    String? institution,
  }) {
    return InstructorState(
      courses: courses ?? this.courses,
      certificates: certificates ?? this.certificates,
      name: name ?? this.name,
      email: email ?? this.email,
      institution: institution ?? this.institution,
    );
  }
}

class InstructorStateNotifier extends Notifier<InstructorState> {
  @override
  InstructorState build() {
    return InstructorState(
      courses: [
        InstructorCourse(
          id: '1',
          title: 'Flutter Mastery',
          studentCount: 24,
          progress: 85,
          levels: [
            CourseLevel(
              id: 'l1',
              title: 'Introduction to Flutter',
              content: 'Welcome to Flutter! In this module...',
              videoUrl: 'https://youtu.be/dQw4w9WgXcQ?si=6nY71hrAFC8hTrMh',
              questions: [
                CourseQuestion(
                  id: 'q1',
                  text: 'What is Flutter?',
                  options: ['A bird', 'A UI toolkit', 'A database', 'A server'],
                  correctIndex: 1,
                ),
              ],
            ),
            CourseLevel(
              id: 'l2',
              title: 'Widgets Basics',
              content: 'Everything in Flutter is a widget...',
            ),
          ],
        ),
        InstructorCourse(
          id: '2',
          title: 'Dart Fundamentals',
          studentCount: 156,
          progress: 92,
        ),
        InstructorCourse(
          id: '3',
          title: 'State Management Pro',
          studentCount: 89,
          progress: 78,
        ),
      ],
      certificates: [
        GeneratedCertificate(
          id: 'c1',
          studentName: 'John Doe',
          courseName: 'Flutter Mastery',
          templateName: 'Classic',
          isAiGenerated: false,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        GeneratedCertificate(
          id: 'c2',
          studentName: 'Jane Smith',
          courseName: 'Dart Basics',
          templateName: 'Tech',
          isAiGenerated: true,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ],
    );
  }

  void addCourse(String title) {
    final newCourse = InstructorCourse(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      levels: [CourseLevel(id: 'l1', title: 'Module 1')],
    );
    state = state.copyWith(courses: [...state.courses, newCourse]);
  }

  void updateCourse(String courseId, InstructorCourse updatedCourse) {
    state = state.copyWith(
      courses: state.courses
          .map((c) => c.id == courseId ? updatedCourse : c)
          .toList(),
    );
  }

  void addLevelToCourse(String courseId) {
    final courses = state.courses.map((c) {
      if (c.id == courseId) {
        final newLevel = CourseLevel(
          id: 'l${c.levels.length + 1}',
          title: 'Module ${c.levels.length + 1}',
        );
        return c.copyWith(levels: [...c.levels, newLevel]);
      }
      return c;
    }).toList();
    state = state.copyWith(courses: courses);
  }

  void updateLevel(String courseId, String levelId, CourseLevel updatedLevel) {
    final courses = state.courses.map((c) {
      if (c.id == courseId) {
        return c.copyWith(
          levels: c.levels
              .map((l) => l.id == levelId ? updatedLevel : l)
              .toList(),
        );
      }
      return c;
    }).toList();
    state = state.copyWith(courses: courses);
  }

  void addQuestionToLevel(
    String courseId,
    String levelId,
    CourseQuestion question,
  ) {
    final courses = state.courses.map((c) {
      if (c.id == courseId) {
        return c.copyWith(
          levels: c.levels.map((l) {
            if (l.id == levelId) {
              return l.copyWith(questions: [...l.questions, question]);
            }
            return l;
          }).toList(),
        );
      }
      return c;
    }).toList();
    state = state.copyWith(courses: courses);
  }

  void updateQuestion(
    String courseId,
    String levelId,
    String questionId,
    CourseQuestion updatedQuestion,
  ) {
    final courses = state.courses.map((c) {
      if (c.id == courseId) {
        return c.copyWith(
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
      }
      return c;
    }).toList();
    state = state.copyWith(courses: courses);
  }

  void addCertificate(GeneratedCertificate cert) {
    state = state.copyWith(certificates: [...state.certificates, cert]);
  }

  void updateProfile({String? name, String? email, String? institution}) {
    state = state.copyWith(
      name: name ?? state.name,
      email: email ?? state.email,
      institution: institution ?? state.institution,
    );
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
