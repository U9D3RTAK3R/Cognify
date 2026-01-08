import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = [
      {'icon': Icons.bolt, 'value': '2,450', 'label': 'Total XP', 'color': AppTheme.primaryCyan},
      {'icon': Icons.emoji_events, 'value': '12', 'label': 'Battles Won', 'color': AppTheme.accentPurple},
      {'icon': Icons.local_fire_department, 'value': '7', 'label': 'Day Streak', 'color': const Color(0xFFFF6B35)},
      {'icon': Icons.military_tech, 'value': '#42', 'label': 'Global Rank', 'color': const Color(0xFF00FF7F)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: (stat['color'] as Color).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(stat['icon'] as IconData, color: stat['color'] as Color, size: 28),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stat['value'] as String,
                    style: AppTheme.headlineMedium.copyWith(color: stat['color'] as Color),
                  ),
                  Text(
                    stat['label'] as String,
                    style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(delay: (index * 100).ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
      },
    );
  }
}
