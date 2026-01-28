import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';
import '../../core/providers/user_state.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../battle/widgets/card_deck.dart';

// Models
class CourseLevel {
  final String id;
  final String title;
  final String content;
  final String videoUrl;
  final List<BattleQuestion> questions;

  CourseLevel({
    required this.id,
    required this.title,
    required this.content,
    required this.videoUrl,
    required this.questions,
  });

  factory CourseLevel.fromJson(Map<String, dynamic> json) {
    var parsedQuestions = <BattleQuestion>[];
    if (json['questions'] != null) {
      final list = json['questions'] as List;
      parsedQuestions = list
          .map((q) {
            if (q is Map<String, dynamic>) {
              return BattleQuestion.fromJson(q);
            }
            // Handle case where it might be a mix or just IDs (failed migration?)
            return null;
          })
          .whereType<BattleQuestion>()
          .toList();
    }

    return CourseLevel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      questions: parsedQuestions,
    );
  }
}

class BattleQuestion {
  final String id;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String topic;
  final int points;

  BattleQuestion({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.topic,
    required this.points,
  });

  factory BattleQuestion.fromJson(Map<String, dynamic> json) {
    return BattleQuestion(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctIndex: json['correctIndex'] ?? 0,
      topic: json['topic'] ?? 'General',
      points: json['points'] ?? 10,
    );
  }
}

class LessonScreen extends ConsumerStatefulWidget {
  final String courseId;
  final String levelId;
  final String levelTitle;

