import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class CertificateHistoryList extends StatelessWidget {
  const CertificateHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final certificates = [
      {
        'course': 'Advanced AI Algorithms',
        'date': 'Jan 15, 2026',
        'id': '#8823',
        'hash': '0x7a...9b2c',
      },
      {
        'course': 'Blockchain Fundamentals',
        'date': 'Oct 2, 2025',
        'id': '#4412',
        'hash': '0x3c...1a4d',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history, color: AppTheme.primaryCyan),
            const SizedBox(width: 8),
            Text("Certificate History", style: AppTheme.headlineMedium.copyWith(fontSize: 18)),
            const Spacer(),
            Icon(Icons.lock_outline, color: AppTheme.primaryCyan.withOpacity(0.5), size: 16),
            const SizedBox(width: 4),
            Text(
              "Protected on Chain",
              style: TextStyle(color: AppTheme.primaryCyan.withOpacity(0.5), fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: certificates.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final cert = certificates[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        cert['course']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryCyan.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          cert['id']!,
                          style: const TextStyle(
                            color: AppTheme.primaryCyan,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: AppTheme.textGrey),
                      const SizedBox(width: 4),
                      Text(
                        cert['date']!,
                        style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.link, size: 12, color: AppTheme.accentPurple),
                      const SizedBox(width: 4),
                      Text(
                        cert['hash']!,
                        style: TextStyle(
                          color: AppTheme.accentPurple.withOpacity(0.8),
                          fontFamily: 'Courier',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.download, size: 16),
                          label: const Text("PDF"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.white.withOpacity(0.2)),
                            padding: const EdgeInsets.symmetric(vertical: 0),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: const Text("Explorer"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryCyan,
                            side: BorderSide(color: AppTheme.primaryCyan.withOpacity(0.3)),
                            padding: const EdgeInsets.symmetric(vertical: 0),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().slideX(
              begin: 0.1, 
              end: 0, 
              delay: Duration(milliseconds: 100 * index),
            );
          },
        ),
      ],
    );
  }
}
