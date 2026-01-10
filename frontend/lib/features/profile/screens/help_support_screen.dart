import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';

class HelpSupportScreen extends ConsumerStatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  ConsumerState<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends ConsumerState<HelpSupportScreen> {
  final Map<int, bool> _expandedFaqs = {};

  final List<Map<String, String>> _faqItems = [
    {
      'question': 'How do I reset my password?',
      'answer':
          'Go to Settings > Account > Reset Password. You will receive an email with a link to create a new password. The link expires in 24 hours.',
    },
    {
      'question': 'How can I earn more XP?',
      'answer':
          'You can earn XP by:\n• Completing daily challenges (+50 XP)\n• Winning boss battles (+150 XP)\n• Finishing course modules (+100 XP)\n• Maintaining your streak (+25 XP/day)',
    },
    {
      'question': 'How to cancel my subscription?',
      'answer':
          'To cancel your subscription:\n1. Go to Profile > Settings\n2. Tap "Manage Subscription"\n3. Select "Cancel Subscription"\n\nYour access continues until the billing period ends.',
    },
    {
      'question': 'Is my data secure?',
      'answer':
          'Yes! We use industry-standard encryption (AES-256) for all data. Your information is stored securely and never shared with third parties without consent.',
    },
    {
      'question': 'How do I contact support?',
      'answer':
          'You can reach us via:\n• Phone: +1 (555) 123-4567\n• Email: support@cognify.app\n• Live Chat: Available 24/7 in the app',
    },
  ];

  Future<void> _launchPhone() async {
    final uri = Uri.parse('tel:+15551234567');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail() async {
    final uri = Uri.parse(
      'mailto:support@cognify.app?subject=Support%20Request',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

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
              _launchPhone,
            ),
            const SizedBox(height: 12),
            _contactCard(
              context,
              '✉️',
              'Email Support',
              'support@cognify.app',
              'Response within 24 hours',
              AppTheme.accentPurple,
              _launchEmail,
            ),
            const SizedBox(height: 12),
            _contactCard(
              context,
              '💬',
              'Live Chat',
              'Chat with us',
              'Instant support available',
              const Color(0xFF00FF7F),
              () => context.push('/profile/help/chat'),
            ),

            const SizedBox(height: 24),

            Text(
              'FAQ',
              style: AppTheme.labelLarge.copyWith(color: AppTheme.primaryCyan),
            ),
            const SizedBox(height: 12),

            ...List.generate(_faqItems.length, (index) => _faqItem(index)),
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
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ).animate().fadeIn().slideX(begin: 0.1, end: 0),
    );
  }

  Widget _faqItem(int index) {
    final faq = _faqItems[index];
    final isExpanded = _expandedFaqs[index] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isExpanded
            ? Border.all(color: AppTheme.accentPurple.withOpacity(0.3))
            : null,
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expandedFaqs[index] = !isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    isExpanded ? Icons.help : Icons.help_outline,
                    color: isExpanded
                        ? AppTheme.accentPurple
                        : AppTheme.textGrey,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      faq['question']!,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: isExpanded
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(48, 0, 16, 16),
              child: Text(
                faq['answer']!,
                style: TextStyle(color: AppTheme.textGrey, height: 1.5),
              ),
            ).animate().fadeIn().slideY(begin: -0.1, end: 0),
        ],
      ),
    );
  }
}