  const LessonScreen({
    super.key,
    required this.courseId,
    required this.levelId,
    required this.levelTitle,
  });

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  CourseLevel? _level;
  List<BattleQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  Map<String, int> _userAnswers = {};
  bool _isLoading = true;
  bool _battleComplete = false;
  Map<String, dynamic>? _completionResult;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchLevelData();
  }

  Future<void> _fetchLevelData() async {
    try {
      // Check if data was passed in extra first (Optional optimization for later, sticking to fetch for now)
      // Fetch course to get level data
      final courseResponse = await ApiService.get(
        '/api/course?id=${widget.courseId}',
      );
      if (courseResponse['success'] == true &&
          courseResponse['course'] != null) {
        final course = courseResponse['course'];
        final levels = List<Map<String, dynamic>>.from(course['levels'] ?? []);

        for (var l in levels) {
          if (l['id'] == widget.levelId) {
            _level = CourseLevel.fromJson(l);
            break;
          }
        }
      }

      // Populate questions directly from the level
      if (_level != null) {
        _questions = _level!.questions;
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error fetching level: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _selectAnswer(String questionId, int index) {
    setState(() {
      _userAnswers[questionId] = index;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() => _currentQuestionIndex++);
    } else {
      _submitBattle();
    }
  }

  Future<void> _submitBattle() async {
    setState(() => _isLoading = true);

    try {
      final answers = _userAnswers.entries
          .map((e) => {'questionId': e.key, 'selectedIndex': e.value})
          .toList();

      // Get actual user ID from auth state
      final userState = ref.read(userStateProvider);
      final userId = userState.profile.id;

      final response = await ApiService.post('/api/course/level/complete', {
        'userId': userId,
        'courseId': widget.courseId,
        'levelId': widget.levelId,
        'answers': answers,
        'timeTakenSeconds': 120,
      });

      setState(() {
        _battleComplete = true;
        _completionResult = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _launchVideo() async {
    if (_level?.videoUrl != null && _level!.videoUrl.isNotEmpty) {
      final uri = Uri.parse(_level!.videoUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _level == null) {
      return Scaffold(
        backgroundColor: AppTheme.bgBlack,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(widget.levelTitle),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.bgBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _level?.title ?? widget.levelTitle,
          style: AppTheme.headlineMedium,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryCyan,
          labelColor: AppTheme.primaryCyan,
          unselectedLabelColor: AppTheme.textGrey,
          tabs: const [
            Tab(icon: Icon(Icons.menu_book), text: 'Read'),
            Tab(icon: Icon(Icons.play_circle), text: 'Watch'),
            Tab(icon: Icon(Icons.sports_esports), text: 'Battle'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildReadTab(), _buildWatchTab(), _buildBattleTab()],
      ),
    );
  }

  Widget _buildReadTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primaryCyan.withOpacity(0.3)),
            ),
            child: MarkdownBody(
              data: _level?.content ?? '# Loading...',
              styleSheet: MarkdownStyleSheet(
                h1: AppTheme.headlineMedium.copyWith(
                  color: AppTheme.primaryCyan,
                ),
                h2: AppTheme.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                p: AppTheme.bodyMedium.copyWith(
                  color: Colors.white70,
                  height: 1.6,
                ),
                listBullet: const TextStyle(color: AppTheme.primaryCyan),
                code: TextStyle(
                  backgroundColor: Colors.black54,
                  color: Colors.greenAccent,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ).animate().fadeIn().slideY(begin: 0.1, end: 0),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _tabController.animateTo(1),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Continue to Video'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryCyan,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.withOpacity(0.5)),
              ),
              child: InkWell(
                onTap: _launchVideo,
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.red,
                        size: 56,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tap to Watch Video',
                      style: AppTheme.bodyLarge.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Opens in YouTube',
                      style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn().scale(),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _tabController.animateTo(2),
              icon: const Icon(Icons.sports_esports),
              label: const Text('Start Battle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBattleTab() {
    if (_battleComplete && _completionResult != null) {
      return _buildBattleResults();
    }

    if (_questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz, size: 64, color: AppTheme.textGrey),
            const SizedBox(height: 16),
            Text(
              'No questions available',
              style: TextStyle(color: AppTheme.textGrey),
            ),
          ],
        ),
      );
    }

    final question = _questions[_currentQuestionIndex];
    final selectedAnswer = _userAnswers[question.id];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                style: TextStyle(
                  color: AppTheme.primaryCyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${question.points} XP',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            backgroundColor: Colors.grey[800],
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppTheme.primaryCyan,
            ),
          ),
          const SizedBox(height: 24),

          // Question
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              question.text,
              style: AppTheme.bodyLarge.copyWith(color: Colors.white),
            ),
          ).animate().fadeIn().slideX(begin: 0.1, end: 0),
          const SizedBox(height: 20),

          // Card Deck Options
          Expanded(
            child: CardDeck(
              options: question.options,
              onSelect: (index) {
                _selectAnswer(question.id, index);
                // Auto-proceed after short delay
                Future.delayed(const Duration(milliseconds: 800), () {
                  if (mounted && _userAnswers[question.id] != null) {
                    _nextQuestion();
                  }
                });
              },
              selectedIndex: selectedAnswer,
              correctIndex: question.correctIndex,
              showResult: selectedAnswer != null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBattleResults() {
    final result = _completionResult!;
    final xpGained = result['xpGained'] ?? 0;
    final correct = result['correctCount'] ?? 0;
    final total = result['totalQuestions'] ?? 1;
    final confidence = result['confidenceScore'] ?? 50;
    final feedback = result['aiFeedback'] ?? 'Great work!';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.celebration, size: 80, color: Colors.amber)
                .animate(onPlay: (c) => c.repeat())
                .shimmer(duration: 2.seconds, color: Colors.white30),
            const SizedBox(height: 24),
            Text('Level Complete!', style: AppTheme.headlineLarge),
            const SizedBox(height: 32),

            // Stats cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard('XP Gained', '+$xpGained', Colors.amber),
                _buildStatCard('Correct', '$correct/$total', Colors.green),
                _buildStatCard(
                  'Confidence',
                  '$confidence%',
                  AppTheme.primaryCyan,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // AI Feedback
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.accentPurple.withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppTheme.accentPurple),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feedback,
                      style: TextStyle(
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Course'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryCyan,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(value, style: AppTheme.headlineMedium.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
        ],
      ),
    ).animate().fadeIn().scale();
  }
}
