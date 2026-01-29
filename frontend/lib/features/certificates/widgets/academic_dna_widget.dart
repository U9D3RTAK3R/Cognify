import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class AcademicDnaWidget extends StatelessWidget {
  const AcademicDnaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryCyan.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryCyan.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 1,
            // inset: true, // Flutter default shadow doesn't support inset easily, skipping
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "ACADEMIC DNA HASH",
                style: TextStyle(
                  color: AppTheme.primaryCyan.withOpacity(0.8),
                  fontSize: 12,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.hub, color: AppTheme.primaryCyan.withOpacity(0.5), size: 18),
            ],
          ),
          const SizedBox(height: 20),
          
          // Visual DNA representation
          SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(20, (index) {
                // Generate varied heights for "DNA" bars
                final height = 20.0 + (index % 5) * 8.0 + (index % 3) * 5.0;
                final color = index % 2 == 0 ? AppTheme.primaryCyan : AppTheme.accentPurple;
                
                return Container(
                  width: 4,
                  height: height,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                 .scaleY(
                   begin: 0.8, 
                   end: 1.2, 
                   duration: Duration(milliseconds: 800 + index * 50),
                   curve: Curves.easeInOut,
                 );
              }),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Hash Text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "8f434346648f6b96df89dda901c5176b10a6d59...",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontFamily: 'Courier',
                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.copy, size: 14, color: Colors.white.withOpacity(0.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
