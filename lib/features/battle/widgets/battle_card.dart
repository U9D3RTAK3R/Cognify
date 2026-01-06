import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class BattleCard extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const BattleCard({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryCyan
                : Colors.white.withOpacity(0.2),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryCyan.withOpacity(0.5),
                    blurRadius: 20,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.flash_on, color: Colors.amber),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: AppTheme.bodyMedium.copyWith(
                  color: isSelected ? AppTheme.primaryCyan : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
