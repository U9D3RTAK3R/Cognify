import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'particle_overlay.dart';

class AmbientBackground extends StatefulWidget {
  final Widget child;

  const AmbientBackground({super.key, required this.child});

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15), // Faster speed
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Background
        Container(color: AppTheme.bgBlack),
        
        // Animated Gradient 1 (Stronger)
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Positioned(
              top: -150 + (_controller.value * 100),
              left: -100 + (_controller.value * 50),
              width: 600,
              height: 600,
              child: Opacity(
                opacity: 0.25, // Increased opacity
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [AppTheme.primaryCyan, Colors.transparent],
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Animated Gradient 2 (Stronger)
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Positioned(
              bottom: -150 - (_controller.value * 100),
              right: -100 - (_controller.value * 50),
              width: 600,
              height: 600,
              child: Opacity(
                opacity: 0.2, // Increased opacity
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [AppTheme.accentPurple, Colors.transparent],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        
        // Particle System
        const Positioned.fill(
          child: ParticleOverlay(
            color: AppTheme.primaryCyan,
            numberOfParticles: 40,
          ),
        ),
        const Positioned.fill(
          child: ParticleOverlay(
            color: AppTheme.accentPurple,
            numberOfParticles: 20,
          ),
        ),
        
        // Content
        widget.child,
      ],
    );
  }
}
