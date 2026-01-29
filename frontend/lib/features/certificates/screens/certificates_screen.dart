import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_animations.dart';
import '../../../shared/animations/breathing_card.dart';
import '../../../shared/animations/animated_neon_button.dart';
import '../../../shared/animations/holographic_shimmer.dart';
import '../widgets/academic_dna_widget.dart';
import '../widgets/certificate_history_list.dart';
import '../../../core/providers/auth_state.dart';
import '../../../shared/animations/ambient_background.dart';
import '../widgets/certificate_generation_card.dart';
import '../widgets/soulbound_identity_badge.dart';

class CertificatesScreen extends ConsumerWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isInstructor = authState.role == 'instructor';
    return Scaffold(
      backgroundColor: AppTheme.bgBlack,
      appBar: AppBar(
        title: Text('Certificates', style: AppTheme.headlineMedium),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryCyan),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: AmbientBackground(
        child: AppAnimations.pageTransitionWrapper(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (isInstructor) ...[
                  const BreathingCard(
                    glowColor: AppTheme.accentPurple,
                    child: SoulboundIdentityBadge(),
                  ),
                  const SizedBox(height: 24),
                ],
                
                const BreathingCard(
                  glowColor: AppTheme.primaryCyan,
                  child: AcademicDnaWidget(),
                ),
                const SizedBox(height: 24),

                if (isInstructor) ...[
                  const CertificateGenerationCard(),
                  const SizedBox(height: 24),
                ],

                const CertificateHistoryList(),
                const SizedBox(height: 24),
                
                // Link to Verification
                SizedBox(
                  width: double.infinity,
                  child: HolographicShimmer(
                    child: AnimatedNeonButton(
                      onTap: () => context.push('/profile/certificates/verify'),
                      icon: Icons.verified_user_outlined,
                      label: "Verify a Certificate",
                      color: AppTheme.primaryCyan,
                    ),
                  ),
                ),
                
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
