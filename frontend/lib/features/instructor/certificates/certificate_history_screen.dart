import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/instructor_state.dart';

class CertificateHistoryScreen extends ConsumerWidget {
  const CertificateHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instructorState = ref.watch(instructorStateProvider);
    final certificates = instructorState.certificates;

    return Scaffold(
      backgroundColor: AppTheme.bgBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Certificate History', style: AppTheme.headlineMedium),
      ),
      body: certificates.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: AppTheme.textGrey),
                  const SizedBox(height: 16),
                  Text(
                    'No certificates issued yet',
                    style: TextStyle(color: AppTheme.textGrey, fontSize: 18),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: certificates.length,
              itemBuilder: (context, index) {
                final cert = certificates[index];
                return _certificateCard(cert, index);
              },
            ),
    );
  }

  Widget _certificateCard(GeneratedCertificate cert, int index) {
    final daysAgo = DateTime.now().difference(cert.createdAt).inDays;
    final timeAgo = daysAgo == 0
        ? 'Today'
        : daysAgo == 1
        ? 'Yesterday'
        : '$daysAgo days ago';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cert.isAiGenerated
              ? Colors.purple.withOpacity(0.5)
              : Colors.orange.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (cert.isAiGenerated ? Colors.purple : Colors.orange)
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  cert.isAiGenerated ? Icons.auto_awesome : Icons.verified,
                  color: cert.isAiGenerated ? Colors.purple : Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cert.studentName,
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      cert.courseName,
                      style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: (cert.isAiGenerated ? Colors.purple : Colors.orange)
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  cert.isAiGenerated ? 'AI' : 'Manual',
                  style: TextStyle(
                    color: cert.isAiGenerated ? Colors.purple : Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.palette_outlined, size: 14, color: AppTheme.textGrey),
              const SizedBox(width: 4),
              Text(
                'Template: ${cert.templateName}',
                style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
              ),
              const Spacer(),
              Icon(Icons.schedule, size: 14, color: AppTheme.textGrey),
              const SizedBox(width: 4),
              Text(
                timeAgo,
                style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1, end: 0);
  }
}
