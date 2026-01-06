import 'package:flutter_riverpod/flutter_riverpod.dart';

class Question {
  final String id;
  final String text;
  final String bossImage;
  final List<String> options;
  final int correctIndex;

  Question({
    required this.id,
    required this.text,
    required this.bossImage,
    required this.options,
    required this.correctIndex,
  });
}

class BattleState {
  final int bossHp;
  final int maxBossHp;
  final int currentQuestionIndex;
  final bool isGameOver;
  final bool isVictory;
  final String? feedbackMessage;

  BattleState({
    required this.bossHp,
    required this.maxBossHp,
    required this.currentQuestionIndex,
    required this.isGameOver,
    required this.isVictory,
    this.feedbackMessage,
  });

  BattleState copyWith({
    int? bossHp,
    int? maxBossHp,
    int? currentQuestionIndex,
    bool? isGameOver,
    bool? isVictory,
    String? feedbackMessage,
  }) {
    return BattleState(
      bossHp: bossHp ?? this.bossHp,
      maxBossHp: maxBossHp ?? this.maxBossHp,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      isGameOver: isGameOver ?? this.isGameOver,
      isVictory: isVictory ?? this.isVictory,
      feedbackMessage: feedbackMessage,
    );
  }
}

class BattleController extends Notifier<BattleState> {
  final List<Question> questions = [
    Question(
      id: "q1",
      text: "Which Widget is used for infinite scrolling lists?",
      bossImage: "assets/boss1.png",
      options: ["Column", "ListView.builder", "Stack", "Container"],
      correctIndex: 1,
    ),
    Question(
      id: "q2",
      text: "What manages state in Riverpod?",
      bossImage: "assets/boss2.png",
      options: ["Provider", "Controller", "Bloc", "SetState"],
      correctIndex: 0,
    ),
  ];

  @override
  BattleState build() {
    return BattleState(
      bossHp: 100,
      maxBossHp: 100,
      currentQuestionIndex: 0,
      isGameOver: false,
      isVictory: false,
    );
  }

  void submitAnswer(int index) {
    if (state.isGameOver) return;

    final currentQuestion = questions[state.currentQuestionIndex];
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
              (state.currentQuestionIndex + 1) % questions.length,
          feedbackMessage: "Direct Hit! -50 HP",
        );
      }
    } else {
      state = state.copyWith(feedbackMessage: "Missed! Try Again!");
    }
  }

  Question get currentQuestion => questions[state.currentQuestionIndex];
}

final battleProvider = NotifierProvider<BattleController, BattleState>(
  BattleController.new,
);
