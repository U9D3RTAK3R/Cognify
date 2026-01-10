import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgBlack,
      appBar: AppBar(
        title: Text('Privacy Policy', style: AppTheme.headlineMedium),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentPurple.withOpacity(0.2),
                    AppTheme.primaryCyan.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('🔒', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 8),
                  Text('Your Privacy Matters', style: AppTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Last updated: January 2026',
                    style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
                  ),
                ],
              ),
            ).animate().fadeIn(),

            const SizedBox(height: 24),

            _policySection(
              '1. Information We Collect',
              'We collect information you provide directly, such as your name, email, and learning preferences. We also automatically collect usage data to improve your experience.',
            ),
            _policySection(
              '2. How We Use Your Information',
              'Your data helps us personalize your learning journey, track progress, and provide AI-powered recommendations. We never sell your personal information.',
            ),
            _policySection(
              '3. Data Security',
              'We implement industry-standard security measures including encryption, secure servers, and regular audits to protect your information.',
            ),
            _policySection(
              '4. Your Rights',
              'You have the right to access, modify, or delete your personal data at any time. Contact our support team for assistance.',
            ),
            _policySection(
              '5. Cookies & Tracking',
              'We use cookies to enhance your experience and analyze app usage. You can manage cookie preferences in your device settings.',
            ),
            _policySection(
              '6. Third-Party Services',
              'We may use third-party services for analytics and payment processing. These partners are bound by strict privacy agreements.',
            ),
            _policySection(
              '7. Children\'s Privacy',
              'Our services are not intended for users under 13. We do not knowingly collect data from children.',
            ),
            _policySection(
              '8. Contact Us',
              'For privacy concerns, contact us at privacy@cognify.app or through the Help & Support section.',
            ),

            const SizedBox(height: 24),

            Center(
              child: Text(
                '© 2026 Cognify. All rights reserved.',
                style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _policySection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.primaryCyan,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(color: Colors.white.withOpacity(0.8), height: 1.5),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.05, end: 0);
  }
}
