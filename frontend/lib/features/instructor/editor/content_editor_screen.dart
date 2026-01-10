import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/instructor_state.dart';

class ContentEditorScreen extends ConsumerStatefulWidget {
  const ContentEditorScreen({super.key});

  @override
  ConsumerState<ContentEditorScreen> createState() =>
      _ContentEditorScreenState();
}

class _ContentEditorScreenState extends ConsumerState<ContentEditorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _contentController = TextEditingController();
  final _videoUrlController = TextEditingController();
  bool _isGeneratingQuestions = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _contentController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  InstructorCourse? _getCurrentCourse(WidgetRef ref) {
    final courseId = ref.watch(selectedCourseIdProvider);
    if (courseId == null) return null;
    final state = ref.watch(instructorStateProvider);
    return state.courses.firstWhere(
      (c) => c.id == courseId,
      orElse: () => state.courses.first,
    );
  }

  CourseLevel? _getCurrentLevel(WidgetRef ref, InstructorCourse course) {
    final levelId = ref.watch(selectedLevelIdProvider);
    if (levelId == null) return null;
    return course.levels.firstWhere(
      (l) => l.id == levelId,
      orElse: () => course.levels.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final course = _getCurrentCourse(ref);
    if (course == null) {
      return Scaffold(
        backgroundColor: AppTheme.bgBlack,
        appBar: AppBar(
          title: const Text('Course Editor'),
          backgroundColor: Colors.transparent,
        ),
        body: const Center(
          child: Text(
            'No course selected',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final selectedLevelId = ref.watch(selectedLevelIdProvider);
    final currentLevel = selectedLevelId != null
        ? _getCurrentLevel(ref, course)
        : null;

    // If a level is selected, show the level editor
    if (currentLevel != null) {
      _contentController.text = currentLevel.content;
      _videoUrlController.text = currentLevel.videoUrl;
      return _buildLevelEditor(context, course, currentLevel);
    }

    // Otherwise show the list of levels
    return _buildLevelsList(context, course);
  }

  Widget _buildLevelsList(BuildContext context, InstructorCourse course) {
    return Scaffold(
      backgroundColor: AppTheme.bgBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(course.title, style: AppTheme.headlineMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.orange),
            onPressed: () {
              ref
                  .read(instructorStateProvider.notifier)
                  .addLevelToCourse(course.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('New level added!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: course.levels.length,
        itemBuilder: (context, index) {
          final level = course.levels[index];
          return GestureDetector(
            onTap: () {
              ref.read(selectedLevelIdProvider.notifier).state = level.id;
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          level.title,
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${level.content.isNotEmpty ? "Content ✓" : "No content"} • ${level.questions.length} questions',
                          style: TextStyle(
                            color: AppTheme.textGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Colors.orange,
                      size: 20,
                    ),
                    onPressed: () => _showRenameLevelDialog(course, level),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1, end: 0),
          );
        },
      ),
    );
  }

  Widget _buildLevelEditor(
    BuildContext context,
    InstructorCourse course,
    CourseLevel level,
  ) {
    return Scaffold(
      backgroundColor: AppTheme.bgBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            ref.read(selectedLevelIdProvider.notifier).state = null;
          },
        ),
        title: GestureDetector(
          onTap: () => _showRenameLevelDialog(course, level),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(level.title, style: AppTheme.headlineMedium),
              const SizedBox(width: 8),
              const Icon(Icons.edit, color: Colors.orange, size: 16),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _saveLevel(course, level),
            icon: const Icon(Icons.save, color: Colors.orange),
            label: const Text('Save', style: TextStyle(color: Colors.orange)),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.orange,
          labelColor: Colors.orange,
          unselectedLabelColor: AppTheme.textGrey,
          tabs: const [
            Tab(icon: Icon(Icons.text_fields), text: 'Content'),
            Tab(icon: Icon(Icons.video_library), text: 'Video'),
            Tab(icon: Icon(Icons.quiz), text: 'Questions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildContentTab(),
          _buildVideoTab(),
          _buildQuestionsTab(course, level),
        ],
      ),
    );
  }

  Widget _buildContentTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MODULE CONTENT',
            style: AppTheme.labelLarge.copyWith(color: Colors.orange),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TextField(
              controller: _contentController,
              style: const TextStyle(color: Colors.white, height: 1.6),
              maxLines: null,
              expands: true,
              decoration: InputDecoration(
                hintText: 'Write your course content here...',
                hintStyle: TextStyle(color: AppTheme.textGrey),
                filled: true,
                fillColor: AppTheme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VIDEO EMBED',
            style: AppTheme.labelLarge.copyWith(color: Colors.orange),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _videoUrlController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'YouTube URL',
              labelStyle: TextStyle(color: AppTheme.textGrey),
              prefixIcon: const Icon(Icons.link, color: Colors.orange),
              filled: true,
              fillColor: AppTheme.cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'PREVIEW',
            style: AppTheme.labelLarge.copyWith(color: Colors.orange),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.withOpacity(0.5)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.red,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Video Preview',
                    style: TextStyle(color: AppTheme.textGrey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsTab(InstructorCourse course, CourseLevel level) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LEVEL QUESTIONS',
                style: AppTheme.labelLarge.copyWith(color: Colors.orange),
              ),
              ElevatedButton.icon(
                onPressed: _isGeneratingQuestions
                    ? null
                    : () => _generateQuestionsWithAI(course, level),
                icon: _isGeneratingQuestions
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_awesome, size: 16),
                label: Text(
                  _isGeneratingQuestions ? 'Generating...' : 'AI Generate',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: level.questions.length,
              itemBuilder: (context, index) {
                final q = level.questions[index];
                return _buildQuestionCard(course, level, q, index);
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showAddQuestionDialog(course, level),
              icon: const Icon(Icons.add),
              label: const Text('Add Question Manually'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: BorderSide(color: Colors.orange.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(
    InstructorCourse course,
    CourseLevel level,
    CourseQuestion q,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Q${index + 1}',
                  style: const TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(q.text, style: AppTheme.bodyMedium)),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange, size: 18),
                onPressed: () => _showEditQuestionDialog(course, level, q),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(q.options.length, (i) {
              final isCorrect = i == q.correctIndex;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? Colors.green.withOpacity(0.2)
                      : AppTheme.bgBlack,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCorrect
                        ? Colors.green
                        : Colors.grey.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  q.options[i],
                  style: TextStyle(
                    color: isCorrect ? Colors.green : Colors.white,
                    fontSize: 12,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1, end: 0);
  }

  void _saveLevel(InstructorCourse course, CourseLevel level) {
    final updatedLevel = level.copyWith(
      content: _contentController.text,
      videoUrl: _videoUrlController.text,
    );
    ref
        .read(instructorStateProvider.notifier)
        .updateLevel(course.id, level.id, updatedLevel);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Level saved! ✓'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _generateQuestionsWithAI(
    InstructorCourse course,
    CourseLevel level,
  ) async {
    setState(() => _isGeneratingQuestions = true);
    await Future.delayed(const Duration(seconds: 2));
    final newQuestion = CourseQuestion(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: 'What is the purpose of BuildContext?',
      options: [
        'To build widgets',
        'To locate widgets in tree',
        'To manage state',
        'To handle navigation',
      ],
      correctIndex: 1,
    );
    ref
        .read(instructorStateProvider.notifier)
        .addQuestionToLevel(course.id, level.id, newQuestion);
    setState(() => _isGeneratingQuestions = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AI generated a new question! ✨'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  void _showAddQuestionDialog(InstructorCourse course, CourseLevel level) {
    final questionController = TextEditingController();
    final optionControllers = List.generate(
      4,
      (_) => TextEditingController(text: 'Option'),
    );
    int correctIndex = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Add Question', style: AppTheme.headlineMedium),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: questionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Question text',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(
                  4,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Radio<int>(
                          value: i,
                          groupValue: correctIndex,
                          onChanged: (v) =>
                              setDialogState(() => correctIndex = v!),
                          activeColor: Colors.green,
                        ),
                        Expanded(
                          child: TextField(
                            controller: optionControllers[i],
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Option ${i + 1}',
                              hintStyle: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: AppTheme.textGrey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (questionController.text.isNotEmpty) {
                  final newQuestion = CourseQuestion(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    text: questionController.text,
                    options: optionControllers.map((c) => c.text).toList(),
                    correctIndex: correctIndex,
                  );
                  ref
                      .read(instructorStateProvider.notifier)
                      .addQuestionToLevel(course.id, level.id, newQuestion);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditQuestionDialog(
    InstructorCourse course,
    CourseLevel level,
    CourseQuestion oldQuestion,
  ) {
    final questionController = TextEditingController(text: oldQuestion.text);
    final optionControllers = oldQuestion.options
        .map((o) => TextEditingController(text: o))
        .toList();
    int correctIndex = oldQuestion.correctIndex;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Edit Question', style: AppTheme.headlineMedium),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: questionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Question text',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(
                  optionControllers.length,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Radio<int>(
                          value: i,
                          groupValue: correctIndex,
                          onChanged: (v) =>
                              setDialogState(() => correctIndex = v!),
                          activeColor: Colors.green,
                        ),
                        Expanded(
                          child: TextField(
                            controller: optionControllers[i],
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Option ${i + 1}',
                              hintStyle: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: AppTheme.textGrey)),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedQuestion = oldQuestion.copyWith(
                  text: questionController.text,
                  options: optionControllers.map((c) => c.text).toList(),
                  correctIndex: correctIndex,
                );
                ref
                    .read(instructorStateProvider.notifier)
                    .updateQuestion(
                      course.id,
                      level.id,
                      oldQuestion.id,
                      updatedQuestion,
                    );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Question updated! ✓'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameLevelDialog(InstructorCourse course, CourseLevel level) {
    final controller = TextEditingController(text: level.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Rename Level', style: AppTheme.headlineMedium),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Level name',
            hintStyle: TextStyle(color: AppTheme.textGrey),
            filled: true,
            fillColor: AppTheme.bgBlack,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textGrey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final updatedLevel = level.copyWith(title: controller.text);
                ref
                    .read(instructorStateProvider.notifier)
                    .updateLevel(course.id, level.id, updatedLevel);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Level renamed to "${controller.text}"'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Rename', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
