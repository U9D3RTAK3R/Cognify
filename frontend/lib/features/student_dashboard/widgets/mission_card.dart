import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../data/mock_data.dart';

class MissionCard extends StatelessWidget {
  final Course course;

  const MissionCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            Color(int.parse(course.colorHex)).withOpacity(0.2),
            AppTheme.cardColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Color(int.parse(course.colorHex)).withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(int.parse(course.colorHex)).withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: Color(int.parse(course.colorHex)).withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(course.emoji, style: const TextStyle(fontSize: 30)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.title, style: AppTheme.headlineMedium),
                const SizedBox(height: 4),
                Text(
                  course.subtitle,
                  style: AppTheme.labelLarge.copyWith(color: AppTheme.textGrey),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: course.progress,
                          backgroundColor: Colors.black.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(int.parse(course.colorHex)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "${(course.progress * 100).toInt()}%",
                      style: AppTheme.labelLarge.copyWith(
                        color: Color(int.parse(course.colorHex)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
