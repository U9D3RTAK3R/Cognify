import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import 'data/battle_state.dart';
import 'widgets/card_deck.dart';
import 'widgets/boss_hp_bar.dart';

class BattleScreen extends ConsumerStatefulWidget {
  const BattleScreen({super.key});

  @override
  ConsumerState<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends ConsumerState<BattleScreen> {
  int? _selectedIndex;
  bool _showResult = false;

  void _onCardSelect(int index) {
    if (_showResult) return;

    setState(() {
      _selectedIndex = index;
      _showResult = true;
    });

    final controller = ref.read(battleProvider.notifier);

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        controller.submitAnswer(index);
        setState(() {
          _selectedIndex = null;
          _showResult = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final battleState = ref.watch(battleProvider);
    final controller = ref.read(battleProvider.notifier);
    final currentQuestion = controller.currentQuestion;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppTheme.bgBlack,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.2,
                colors: [Colors.red.withOpacity(0.25), AppTheme.bgBlack],
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableHeight = constraints.maxHeight;
                final bossAreaHeight = availableHeight * 0.25;
                final questionAreaHeight = availableHeight * 0.18;
                final cardAreaHeight = availableHeight * 0.35;

                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: availableHeight),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                              Text(
                                "BOSS BATTLE",
                                style: AppTheme.labelLarge.copyWith(
                                  color: Colors.red,
                                  letterSpacing: 3,
                                ),
                              ),
                              const SizedBox(width: 48),
                            ],
                          ),
                        ),

                        // HP Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: BossHpBar(
                            currentHp: battleState.bossHp,
                            maxHp: battleState.maxBossHp,
                          ),
                        ),

                        // Boss Area
                        SizedBox(
                          height: bossAreaHeight,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            Colors.red.shade800,
                                            Colors.red.shade900,
                                            Colors.black,
                                          ],
                                          stops: const [0.0, 0.5, 1.0],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.red.withOpacity(0.6),
                                            blurRadius: 25,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.bug_report,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                    )
                                    .animate(
                                      target:
                                          _showResult &&
                                              _selectedIndex ==
                                                  currentQuestion.correctIndex
                                          ? 1
                                          : 0,
                                    )
                                    .shake(hz: 5, duration: 500.ms),
                                const SizedBox(height: 12),
                                if (battleState.feedbackMessage != null)
                                  Text(
                                    battleState.feedbackMessage!,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          battleState.feedbackMessage!.contains(
                                            "Correct",
                                          )
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ).animate().fadeIn().scale(),
                              ],
                            ),
                          ),
                        ),

                        // Question Panel
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.primaryCyan.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Question ${battleState.currentQuestionIndex + 1}",
                                style: AppTheme.labelLarge.copyWith(
                                  color: AppTheme.primaryCyan,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                currentQuestion.text,
                                style: AppTheme.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn().slideY(begin: 0.1, end: 0),

                        const SizedBox(height: 12),

                        // Card Deck
                        SizedBox(
                          height: cardAreaHeight,
                          child: CardDeck(
                            options: currentQuestion.options,
                            onSelect: _onCardSelect,
                            selectedIndex: _selectedIndex,
                            correctIndex: currentQuestion.correctIndex,
                            showResult: _showResult,
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Victory Overlay
          if (battleState.isVictory)
            Container(
              color: Colors.black.withOpacity(0.85),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("🏆", style: TextStyle(fontSize: 70)),
                    const SizedBox(height: 20),
                    Text(
                      "VICTORY!",
                      style: AppTheme.headlineLarge.copyWith(
                        color: Colors.amber,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Boss Defeated!",
                      style: AppTheme.bodyLarge.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                      ),
                      child: const Text(
                        "CLAIM REWARDS",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ).animate().fadeIn().scale(),
              ),
            ),
        ],
      ),
    );
  }
}
