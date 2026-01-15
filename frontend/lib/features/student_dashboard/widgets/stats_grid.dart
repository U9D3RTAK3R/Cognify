import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/gamification_state.dart';

class StatsGrid extends ConsumerWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamification = ref.watch(gamificationProvider);
    final stats = gamification.userStats;

    final statItems = [
      {
        'icon': Icons.bolt,
        'value': stats.totalXp.toString(),
        'label': 'Total XP',
        'color': AppTheme.primaryCyan,
      },
      {
        'icon': Icons.emoji_events,
        'value': stats.battlesWon.toString(),
        'label': 'Battles Won',
        'color': AppTheme.accentPurple,
      },
      {
        'icon': Icons.local_fire_department,
        'value': stats.currentStreak.toString(),
        'label': 'Day Streak',
        'color': const Color(0xFFFF6B35),
      },
      {
        'icon': Icons.military_tech,
        'value': '#${stats.globalRank}',
        'label': 'Global Rank',
        'color': const Color(0xFF00FF7F),
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive: 4 columns on wide screens, 2 on narrow
        final isWide = constraints.maxWidth > 600;
        final crossAxisCount = isWide ? 4 : 2;
        final childAspectRatio = isWide ? 1.2 : 1.5;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: statItems.length,
          itemBuilder: (context, index) {
            final stat = statItems[index];
            return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (stat['color'] as Color).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        stat['icon'] as IconData,
                        color: stat['color'] as Color,
                        size: 28,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stat['value'] as String,
                            style: AppTheme.headlineMedium.copyWith(
                              color: stat['color'] as Color,
                            ),
                          ),
                          Text(
                            stat['label'] as String,
                            style: TextStyle(
                              color: AppTheme.textGrey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(delay: (index * 100).ms)
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
          },
        );
      },
    );
  }
}
