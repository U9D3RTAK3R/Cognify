import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgBlack,
      appBar: AppBar(
        title: Text('Help & Support', style: AppTheme.headlineMedium),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryCyan.withOpacity(0.2),
                    AppTheme.accentPurple.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppTheme.primaryCyan.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  const Text('🛟', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text('Need Help?', style: AppTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Our team is here to assist you 24/7',
                    style: TextStyle(color: AppTheme.textGrey),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.1, end: 0),

            const SizedBox(height: 24),

            Text(
              'CONTACT US',
              style: AppTheme.labelLarge.copyWith(color: AppTheme.primaryCyan),
            ),
            const SizedBox(height: 12),

            _contactCard(
              context,
              '📞',
              'Phone Support',
              '+1 (555) 123-4567',
              'Available 9 AM - 6 PM EST',
              AppTheme.primaryCyan,
            ),
            const SizedBox(height: 12),
            _contactCard(
              context,
              '✉️',
              'Email Support',
              'support@cognify.app',
              'Response within 24 hours',
              AppTheme.accentPurple,
            ),
            const SizedBox(height: 12),
            _contactCard(
              context,
              '💬',
              'Live Chat',
              'Chat with us',
              'Instant support available',
              const Color(0xFF00FF7F),
            ),

            const SizedBox(height: 24),

            Text(
              'FAQ',
              style: AppTheme.labelLarge.copyWith(color: AppTheme.primaryCyan),
            ),
            const SizedBox(height: 12),

            _faqItem('How do I reset my password?'),
            _faqItem('How can I earn more XP?'),
            _faqItem('How to cancel my subscription?'),
            _faqItem('Is my data secure?'),
          ],
        ),
      ),
    );
  }

  Widget _contactCard(
    BuildContext context,
    String emoji,
    String title,
    String value,
    String subtitle,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
                ),
                Text(value, style: AppTheme.bodyLarge.copyWith(color: color)),
                Text(
                  subtitle,
                  style: TextStyle(color: AppTheme.textGrey, fontSize: 11),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: color),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }

  Widget _faqItem(String question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.help_outline,
            color: AppTheme.accentPurple,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(question, style: AppTheme.bodyMedium)),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
    );
  }
}
