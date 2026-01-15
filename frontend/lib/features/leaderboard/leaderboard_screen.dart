import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/gamification_state.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamification = ref.watch(gamificationProvider);
    final leaderboard = gamification.leaderboard;

    return Scaffold(
      backgroundColor: AppTheme.bgBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
            const SizedBox(width: 8),
            Text("Leaderboard", style: AppTheme.headlineMedium),
          ],
        ),
      ),
      body: gamification.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryCyan),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Podium for top 3
                  if (leaderboard.length >= 3) _buildPodium(leaderboard),
                  const SizedBox(height: 24),

                  // Rest of leaderboard (4-10)
                  if (leaderboard.length > 3)
                    ...leaderboard
                        .skip(3)
                        .map((entry) => _buildLeaderboardItem(entry))
                        .toList(),

                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  Widget _buildPodium(List<LeaderboardEntry> leaderboard) {
    final first = leaderboard[0];
    final second = leaderboard[1];
    final third = leaderboard[2];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.cardColor, AppTheme.bgBlack],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            "TOP CHAMPIONS",
            style: AppTheme.labelLarge.copyWith(
              color: Colors.amber,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2nd Place (Silver)
              _buildPodiumPlace(
                entry: second,
                height: 100,
                color: const Color(0xFFC0C0C0),
                medal: "🥈",
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),

              const SizedBox(width: 8),

              // 1st Place (Gold)
              _buildPodiumPlace(
                entry: first,
                height: 140,
                color: const Color(0xFFFFD700),
                medal: "🥇",
                isWinner: true,
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.3),

              const SizedBox(width: 8),

              // 3rd Place (Bronze)
              _buildPodiumPlace(
                entry: third,
                height: 80,
                color: const Color(0xFFCD7F32),
                medal: "🥉",
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildPodiumPlace({
    required LeaderboardEntry entry,
    required double height,
    required Color color,
    required String medal,
    bool isWinner = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar with crown for winner
        Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: isWinner ? 70 : 55,
              height: isWinner ? 70 : 55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.8), color.withOpacity(0.4)],
                ),
                border: Border.all(color: color, width: 3),
                boxShadow: isWinner
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  entry.avatarEmoji,
                  style: TextStyle(fontSize: isWinner ? 32 : 24),
                ),
              ),
            ),
            if (isWinner)
              Positioned(
                top: -20,
                child: const Text("👑", style: TextStyle(fontSize: 24)),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Name
        SizedBox(
          width: 80,
          child: Text(
            entry.name,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isWinner ? 14 : 12,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // XP
        Text(
          "${entry.totalXp} XP",
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: isWinner ? 16 : 12,
          ),
        ),

        const SizedBox(height: 8),

        // Podium block
        Container(
          width: 90,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color, color.withOpacity(0.6)],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Text(medal, style: const TextStyle(fontSize: 36)),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(LeaderboardEntry entry) {
    Color rankColor = AppTheme.primaryCyan;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryCyan.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                "#${entry.rank}",
                style: TextStyle(
                  color: rankColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primaryCyan.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                entry.avatarEmoji,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name & Level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "Level ${entry.level}",
                  style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
                ),
              ],
            ),
          ),

          // XP
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${entry.totalXp}",
                style: const TextStyle(
                  color: AppTheme.primaryCyan,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                "XP",
                style: TextStyle(color: AppTheme.textGrey, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (entry.rank * 50).ms).slideX(begin: 0.1);
  }
}
