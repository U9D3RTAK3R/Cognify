import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class XpBar extends StatelessWidget {
  final int level;
  final int currentXp;
  final int maxXp;
  final String rank;

  const XpBar({
    super.key,
    required this.level,
    required this.currentXp,
    required this.maxXp,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentXp / maxXp;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryCyan.withOpacity(0.2),
              border: Border.all(color: AppTheme.primaryCyan, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryCyan.withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                "$level",
                style: AppTheme.headlineMedium.copyWith(
                  color: AppTheme.primaryCyan,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      rank,
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "$currentXp / $maxXp XP",
                      style: AppTheme.labelLarge.copyWith(
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.black.withOpacity(0.5),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.accentPurple,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
