import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SoulboundIdentityBadge extends StatelessWidget {
  const SoulboundIdentityBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.accentPurple.withOpacity(0.3)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.cardColor,
            AppTheme.accentPurple.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "SOULBOUND IDENTITY",
                    style: TextStyle(
                      color: AppTheme.accentPurple,
                      fontSize: 10,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.verified_user, 
                        color: AppTheme.primaryCyan, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        "0x71C...9A23",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontFamily: 'Courier', // Monospace for crypto look
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.fingerprint, color: AppTheme.accentPurple),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: _buildStat(
                  "Trust Score",
                  "98/100",
                  AppTheme.primaryCyan,
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.white.withOpacity(0.1),
              ),
              Expanded(
                child: _buildStat(
                  "Credentials",
                  "12",
                  AppTheme.accentPurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textGrey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
