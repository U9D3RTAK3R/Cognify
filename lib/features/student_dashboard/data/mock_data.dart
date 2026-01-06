class Course {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final String colorHex;
  final double progress;

  Course({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.colorHex,
    required this.progress,
  });
}

class MockData {
  static final Course activeCourse = Course(
    id: "1",
    title: "Flutter Mastery",
    subtitle: "Build beautiful apps",
    emoji: "🚀",
    colorHex: "0xFF00F5FF",
    progress: 0.65,
  );

  static final List<Course> trendingCourses = [
    Course(
      id: "2",
      title: "AI Basics",
      subtitle: "Machine Learning 101",
      emoji: "🤖",
      colorHex: "0xFFBF00FF",
      progress: 0.3,
    ),
    Course(
      id: "3",
      title: "Web Dev",
      subtitle: "HTML, CSS, JS",
      emoji: "🌐",
      colorHex: "0xFFFF00A0",
      progress: 0.8,
    ),
    Course(
      id: "4",
      title: "Data Science",
      subtitle: "Python & Stats",
      emoji: "📊",
      colorHex: "0xFF00FF7F",
      progress: 0.45,
    ),
  ];
}
