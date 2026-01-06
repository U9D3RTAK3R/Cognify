import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CourseStatus { available, enrolled, ongoing, completed }

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
  final int duration; // in hours

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
    this.duration = 5,
  });

  Course copyWith({CourseStatus? status, double? progress}) {
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
    );
  }
}

class ExploreState {
  final List<Course> courses;
  final String filter; // all, enrolled, ongoing, completed

  ExploreState({required this.courses, this.filter = 'all'});

  ExploreState copyWith({List<Course>? courses, String? filter}) {
    return ExploreState(
      courses: courses ?? this.courses,
      filter: filter ?? this.filter,
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
}

class ExploreController extends Notifier<ExploreState> {
  @override
  ExploreState build() {
    return ExploreState(
      courses: [
        Course(
          id: '1',
          title: 'Flutter Mastery',
          subtitle: 'Build beautiful apps',
          emoji: '🚀',
          colorHex: '0xFF00F5FF',
          progress: 0.65,
          status: CourseStatus.ongoing,
          price: 49.99,
          instructor: 'John Flutter',
          lessons: 24,
          duration: 12,
        ),
        Course(
          id: '2',
          title: 'AI Basics',
          subtitle: 'Machine Learning 101',
          emoji: '🤖',
          colorHex: '0xFFBF00FF',
          progress: 0.0,
          status: CourseStatus.available,
          price: 79.99,
          instructor: 'AI Master',
          lessons: 18,
          duration: 8,
        ),
        Course(
          id: '3',
          title: 'Web Development',
          subtitle: 'HTML, CSS, JS',
          emoji: '🌐',
          colorHex: '0xFFFF00A0',
          progress: 1.0,
          status: CourseStatus.completed,
          price: 39.99,
          instructor: 'Web Wizard',
          lessons: 30,
          duration: 15,
        ),
        Course(
          id: '4',
          title: 'Data Science',
          subtitle: 'Python & Stats',
          emoji: '📊',
          colorHex: '0xFF00FF7F',
          progress: 0.3,
          status: CourseStatus.ongoing,
          price: 89.99,
          instructor: 'Data Guru',
          lessons: 22,
          duration: 10,
        ),
        Course(
          id: '5',
          title: 'Cybersecurity',
          subtitle: 'Ethical Hacking',
          emoji: '🔐',
          colorHex: '0xFFFF6B35',
          progress: 0.0,
          status: CourseStatus.available,
          price: 99.99,
          instructor: 'Sec Expert',
          lessons: 20,
          duration: 12,
        ),
        Course(
          id: '6',
          title: 'Mobile Design',
          subtitle: 'UI/UX Principles',
          emoji: '🎨',
          colorHex: '0xFFE040FB',
          progress: 0.0,
          status: CourseStatus.enrolled,
          price: 59.99,
          instructor: 'Design Pro',
          lessons: 16,
          duration: 6,
        ),
      ],
    );
  }

  void setFilter(String filter) {
    state = state.copyWith(filter: filter);
  }

  void enrollCourse(String courseId) {
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
