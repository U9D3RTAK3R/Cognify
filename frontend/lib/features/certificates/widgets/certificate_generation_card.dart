import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class CertificateGenerationCard extends StatelessWidget {
  const CertificateGenerationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primaryCyan.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryCyan.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon and Title
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryCyan.withOpacity(0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryCyan.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.school_rounded,
              size: 40,
              color: AppTheme.primaryCyan,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
          
          const SizedBox(height: 16),
          
          Text(
            "Generate Blockchain Certificate",
            style: AppTheme.headlineMedium.copyWith(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Mint a soulbound verified academic certificate",
            style: TextStyle(color: AppTheme.textGrey),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Connect Wallet Button
          _buildNeonButton(
            context,
            label: "Connect Wallet (MetaMask)",
            icon: Icons.account_balance_wallet_outlined,
            color: Colors.orangeAccent,
            onTap: () {},
          ),
          
          const SizedBox(height: 12),
          
          // Generate Button
          _buildNeonButton(
            context,
            label: "Generate Certificate",
            icon: Icons.auto_awesome,
            color: AppTheme.primaryCyan,
            onTap: () {},
            isPrimary: true,
          ),
          
          const SizedBox(height: 16),
          
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Status: Pending",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildNeonButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? LinearGradient(
                  colors: [
                    color.withOpacity(0.8),
                    color.withOpacity(0.4),
                  ],
                )
              : null,
          color: isPrimary ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(isPrimary ? 0.0 : 0.5),
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isPrimary ? Colors.white : color, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
