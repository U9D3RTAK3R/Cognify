import 'dart:convert';
import 'package:cognify/core/config/api_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class Question {
  final String id;
  final String text;
  final String bossImage; // Kept for UI compatibility, defaulted
  final List<String> options;
  final int correctIndex;
  final String difficulty;
  final String topic;

  Question({
    required this.id,
    required this.text,
    this.bossImage = "assets/boss1.png",
    required this.options,
    required this.correctIndex,
    required this.difficulty,
    required this.topic,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctIndex: json['correctIndex'] ?? 0,
      difficulty: json['difficulty'] ?? 'Easy',
      topic: json['topic'] ?? 'General',
    );
  }
}

class BattleState {
  final int bossHp;
  final int maxBossHp;
  final int currentQuestionIndex;
  final bool isGameOver;
  final bool isVictory;
  final String? feedbackMessage;
  final bool isLoading;
  final List<Question> questions;

  BattleState({
    required this.bossHp,
    required this.maxBossHp,
    required this.currentQuestionIndex,
    required this.isGameOver,
    required this.isVictory,
    this.feedbackMessage,
    this.isLoading = false,
    this.questions = const [],
  });

  BattleState copyWith({
    int? bossHp,
    int? maxBossHp,
    int? currentQuestionIndex,
    bool? isGameOver,
    bool? isVictory,
    String? feedbackMessage,
    bool? isLoading,
    List<Question>? questions,
  }) {
    return BattleState(
      bossHp: bossHp ?? this.bossHp,
      maxBossHp: maxBossHp ?? this.maxBossHp,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      isGameOver: isGameOver ?? this.isGameOver,
      isVictory: isVictory ?? this.isVictory,
      feedbackMessage: feedbackMessage,
      isLoading: isLoading ?? this.isLoading,
      questions: questions ?? this.questions,
    );
  }
}

class BattleController extends Notifier<BattleState> {
  @override
  BattleState build() {
    // Initial state is loading
    Future.microtask(() => _fetchQuestions());
    return BattleState(
      bossHp: 100,
      maxBossHp: 100,
      currentQuestionIndex: 0,
      isGameOver: false,
      isVictory: false,
      isLoading: true,
      questions: [],
    );
  }

  Future<void> _fetchQuestions() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.apiUrl}/battles/questions'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> qList = data['questions'];
          final questions = qList.map((q) => Question.fromJson(q)).toList();

          state = state.copyWith(isLoading: false, questions: questions);
          return;
        }
      }
      // Handle error or empty
      state = state.copyWith(
        isLoading: false,
        feedbackMessage: "Failed to load questions",
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        feedbackMessage: "Error connecting to server",
      );
    }
  }

  void submitAnswer(int index) {
    if (state.isGameOver || state.questions.isEmpty) return;

    final currentQuestion = state.questions[state.currentQuestionIndex];
    if (index == currentQuestion.correctIndex) {
      int newHp = state.bossHp - 50;
      if (newHp <= 0) {
        newHp = 0;
        state = state.copyWith(
          bossHp: newHp,
          isVictory: true,
          isGameOver: true,
          feedbackMessage: "CRITICAL HIT! BOSS DEFEATED!",
        );
      } else {
        state = state.copyWith(
          bossHp: newHp,
          currentQuestionIndex:
              (state.currentQuestionIndex + 1) % state.questions.length,
          feedbackMessage: "Direct Hit! -50 HP",
        );
      }
    } else {
      state = state.copyWith(feedbackMessage: "Missed! Try Again!");
    }
  }

  Question? get currentQuestion => state.questions.isNotEmpty
      ? state.questions[state.currentQuestionIndex]
      : null;
}

final battleProvider = NotifierProvider<BattleController, BattleState>(
  BattleController.new,
);
